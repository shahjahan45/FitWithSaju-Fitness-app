import 'package:flutter/material.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ValueListenableBuilder<int>(
        valueListenable: LocalStore.changes,
        builder: (context, _, __) => FutureBuilder<List<dynamic>>(
          future: Future.wait<dynamic>([
            LocalStore.history(),
            LocalStore.favorites(),
            LocalStore.weightEntries(),
            LocalStore.exerciseRecords(),
            LocalStore.totalTrainingVolume(),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final history = snapshot.data![0] as List<Map<String, dynamic>>;
            final favorites = snapshot.data![1] as Set<String>;
            final weights = snapshot.data![2] as List<Map<String, dynamic>>;
            final records =
                snapshot.data![3] as Map<String, Map<String, dynamic>>;
            final totalVolume = snapshot.data![4] as double;

            final totalSets = history.fold<int>(
              0,
              (sum, item) =>
                  sum + ((item['completedSets'] as num?)?.toInt() ?? 0),
            );
            final streak = _streak(history);

            final items = <_Achievement>[
              _Achievement(
                icon: Icons.flag_rounded,
                title: 'First session',
                subtitle: 'Complete your first FitWithSaju workout.',
                value: history.length.toDouble(),
                target: 1,
              ),
              _Achievement(
                icon: Icons.fitness_center_rounded,
                title: 'Building momentum',
                subtitle: 'Complete 5 workouts.',
                value: history.length.toDouble(),
                target: 5,
              ),
              _Achievement(
                icon: Icons.workspace_premium_rounded,
                title: 'Committed',
                subtitle: 'Complete 20 workouts.',
                value: history.length.toDouble(),
                target: 20,
              ),
              _Achievement(
                icon: Icons.local_fire_department_rounded,
                title: 'Seven-day rhythm',
                subtitle: 'Reach a 7-day workout streak.',
                value: streak.toDouble(),
                target: 7,
              ),
              _Achievement(
                icon: Icons.repeat_rounded,
                title: 'Set collector',
                subtitle: 'Complete 100 training sets.',
                value: totalSets.toDouble(),
                target: 100,
              ),
              _Achievement(
                icon: Icons.monitor_weight_rounded,
                title: 'Volume builder',
                subtitle: 'Move 10,000 kg of total training volume.',
                value: totalVolume,
                target: 10000,
                suffix: 'kg',
              ),
              _Achievement(
                icon: Icons.emoji_events_rounded,
                title: 'Record breaker',
                subtitle: 'Establish records in 5 exercises.',
                value: records.length.toDouble(),
                target: 5,
              ),
              _Achievement(
                icon: Icons.favorite_rounded,
                title: 'Exercise shortlist',
                subtitle: 'Save 5 favorite exercises.',
                value: favorites.length.toDouble(),
                target: 5,
              ),
              _Achievement(
                icon: Icons.scale_rounded,
                title: 'Tracking started',
                subtitle: 'Add your first body-weight entry.',
                value: weights.length.toDouble(),
                target: 1,
              ),
            ];

            final unlocked = items.where((item) => item.unlocked).length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _SummaryCard(unlocked: unlocked, total: items.length),
                const SizedBox(height: 24),
                const Text(
                  'Your milestones',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Achievements unlock automatically from your real local training data.',
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 14),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _AchievementCard(item: item),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static int _streak(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return 0;
    final days = items
        .map((e) => DateTime.tryParse(e['date']?.toString() ?? ''))
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var result = 0;
    while (days.contains(cursor)) {
      result++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return result;
  }
}

class _SummaryCard extends StatelessWidget {
  final int unlocked;
  final int total;

  const _SummaryCard({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173D25), Color(0xFF255F2B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Color(0xFFA5D83F)),
              SizedBox(width: 9),
              Text(
                'MILESTONE PROGRESS',
                style: TextStyle(
                  color: Color(0xFFA5D83F),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$unlocked of $total unlocked',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            unlocked == total
                ? 'Every current achievement is complete. Keep building your next chapter.'
                : 'Keep showing up. Progress here comes directly from the work you log.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .78),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: .14),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFA5D83F)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final _Achievement item;

  const _AchievementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final unlocked = item.unlocked;
    final progress = item.progress;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked
              ? AppColors.primary.withValues(alpha: .38)
              : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: unlocked ? AppColors.primarySoft : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              unlocked ? item.icon : Icons.lock_outline_rounded,
              color: unlocked ? AppColors.primary : AppColors.muted,
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
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      unlocked ? 'UNLOCKED' : item.progressLabel,
                      style: TextStyle(
                        color: unlocked ? AppColors.primary : AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 11),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation(
                      unlocked ? AppColors.primary : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final double target;
  final String? suffix;

  const _Achievement({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.target,
    this.suffix,
  });

  bool get unlocked => value >= target;
  double get progress =>
      target <= 0 ? 1.0 : (value / target).clamp(0.0, 1.0).toDouble();

  String get progressLabel {
    final current = value >= target ? target : value;
    final currentText = current == current.roundToDouble()
        ? current.toInt().toString()
        : current.toStringAsFixed(1);
    final targetText = target == target.roundToDouble()
        ? target.toInt().toString()
        : target.toStringAsFixed(1);
    final unit = suffix == null ? '' : ' $suffix';
    return '$currentText / $targetText$unit';
  }
}
