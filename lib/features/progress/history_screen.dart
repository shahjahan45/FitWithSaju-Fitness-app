import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/pro_empty_state.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> data;

  @override
  void initState() {
    super.initState();
    data = LocalStore.history();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: data,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return ProEmptyState(
              icon: Icons.history_rounded,
              title: 'Your training timeline starts here',
              message:
                  'Complete a workout and FitWithSaju will save the session, sets, duration, volume and PRs in this timeline.',
              primaryLabel: 'Go back to Progress',
              onPrimary: () => Navigator.of(context).pop(),
            );
          }

          final totalMinutes = items.fold<int>(
            0,
            (sum, item) =>
                sum + ((item['durationMinutes'] as num?)?.toInt() ?? 0),
          );
          final totalSets = items.fold<int>(
            0,
            (sum, item) =>
                sum + ((item['completedSets'] as num?)?.toInt() ?? 0),
          );
          final totalVolume = items.fold<double>(
            0,
            (sum, item) =>
                sum + ((item['totalVolume'] as num?)?.toDouble() ?? 0),
          );

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            itemCount: items.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _HistorySummary(
                    workouts: items.length,
                    minutes: totalMinutes,
                    sets: totalSets,
                    volume: totalVolume,
                  ),
                );
              }
              final item = items[index - 1];
              final date = DateTime.tryParse(item['date']?.toString() ?? '');
              final volume = (item['totalVolume'] as num?)?.toDouble() ?? 0;
              final prCount = (item['prCount'] as num?)?.toInt() ?? 0;
              final sets = LocalStore.sessionSets(item);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () async {
                      await Navigator.of(context).push(
                        FitRoutes.route(
                          context,
                          motion: FitRouteMotion.detail,
                          builder: (_) => HistoryDetailScreen(session: item),
                        ),
                      );
                      if (mounted) {
                        setState(() => data = LocalStore.history());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.primarySoft,
                            child: Icon(
                              Icons.fitness_center_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title']?.toString() ?? 'Workout',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    if (prCount > 0)
                                      const Icon(
                                        Icons.emoji_events_rounded,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date == null
                                      ? 'Saved workout'
                                      : '${date.day}/${date.month}/${date.year} • ${item['durationMinutes']} min • ${item['completedSets']} sets',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                                if (sets.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    '${volume.round()} kg volume • ${item['exerciseCount']} exercises',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistorySummary extends StatelessWidget {
  final int workouts;
  final int minutes;
  final int sets;
  final double volume;

  const _HistorySummary({
    required this.workouts,
    required this.minutes,
    required this.sets,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        minutes < 60 ? '${minutes}m' : '${minutes ~/ 60}h ${minutes % 60}m';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Training archive',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'A lifetime view of the sessions saved on this device.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: _SummaryMetric(value: '$workouts', label: 'Workouts')),
              Expanded(child: _SummaryMetric(value: time, label: 'Training')),
              Expanded(child: _SummaryMetric(value: '$sets', label: 'Sets')),
              Expanded(
                child: _SummaryMetric(
                  value: '${volume.round()}kg',
                  label: 'Volume',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 10),
        ),
      ],
    );
  }
}
