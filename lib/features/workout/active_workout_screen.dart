import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with SingleTickerProviderStateMixin {
  int exerciseIndex = 0;
  int setIndex = 1;
  int rest = 0;
  int completedSets = 0;
  Timer? timer;
  late DateTime startedAt;

  final weightController = TextEditingController();
  final repsController = TextEditingController();
  final List<Map<String, dynamic>> _sessionSets = [];
  final Map<String, Map<String, dynamic>> _records = {};

  Map<String, dynamic>? _previousSet;
  bool _loadingPrevious = true;
  bool _completingSet = false;
  int _prCount = 0;

  @override
  void initState() {
    super.initState();
    startedAt = DateTime.now();
    _prepareWorkout();
  }

  Future<void> _prepareWorkout() async {
    final records = await LocalStore.exerciseRecords();
    _records
      ..clear()
      ..addAll(records);
    await _prepareCurrentSet(prefill: true);
  }

  Future<void> _prepareCurrentSet({bool prefill = false}) async {
    if (!mounted) {
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
      if (prefill || previous != null) {
        weightController.text = previous == null
            ? _defaultWeight(exercise).toStringAsFixed(0)
            : _formatNumber((previous['weight'] as num?)?.toDouble() ?? 0);
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
    final weight = double.tryParse(weightController.text.trim().replaceAll(',', '.'));
    final reps = int.tryParse(repsController.text.trim());

    if (weight == null || weight < 0 || reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid weight and reps before completing the set.'),
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
      'isPR': isPr,
      'completedAt': completedAt.toIso8601String(),
    };

    _sessionSets.add(setEntry);
    _updateRecord(exercise, weight, reps, volume, completedAt);

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

    if (setIndex < exercise.sets) {
      setState(() {
        rest = exercise.restSeconds;
        setIndex++;
      });
      await _prepareCurrentSet();
      _startRest();
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
      });
      await _prepareCurrentSet(prefill: true);
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

  void _startRest() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        return;
      }
      if (rest <= 1) {
        t.cancel();
        setState(() => rest = 0);
      } else {
        setState(() => rest--);
      }
    });
  }

  Future<void> _finishWorkout() async {
    final duration = DateTime.now().difference(startedAt).inMinutes.clamp(1, 999);
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
      });
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
            padding: const EdgeInsets.only(right: 16),
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
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (exerciseIndex + 1) / widget.workout.exercises.length,
              minHeight: 8,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceAlt,
            ),
          ),
          const SizedBox(height: 24),
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
            child: Center(
              child: Image.asset(
                'assets/images/fitwithsaju_logo.png',
                width: 190,
              ),
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
              _SetBadge(current: setIndex, total: exercise.sets),
            ],
          ),
          const SizedBox(height: 20),
          if (rest > 0)
            _RestCard(
              rest: rest,
              onSkip: () {
                timer?.cancel();
                setState(() => rest = 0);
              },
              onAdd: () => setState(() => rest += 15),
            )
          else ...[
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
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _completingSet ? null : _completeSet,
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Complete Set',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
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
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 46,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  keyboardType: TextInputType.numberWithOptions(decimal: decimal),
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
    required this.rest,
    required this.onSkip,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: .12),
            AppColors.secondary.withValues(alpha: .10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary),
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
          const SizedBox(height: 6),
          Text(
            '${rest ~/ 60}:${(rest % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: onAdd, child: const Text('+15 sec')),
              const SizedBox(width: 14),
              TextButton(onPressed: onSkip, child: const Text('Skip rest')),
            ],
          ),
        ],
      ),
    );
  }
}
