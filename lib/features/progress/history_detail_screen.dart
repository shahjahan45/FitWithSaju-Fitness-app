import 'package:flutter/material.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';

class HistoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> session;

  const HistoryDetailScreen({
    super.key,
    required this.session,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late Map<String, dynamic> _session;

  @override
  void initState() {
    super.initState();
    _session = Map<String, dynamic>.from(widget.session);
  }

  Future<void> _refresh() async {
    final id = _session['id']?.toString();
    if (id == null || id.isEmpty) {
      return;
    }
    final fresh = await LocalStore.historySessionById(id);
    if (fresh != null && mounted) {
      setState(() => _session = fresh);
    }
  }

  Future<void> _persistSets(List<Map<String, dynamic>> sets) async {
    final id = _session['id']?.toString();
    if (id == null || id.isEmpty) {
      return;
    }
    final updated = Map<String, dynamic>.from(_session)..['sets'] = sets;
    await LocalStore.replaceHistorySession(id, updated);
    await LocalStore.normalizeWorkoutHistory();
    await _refresh();
  }

  Future<void> _editSet(int index) async {
    final sets = LocalStore.sessionSets(_session);
    if (index < 0 || index >= sets.length) {
      return;
    }
    final set = sets[index];
    final weightController = TextEditingController(
      text: _formatWeight((set['weight'] as num?)?.toDouble() ?? 0),
    );
    final repsController = TextEditingController(
      text: ((set['reps'] as num?)?.toInt() ?? 0).toString(),
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
              'Edit ${set['exerciseName'] ?? 'set'}',
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
    if (result == null) {
      return;
    }
    set['weight'] = result['weight'];
    set['reps'] = result['reps'];
    set['volume'] = (result['weight'] ?? 0) * (result['reps'] ?? 0);
    set['estimated1RM'] = LocalStore.estimatedOneRepMax(
      (result['weight'] ?? 0).toDouble(),
      (result['reps'] ?? 0).toInt(),
    );
    await _persistSets(sets);
  }

  Future<void> _deleteSet(int index) async {
    final sets = LocalStore.sessionSets(_session);
    if (index < 0 || index >= sets.length) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this set?'),
        content: const Text(
          'Workout volume and personal-record calculations will be updated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    sets.removeAt(index);
    await _persistSets(sets);
  }

  @override
  Widget build(BuildContext context) {
    final sets = LocalStore.sessionSets(_session);
    final grouped = <String, List<_IndexedSet>>{};
    for (var index = 0; index < sets.length; index++) {
      final set = sets[index];
      final id = set['exerciseId']?.toString() ?? 'exercise';
      grouped.putIfAbsent(id, () => []).add(_IndexedSet(index, set));
    }

    final date = DateTime.tryParse(_session['date']?.toString() ?? '');
    final duration = (_session['durationMinutes'] as num?)?.toInt() ?? 0;
    final totalVolume = (_session['totalVolume'] as num?)?.toDouble() ?? 0;
    final prCount = (_session['prCount'] as num?)?.toInt() ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Summary')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            _session['title']?.toString() ?? 'Workout',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            date == null
                ? 'Saved session'
                : '${_month(date.month)} ${date.day}, ${date.year}',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Time',
                  value: '$duration min',
                  icon: Icons.timer_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  label: 'Sets',
                  value: '${sets.length}',
                  icon: Icons.repeat_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  label: 'Volume',
                  value: '${totalVolume.round()} kg',
                  icon: Icons.monitor_weight_rounded,
                ),
              ),
            ],
          ),
          if (prCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$prCount personal ${prCount == 1 ? 'record' : 'records'} achieved in this workout',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Exercise breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              if (sets.isNotEmpty)
                const Text(
                  'Tap ⋮ to edit',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (grouped.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'This older session was saved before set-level tracking was introduced, or all tracked sets were removed.',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
            )
          else
            ...grouped.values.map((exerciseSets) {
              final first = exerciseSets.first.set;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExerciseSessionCard(
                  name: first['exerciseName']?.toString() ?? 'Exercise',
                  muscle: first['muscle']?.toString() ?? '',
                  sets: exerciseSets,
                  onEdit: _editSet,
                  onDelete: _deleteSet,
                ),
              );
            }),
        ],
      ),
    );
  }

  static String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _IndexedSet {
  final int index;
  final Map<String, dynamic> set;
  const _IndexedSet(this.index, this.set);
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSessionCard extends StatelessWidget {
  final String name;
  final String muscle;
  final List<_IndexedSet> sets;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  const _ExerciseSessionCard({
    required this.name,
    required this.muscle,
    required this.sets,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final volume = sets.fold<double>(
      0,
      (sum, item) => sum + ((item.set['volume'] as num?)?.toDouble() ?? 0),
    );

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (muscle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        muscle,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${volume.round()} kg vol.',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...sets.map((item) {
            final set = item.set;
            final number = (set['setNumber'] as num?)?.toInt() ?? 0;
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;
            final reps = (set['reps'] as num?)?.toInt() ?? 0;
            final isPr = set['isPR'] == true;
            final oneRm = (set['estimated1RM'] as num?)?.toDouble() ??
                LocalStore.estimatedOneRepMax(weight, reps);
            return Container(
              margin: const EdgeInsets.only(top: 7),
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                color: isPr ? AppColors.primarySoft : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      '$number',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_HistoryDetailScreenState._formatWeight(weight)} KG × $reps',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Est. 1RM ${_HistoryDetailScreenState._formatWeight(oneRm)} KG'
                          '${isPr ? ' • PR' : ''}',
                          style: TextStyle(
                            color: isPr ? AppColors.primary : AppColors.muted,
                            fontSize: 10,
                            fontWeight:
                                isPr ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit(item.index);
                      } else if (value == 'delete') {
                        onDelete(item.index);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit set')),
                      PopupMenuItem(value: 'delete', child: Text('Delete set')),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
