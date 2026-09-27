import 'package:flutter/material.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> session;

  const HistoryDetailScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final sets = LocalStore.sessionSets(session);
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final set in sets) {
      final id = set['exerciseId']?.toString() ?? 'exercise';
      grouped.putIfAbsent(id, () => []).add(set);
    }

    final date = DateTime.tryParse(session['date']?.toString() ?? '');
    final duration = (session['durationMinutes'] as num?)?.toInt() ?? 0;
    final totalVolume = (session['totalVolume'] as num?)?.toDouble() ?? 0;
    final prCount = (session['prCount'] as num?)?.toInt() ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Summary')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            session['title']?.toString() ?? 'Workout',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
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
                  const Icon(Icons.emoji_events_rounded, color: AppColors.primary),
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
          const Text(
            'Exercise breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                'This older session was saved before set-level tracking was introduced.',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
            )
          else
            ...grouped.values.map((exerciseSets) {
              final first = exerciseSets.first;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExerciseSessionCard(
                  name: first['exerciseName']?.toString() ?? 'Exercise',
                  muscle: first['muscle']?.toString() ?? '',
                  sets: exerciseSets,
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
  final List<Map<String, dynamic>> sets;

  const _ExerciseSessionCard({
    required this.name,
    required this.muscle,
    required this.sets,
  });

  @override
  Widget build(BuildContext context) {
    final volume = sets.fold<double>(
      0,
      (sum, set) => sum + ((set['volume'] as num?)?.toDouble() ?? 0),
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
          const Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  'SET',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'WEIGHT',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'REPS',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 6),
          ...sets.map((set) {
            final number = (set['setNumber'] as num?)?.toInt() ?? 0;
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;
            final reps = (set['reps'] as num?)?.toInt() ?? 0;
            final isPr = set['isPR'] == true;
            return Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: isPr ? AppColors.primarySoft : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Text(
                      '$number',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_formatWeight(weight)} KG',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$reps',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    child: isPr
                        ? const Icon(
                            Icons.emoji_events_rounded,
                            color: AppColors.primary,
                            size: 19,
                          )
                        : null,
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
