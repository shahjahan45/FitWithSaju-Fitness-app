import 'package:flutter/material.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/pro_empty_state.dart';

class PersonalRecordsScreen extends StatelessWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Records')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([
          LocalStore.history(),
          LocalStore.exerciseRecords(),
        ]),
        builder: (context, snapshot) {
          final history = snapshot.hasData
              ? snapshot.data![0] as List<Map<String, dynamic>>
              : <Map<String, dynamic>>[];
          final records = snapshot.hasData
              ? snapshot.data![1] as Map<String, Map<String, dynamic>>
              : <String, Map<String, dynamic>>{};

          if (history.isEmpty) {
            return ProEmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'Your records are waiting to be earned',
              message:
                  'Complete workouts with saved weight and reps to build exercise PRs, session milestones and lifetime training volume.',
              primaryLabel: 'Back to More',
              onPrimary: () => Navigator.of(context).pop(),
            );
          }

          final longest = history.fold<int>(
            0,
            (max, item) {
              final value = (item['durationMinutes'] as num?)?.toInt() ?? 0;
              return value > max ? value : max;
            },
          );
          final mostSets = history.fold<int>(
            0,
            (max, item) {
              final value = (item['completedSets'] as num?)?.toInt() ?? 0;
              return value > max ? value : max;
            },
          );
          final totalVolume = history.fold<double>(
            0,
            (sum, item) =>
                sum + ((item['totalVolume'] as num?)?.toDouble() ?? 0),
          );
          final recordList = records.values.toList()
            ..sort((a, b) {
              final aw = (a['bestWeight'] as num?)?.toDouble() ?? 0;
              final bw = (b['bestWeight'] as num?)?.toDouble() ?? 0;
              return bw.compareTo(aw);
            });

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              const Text(
                'Training milestones',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _RecordCard(
                icon: Icons.emoji_events_rounded,
                label: 'Completed Workouts',
                value: '${history.length}',
              ),
              const SizedBox(height: 10),
              _RecordCard(
                icon: Icons.timer_rounded,
                label: 'Longest Session',
                value: '$longest min',
              ),
              const SizedBox(height: 10),
              _RecordCard(
                icon: Icons.repeat_rounded,
                label: 'Most Sets in a Session',
                value: '$mostSets sets',
              ),
              const SizedBox(height: 10),
              _RecordCard(
                icon: Icons.monitor_weight_rounded,
                label: 'Lifetime Training Volume',
                value: '${totalVolume.round()} kg',
              ),
              const SizedBox(height: 26),
              const Text(
                'Exercise records',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Best saved weight and reps from completed sets.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              if (recordList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Your older workouts do not contain set-level data. Complete a new workout to create exercise PRs.',
                    style: TextStyle(color: AppColors.muted, height: 1.5),
                  ),
                )
              else
                ...recordList.map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ExerciseRecordCard(record: record),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RecordCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const _ExerciseRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final weight = (record['bestWeight'] as num?)?.toDouble() ?? 0;
    final reps = (record['repsAtBestWeight'] as num?)?.toInt() ?? 0;
    final bestReps = (record['bestReps'] as num?)?.toInt() ?? reps;
    final bestVolume = (record['bestSetVolume'] as num?)?.toDouble() ?? 0;
    final estimatedOneRm = LocalStore.estimatedOneRepMax(weight, reps);

    return Container(
      padding: const EdgeInsets.all(18),
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
              const CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['exerciseName']?.toString() ?? 'Exercise',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if ((record['muscle']?.toString() ?? '').isNotEmpty)
                      Text(
                        record['muscle'].toString(),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${_format(weight)} KG × $reps',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(label: 'Best reps', value: '$bestReps'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetric(
                  label: 'Estimated 1RM',
                  value: '${_format(estimatedOneRm)} kg',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetric(
                  label: 'Best volume',
                  value: '${bestVolume.round()} kg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _format(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
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
