import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/widgets/app_screen.dart';

import '../../core/motion/app_motion.dart';
import '../../core/settings/app_preferences.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/exercise_media.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final Map<String, dynamic>? resumeDraft;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
    this.resumeDraft,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int exerciseIndex = 0;
  int setIndex = 1;
  int rest = 0;
  int completedSets = 0;
  Timer? timer;
  DateTime? _restEndAt;
  late DateTime startedAt;

  final weightController = TextEditingController();
  final repsController = TextEditingController();
  final List<Map<String, dynamic>> _sessionSets = [];
  final Map<String, Map<String, dynamic>> _records = {};

  Map<String, dynamic>? _previousSet;
  bool _loadingPrevious = true;
  bool _completingSet = false;
  bool _restored = false;
  bool _finishedOrDiscarded = false;
  int _prCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startedAt = DateTime.now();
    _restoreDraft(widget.resumeDraft);
    _prepareWorkout();
  }

  void _restoreDraft(Map<String, dynamic>? draft) {
    if (draft == null) {
      return;
    }
    _restored = true;
    startedAt = DateTime.tryParse(draft['startedAt']?.toString() ?? '') ??
        DateTime.now();
    exerciseIndex = ((draft['exerciseIndex'] as num?)?.toInt() ?? 0)
        .clamp(0, widget.workout.exercises.length - 1)
        .toInt();
    setIndex = ((draft['setIndex'] as num?)?.toInt() ?? 1).clamp(1, 99).toInt();
    _sessionSets.addAll(_mapList(draft['sets']));
    completedSets = _sessionSets.length;
    weightController.text = draft['weight']?.toString() ?? '';
    repsController.text = draft['reps']?.toString() ?? '';

    final restEndAt = DateTime.tryParse(draft['restEndAt']?.toString() ?? '');
    if (restEndAt != null && restEndAt.isAfter(DateTime.now())) {
      _restEndAt = restEndAt;
      rest =
          restEndAt.difference(DateTime.now()).inSeconds.clamp(1, 3600).toInt();
    }
  }

  Future<void> _prepareWorkout() async {
    await _rebuildRecordsAndPrCount();
    await _prepareCurrentSet(prefill: !_restored);
    if (_restored && weightController.text.isEmpty) {
      await _prepareCurrentSet(prefill: true);
    }
    if (rest > 0) {
      _startRest(existingEnd: _restEndAt);
    }
    await _persistDraft();
    if (mounted && _restored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Workout resumed from your last saved set.'),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _persistDraft();
    }
  }

  Future<void> _persistDraft() async {
    if (widget.workout.exercises.isEmpty) {
      return;
    }
    await LocalStore.saveActiveWorkout(<String, dynamic>{
      'draftVersion': 1,
      'workoutId': widget.workout.id,
      'title': widget.workout.title,
      'subtitle': widget.workout.subtitle,
      'durationMinutes': widget.workout.durationMinutes,
      'exerciseIds': widget.workout.exercises.map((e) => e.id).toList(),
      'exerciseIndex': exerciseIndex,
      'setIndex': setIndex,
      'startedAt': startedAt.toIso8601String(),
      'sets': _sessionSets,
      'weight': weightController.text,
      'reps': repsController.text,
      'restEndAt': _restEndAt?.toIso8601String(),
      if (widget.workout.programSessionKey != null)
        'programSessionKey': widget.workout.programSessionKey,
      if (widget.workout.scheduledDate != null)
        'scheduledDate': widget.workout.scheduledDate,
      if (widget.workout.programWeek != null)
        'programWeek': widget.workout.programWeek,
      'isDeload': widget.workout.isDeload,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _prepareCurrentSet({bool prefill = false}) async {
    if (!mounted || widget.workout.exercises.isEmpty) {
      return;
    }
    final exercise = widget.workout.exercises[exerciseIndex];
    setState(() => _loadingPrevious = true);

    final previous = await LocalStore.latestSetForExercise(
      exercise.id,
      setNumber: setIndex,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _previousSet = previous;
      _loadingPrevious = false;
      if (prefill || previous != null && weightController.text.isEmpty) {
        final suggestedWeight = previous == null
            ? _defaultWeight(exercise)
            : ((previous['weight'] as num?)?.toDouble() ?? 0);
        final adjustedWeight =
            widget.workout.isDeload ? suggestedWeight * .85 : suggestedWeight;
        weightController.text = _formatNumber(adjustedWeight);
        repsController.text = previous == null
            ? _targetReps(exercise).toString()
            : ((previous['reps'] as num?)?.toInt() ?? _targetReps(exercise))
                .toString();
      }
    });
  }

  Future<void> _completeSet() async {
    if (_completingSet) {
      return;
    }

    final exercise = widget.workout.exercises[exerciseIndex];
    final weight = double.tryParse(
      weightController.text.trim().replaceAll(',', '.'),
    );
    final reps = int.tryParse(repsController.text.trim());

    if (weight == null || weight < 0 || reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Enter a valid weight and reps before completing the set.'),
        ),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _completingSet = true);

    final isPr = _isNewRecord(exercise.id, weight, reps);
    final completedAt = DateTime.now();
    final volume = weight * reps;
    final setEntry = <String, dynamic>{
      'exerciseId': exercise.id,
      'exerciseName': exercise.name,
      'muscle': exercise.muscle,
      'setNumber': setIndex,
      'weight': weight,
      'reps': reps,
      'volume': volume,
      'estimated1RM': LocalStore.estimatedOneRepMax(weight, reps),
      'isPR': isPr,
      'completedAt': completedAt.toIso8601String(),
    };

    _sessionSets.add(setEntry);
    _updateRecord(exercise, weight, reps, volume, completedAt);
    if (isPr) {
      AppPreferences.successFeedback();
    } else {
      AppPreferences.selectionFeedback();
    }

    setState(() {
      completedSets = _sessionSets.length;
      if (isPr) {
        _prCount++;
      }
    });

    if (isPr && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '🏆 New ${exercise.name} PR — ${_formatNumber(weight)} KG × $reps',
          ),
        ),
      );
    }

    if (setIndex < _targetSetCount(exercise)) {
      setState(() {
        rest = exercise.restSeconds;
        setIndex++;
      });
      await _prepareCurrentSet();
      _startRest();
      await _persistDraft();
      if (mounted) {
        setState(() => _completingSet = false);
      }
      return;
    }

    if (exerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        exerciseIndex++;
        setIndex = 1;
        rest = 0;
        _restEndAt = null;
        weightController.clear();
        repsController.clear();
      });
      await _prepareCurrentSet(prefill: true);
      await _persistDraft();
      if (mounted) {
        setState(() => _completingSet = false);
      }
    } else {
      await _finishWorkout();
      if (mounted) {
        setState(() => _completingSet = false);
      }
    }
  }

  Future<void> _rebuildRecordsAndPrCount() async {
    final base = await LocalStore.exerciseRecords();
    _records
      ..clear()
      ..addAll(base);
    _prCount = 0;
    final counts = <String, int>{};

    for (final set in _sessionSets) {
      final exerciseId = set['exerciseId']?.toString() ?? '';
      final exercise = _exerciseById(exerciseId);
      if (exercise == null) {
        continue;
      }
      counts[exerciseId] = (counts[exerciseId] ?? 0) + 1;
      set['setNumber'] = counts[exerciseId];
      final weight = (set['weight'] as num?)?.toDouble() ?? 0;
      final reps = (set['reps'] as num?)?.toInt() ?? 0;
      final volume = weight * reps;
      final completedAt =
          DateTime.tryParse(set['completedAt']?.toString() ?? '') ??
              DateTime.now();
      final isPr = _isNewRecord(exerciseId, weight, reps);
      set['volume'] = volume;
      set['estimated1RM'] = LocalStore.estimatedOneRepMax(weight, reps);
      set['isPR'] = isPr;
      if (isPr) {
        _prCount++;
      }
      _updateRecord(exercise, weight, reps, volume, completedAt);
    }
    completedSets = _sessionSets.length;
  }

  Exercise? _exerciseById(String id) {
    for (final exercise in widget.workout.exercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }

  Future<void> _editCompletedSet(int index) async {
    final current = _sessionSets[index];
    final weightController = TextEditingController(
      text: _formatNumber((current['weight'] as num?)?.toDouble() ?? 0),
    );
    final repsController = TextEditingController(
      text: ((current['reps'] as num?)?.toInt() ?? 0).toString(),
    );

    final result = await showModalBottomSheet<Map<String, num>>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit ${current['exerciseName'] ?? 'set'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Weight (KG)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final weight = double.tryParse(
                    weightController.text.trim().replaceAll(',', '.'),
                  );
                  final reps = int.tryParse(repsController.text.trim());
                  if (weight == null ||
                      weight < 0 ||
                      reps == null ||
                      reps <= 0) {
                    return;
                  }
                  Navigator.of(sheetContext).pop(<String, num>{
                    'weight': weight,
                    'reps': reps,
                  });
                },
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );

    weightController.dispose();
    repsController.dispose();
    if (result == null || !mounted) {
      return;
    }

    current['weight'] = result['weight'];
    current['reps'] = result['reps'];
    await _rebuildRecordsAndPrCount();
    await _persistDraft();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteCompletedSet(int index) async {
    final removed = Map<String, dynamic>.from(_sessionSets[index]);
    setState(() => _sessionSets.removeAt(index));
    await _rebuildRecordsAndPrCount();
    await _persistDraft();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Completed set removed.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final safeIndex = index < 0
                ? 0
                : (index > _sessionSets.length ? _sessionSets.length : index);
            _sessionSets.insert(safeIndex, removed);
            await _rebuildRecordsAndPrCount();
            await _persistDraft();
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  bool _isNewRecord(String exerciseId, double weight, int reps) {
    final current = _records[exerciseId];
    if (current == null) {
      return true;
    }
    final bestWeight = (current['bestWeight'] as num?)?.toDouble() ?? 0;
    final bestRepsAtWeight =
        (current['repsAtBestWeight'] as num?)?.toInt() ?? 0;
    if (weight > bestWeight) {
      return true;
    }
    return weight == bestWeight && reps > bestRepsAtWeight;
  }

  void _updateRecord(
    Exercise exercise,
    double weight,
    int reps,
    double volume,
    DateTime completedAt,
  ) {
    final current = _records[exercise.id];
    if (current == null) {
      _records[exercise.id] = <String, dynamic>{
        'exerciseId': exercise.id,
        'exerciseName': exercise.name,
        'muscle': exercise.muscle,
        'bestWeight': weight,
        'repsAtBestWeight': reps,
        'bestSetVolume': volume,
        'bestReps': reps,
        'achievedAt': completedAt.toIso8601String(),
      };
      return;
    }

    final bestWeight = (current['bestWeight'] as num?)?.toDouble() ?? 0;
    final repsAtBest = (current['repsAtBestWeight'] as num?)?.toInt() ?? 0;
    final bestVolume = (current['bestSetVolume'] as num?)?.toDouble() ?? 0;
    final bestReps = (current['bestReps'] as num?)?.toInt() ?? 0;

    if (weight > bestWeight || (weight == bestWeight && reps > repsAtBest)) {
      current['bestWeight'] = weight;
      current['repsAtBestWeight'] = reps;
      current['achievedAt'] = completedAt.toIso8601String();
    }
    if (volume > bestVolume) {
      current['bestSetVolume'] = volume;
    }
    if (reps > bestReps) {
      current['bestReps'] = reps;
    }
  }

  void _startRest({DateTime? existingEnd}) {
    timer?.cancel();
    _restEndAt = existingEnd ?? DateTime.now().add(Duration(seconds: rest));
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        return;
      }
      final remaining = _restEndAt!.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        t.cancel();
        setState(() {
          rest = 0;
          _restEndAt = null;
        });
        _persistDraft();
      } else {
        setState(() => rest = remaining);
      }
    });
  }

  Future<void> _discardWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard workout?'),
        content: const Text(
          'Your completed sets in this unfinished workout will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    timer?.cancel();
    _finishedOrDiscarded = true;
    await LocalStore.clearActiveWorkout();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _finishWorkout() async {
    final duration =
        DateTime.now().difference(startedAt).inMinutes.clamp(1, 999);
    final totalVolume = _sessionSets.fold<double>(
      0,
      (sum, set) => sum + ((set['volume'] as num?)?.toDouble() ?? 0),
    );

    try {
      await LocalStore.addWorkoutHistory({
        'id': 'session_${DateTime.now().microsecondsSinceEpoch}',
        'workoutId': widget.workout.id,
        'title': widget.workout.title,
        'date': DateTime.now().toIso8601String(),
        'durationMinutes': duration,
        'completedSets': completedSets,
        'exerciseCount': widget.workout.exercises.length,
        'totalVolume': totalVolume,
        'prCount': _prCount,
        'sets': _sessionSets,
        if (widget.workout.programSessionKey != null)
          'programSessionKey': widget.workout.programSessionKey,
        if (widget.workout.scheduledDate != null)
          'scheduledDate': widget.workout.scheduledDate,
        if (widget.workout.programWeek != null)
          'programWeek': widget.workout.programWeek,
        'isDeload': widget.workout.isDeload,
      });
      _finishedOrDiscarded = true;
      await LocalStore.clearActiveWorkout();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this workout. Please try again.'),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    AppPreferences.successFeedback();
    FocusManager.instance.primaryFocus?.unfocus();

    final sheetController = AnimationController(
      vsync: this,
      duration: AppMotion.duration(context, AppMotion.modal),
      reverseDuration: AppMotion.duration(context, AppMotion.modalReverse),
    );

    final closeWorkout = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .28),
      transitionAnimationController: sheetController,
      builder: (sheetContext) => _WorkoutSuccessSheet(
        completedSets: completedSets,
        durationMinutes: duration,
        totalVolume: totalVolume,
        prCount: _prCount,
        onDone: () => Navigator.of(sheetContext).pop(true),
      ),
    );

    sheetController.dispose();

    if (closeWorkout == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_finishedOrDiscarded &&
        (_sessionSets.isNotEmpty || weightController.text.isNotEmpty)) {
      _persistDraft();
    }
    timer?.cancel();
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.workout.exercises[exerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Text(
                '${exerciseIndex + 1}/${widget.workout.exercises.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'discard') {
                _discardWorkout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'discard',
                child: Text('Discard workout'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: fitPagePadding(context, bottom: 28),
        children: [
          AnimatedLinearProgress(
            value: (exerciseIndex + 1) / widget.workout.exercises.length,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceAlt,
          ),
          const SizedBox(height: 18),
          if (widget.workout.isDeload) ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.self_improvement_rounded,
                      color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Deload session • one fewer set per exercise and a 15% lighter starting load. Keep every rep controlled and stop well before failure.',
                      style:
                          TextStyle(height: 1.4, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ] else
            const SizedBox(height: 6),
          Container(
            height: 230,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primarySoft,
                  AppColors.secondarySoft.withValues(alpha: .8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.border),
            ),
            child: ExerciseMedia(
              exercise: exercise,
              width: double.infinity,
              height: 230,
              borderRadius: BorderRadius.circular(29),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${exercise.muscle} • ${exercise.equipment}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              _SetBadge(current: setIndex, total: _targetSetCount(exercise)),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration:
                AppMotion.duration(context, const Duration(milliseconds: 260)),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0, .025),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: rest > 0
                ? _RestCard(
                    key: const ValueKey('rest-card'),
                    rest: rest,
                    onSkip: () {
                      timer?.cancel();
                      setState(() {
                        rest = 0;
                        _restEndAt = null;
                      });
                      _persistDraft();
                    },
                    onAdd: () {
                      setState(() {
                        rest += 15;
                        _restEndAt =
                            DateTime.now().add(Duration(seconds: rest));
                      });
                      _persistDraft();
                    },
                  )
                : Column(
                    key: const ValueKey('set-entry'),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _EditableMetric(
                              label: 'WEIGHT',
                              controller: weightController,
                              suffix: 'KG',
                              decimal: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _EditableMetric(
                              label: 'REPS',
                              controller: repsController,
                              suffix: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _PreviousSetCard(
                        loading: _loadingPrevious,
                        previousSet: _previousSet,
                        targetReps: exercise.reps,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 58,
                        child: PressableScale(
                          onTap: _completingSet ? null : _completeSet,
                          borderRadius: BorderRadius.circular(20),
                          pressedScale: .985,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, Color(0xFF6CB000)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: .18),
                                  blurRadius: 18,
                                  offset: const Offset(0, 9),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_completingSet)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  const Icon(Icons.check_rounded,
                                      color: Colors.white),
                                const SizedBox(width: 9),
                                const Text(
                                  'Complete Set',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (_sessionSets.isNotEmpty) ...[
            const SizedBox(height: 24),
            _CompletedSetsPanel(
              sets: _sessionSets,
              onEdit: _editCompletedSet,
              onDelete: _deleteCompletedSet,
            ),
          ],
        ],
      ),
    );
  }

  int _targetSetCount(Exercise exercise) {
    if (!widget.workout.isDeload) {
      return exercise.sets;
    }
    return (exercise.sets - 1).clamp(1, exercise.sets).toInt();
  }

  static double _defaultWeight(Exercise exercise) {
    final equipment = exercise.equipment.toLowerCase();
    if (equipment.contains('barbell')) {
      return 60;
    }
    if (equipment.contains('dumbbell')) {
      return 20;
    }
    if (equipment.contains('cable')) {
      return 30;
    }
    return 0;
  }

  static int _targetReps(Exercise exercise) {
    final match = RegExp(r'\d+').firstMatch(exercise.reps);
    return int.tryParse(match?.group(0) ?? '') ?? 10;
  }

  static String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

class _CompletedSetsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> sets;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  const _CompletedSetsPanel({
    required this.sets,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completed sets',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...List.generate(sets.length, (index) {
            final set = sets[index];
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;
            final reps = (set['reps'] as num?)?.toInt() ?? 0;
            return Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              decoration: BoxDecoration(
                color: set['isPR'] == true
                    ? AppColors.primarySoft
                    : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${set['exerciseName'] ?? 'Exercise'} • Set ${set['setNumber'] ?? index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_formatWeight(weight)} KG × $reps reps'
                          '${set['isPR'] == true ? '  •  PR 🏆' : ''}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit set',
                    onPressed: () => onEdit(index),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
                  IconButton(
                    tooltip: 'Delete set',
                    onPressed: () => onDelete(index),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _WorkoutSuccessSheet extends StatelessWidget {
  final int completedSets;
  final int durationMinutes;
  final double totalVolume;
  final int prCount;
  final VoidCallback onDone;

  const _WorkoutSuccessSheet({
    required this.completedSets,
    required this.durationMinutes,
    required this.totalVolume,
    required this.prCount,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reducedMotion(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: AppMotion.duration(context, AppMotion.success),
        curve: AppMotion.enterCurve,
        builder: (context, value, child) {
          return Opacity(
            opacity: .65 + (.35 * value),
            child: Transform.scale(
              scale: reduceMotion ? 1 : .96 + (.04 * value),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: const Center(
                child: AnimatedCheckBurst(
                  active: true,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Workout complete!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Sets',
                    value: '$completedSets',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Time',
                    value: '$durationMinutes min',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Volume',
                    value: '${totalVolume.round()} kg',
                  ),
                ),
              ],
            ),
            if (prCount > 0) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '🏆 $prCount new personal ${prCount == 1 ? 'record' : 'records'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: onDone,
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SetBadge extends StatelessWidget {
  final int current;
  final int total;

  const _SetBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'SET $current/$total',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _PreviousSetCard extends StatelessWidget {
  final bool loading;
  final Map<String, dynamic>? previousSet;
  final String targetReps;

  const _PreviousSetCard({
    required this.loading,
    required this.previousSet,
    required this.targetReps,
  });

  @override
  Widget build(BuildContext context) {
    String previousText;
    if (loading) {
      previousText = 'Checking your previous performance…';
    } else if (previousSet == null) {
      previousText = 'No previous set saved yet';
    } else {
      final weight = (previousSet!['weight'] as num?)?.toDouble() ?? 0;
      final reps = (previousSet!['reps'] as num?)?.toInt() ?? 0;
      final formatted = weight == weight.roundToDouble()
          ? weight.toInt().toString()
          : weight.toStringAsFixed(1);
      previousText = 'Previous: $formatted KG × $reps reps';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.history_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  previousText,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  'Target: $targetReps reps',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableMetric extends StatelessWidget {
  final String label;
  final String suffix;
  final TextEditingController controller;
  final bool decimal;

  const _EditableMetric({
    required this.label,
    required this.controller,
    required this.suffix,
    this.decimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: decimal),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (suffix.isNotEmpty)
                Text(
                  suffix,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestCard extends StatelessWidget {
  final int rest;
  final VoidCallback onSkip;
  final VoidCallback onAdd;

  const _RestCard({
    super.key,
    required this.rest,
    required this.onSkip,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return BreathingGlow(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: .12),
              AppColors.secondary.withValues(alpha: .10),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: .45)),
        ),
        child: Column(
          children: [
            const Text(
              'REST',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: .94, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 124,
                height: 124,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .70),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .24),
                    width: 7,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .10),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    '${rest ~/ 60}:${(rest % 60).toString().padLeft(2, '0')}',
                    key: ValueKey(rest),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('15 sec'),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(Icons.skip_next_rounded, size: 18),
                  label: const Text('Skip rest'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
