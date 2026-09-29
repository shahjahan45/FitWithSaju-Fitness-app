import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/workout_program_catalog.dart';
import '../workout/active_program_screen.dart';
import '../more/achievements_screen.dart';
import 'history_screen.dart';
import 'weight_tracker_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStore.changes,
      builder: (context, _, __) => FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([
          LocalStore.history(),
          LocalStore.weightEntries(),
          LocalStore.activeProgram(),
        ]),
        builder: (context, snapshot) {
          final history = snapshot.hasData
              ? snapshot.data![0] as List<Map<String, dynamic>>
              : <Map<String, dynamic>>[];
          final weights = snapshot.hasData
              ? snapshot.data![1] as List<Map<String, dynamic>>
              : <Map<String, dynamic>>[];
          final activeProgram = snapshot.hasData
              ? snapshot.data![2] as Map<String, dynamic>?
              : null;
          return _ProgressContent(
            history: history,
            weights: weights,
            activeProgram: activeProgram,
          );
        },
      ),
    );
  }
}

class _ProgressContent extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final List<Map<String, dynamic>> weights;
  final Map<String, dynamic>? activeProgram;

  const _ProgressContent({
    required this.history,
    required this.weights,
    required this.activeProgram,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final thisWeek = history.where((item) {
      final date = DateTime.tryParse(item['date']?.toString() ?? '');
      return date != null && !date.isBefore(start);
    }).toList();
    final minutes = thisWeek.fold<int>(
      0,
      (sum, item) => sum + ((item['durationMinutes'] as num?)?.toInt() ?? 0),
    );
    final sets = thisWeek.fold<int>(
      0,
      (sum, item) => sum + ((item['completedSets'] as num?)?.toInt() ?? 0),
    );
    final weeklyVolume = thisWeek.fold<double>(
      0,
      (sum, item) => sum + ((item['totalVolume'] as num?)?.toDouble() ?? 0),
    );
    final streak = _streak(history);

    return SafeArea(
      child: ListView(
        key: const PageStorageKey('progress-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const MotionReveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text(
                  'Consistency is your strongest metric.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (activeProgram != null) ...[
            _ProgramProgressCard(
              activeProgram: activeProgram!,
              history: history,
            ),
            const SizedBox(height: 16),
          ],
          MotionReveal(
            delay: const Duration(milliseconds: 55),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text(
                    'THIS WEEK',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  Spacer(),
                  Text('Mon – Sun',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              MotionReveal(
                delay: const Duration(milliseconds: 90),
                child: _StatCard(
                  label: 'Workouts this week',
                  value: '${thisWeek.length}',
                  icon: Icons.bolt_rounded,
                ),
              ),
              MotionReveal(
                delay: const Duration(milliseconds: 125),
                child: _StatCard(
                  label: 'Training this week',
                  value: _formatMinutes(minutes),
                  icon: Icons.timer_rounded,
                ),
              ),
              MotionReveal(
                delay: const Duration(milliseconds: 160),
                child: _StatCard(
                  label: 'Sets this week',
                  value: '$sets',
                  icon: Icons.repeat_rounded,
                ),
              ),
              MotionReveal(
                delay: const Duration(milliseconds: 195),
                child: _StatCard(
                  label: 'Current streak',
                  value: '$streak days',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly activity',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Training minutes by day',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: _WeeklyBars(history: history),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Training volume',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Text(
                      '${weeklyVolume.round()} kg this week',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Total weight × reps completed each day',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 130,
                  child: _WeeklyVolumeBars(history: history),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FitCard(
            onTap: () => Navigator.of(context).push(
              FitRoutes.route(
                context,
                motion: FitRouteMotion.detail,
                builder: (_) => const HistoryScreen(),
              ),
            ),
            child: const _LinkRow(
              icon: Icons.history_rounded,
              title: 'Workout history',
              subtitle: 'Review your completed sessions',
            ),
          ),
          const SizedBox(height: 12),
          FitCard(
            onTap: () => Navigator.of(context).push(
              FitRoutes.route(
                context,
                motion: FitRouteMotion.detail,
                builder: (_) => const WeightTrackerScreen(),
              ),
            ),
            child: _LinkRow(
              icon: Icons.monitor_weight_rounded,
              title: 'Body weight',
              subtitle: weights.isEmpty
                  ? 'Add your first weight entry'
                  : 'Latest: ${(weights.first['value'] as num).toStringAsFixed(1)} KG',
            ),
          ),
          const SizedBox(height: 12),
          FitCard(
            onTap: () => Navigator.of(context).push(
              FitRoutes.route(
                context,
                motion: FitRouteMotion.detail,
                builder: (_) => const AchievementsScreen(),
              ),
            ),
            child: const _LinkRow(
              icon: Icons.workspace_premium_rounded,
              title: 'Achievements',
              subtitle: 'Track milestones unlocked from your real activity',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Keep showing up',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
  }

  static int _streak(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return 0;
    }
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

class _WeeklyBars extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _WeeklyBars({required this.history});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final values = List<int>.filled(7, 0);
    for (final item in history) {
      final date = DateTime.tryParse(item['date']?.toString() ?? '');
      if (date == null || date.isBefore(start)) {
        continue;
      }
      final diff =
          DateTime(date.year, date.month, date.day).difference(start).inDays;
      if (diff >= 0 && diff < 7) {
        values[diff] += (item['durationMinutes'] as num?)?.toInt() ?? 0;
      }
    }
    final maxValue =
        values.fold<int>(1, (max, value) => value > max ? value : max);
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final normalized = values[index] / maxValue;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  values[index] == 0 ? '' : '${values[index]}',
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                AnimatedVerticalBar(
                  height: 18 + (95 * normalized),
                  duration: Duration(milliseconds: 520 + (index * 55)),
                  decoration: BoxDecoration(
                    color: index == DateTime.now().weekday - 1
                        ? const Color(0xFF2F6B32)
                        : AppColors.primary.withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _WeeklyVolumeBars extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const _WeeklyVolumeBars({required this.history});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final values = List<double>.filled(7, 0);

    for (final item in history) {
      final date = DateTime.tryParse(item['date']?.toString() ?? '');
      if (date == null || date.isBefore(start)) {
        continue;
      }
      final diff =
          DateTime(date.year, date.month, date.day).difference(start).inDays;
      if (diff >= 0 && diff < 7) {
        values[diff] += (item['totalVolume'] as num?)?.toDouble() ?? 0;
      }
    }

    final maxValue = values.fold<double>(
      1,
      (max, value) => value > max ? value : max,
    );
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final normalized = values[index] / maxValue;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  values[index] == 0 ? '' : '${values[index].round()}',
                  style: const TextStyle(fontSize: 9, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                AnimatedVerticalBar(
                  height: 14 + (78 * normalized),
                  duration: Duration(milliseconds: 560 + (index * 55)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.primary,
                        AppColors.secondary.withValues(alpha: .65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LinkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      ],
    );
  }
}

class _ProgramProgressCard extends StatelessWidget {
  final Map<String, dynamic> activeProgram;
  final List<Map<String, dynamic>> history;

  const _ProgramProgressCard({
    required this.activeProgram,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final progress = WorkoutProgramProgress.calculate(
      activeProgram: activeProgram,
      history: history,
    );
    return MotionReveal(
      delay: const Duration(milliseconds: 40),
      child: FitCard(
        onTap: () => Navigator.of(context).push(
          FitRoutes.route(
            context,
            motion: FitRouteMotion.detail,
            builder: (_) => const ActiveProgramScreen(),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress.completion,
                    strokeWidth: 6,
                    backgroundColor: AppColors.surfaceAlt,
                    color: AppColors.primary,
                  ),
                  Text(
                    '${(progress.completion * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACTIVE PROGRAM',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    activeProgram['name']?.toString() ?? 'Workout Program',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Week ${progress.currentWeek}/${progress.durationWeeks} • ${progress.completedSessions}/${progress.totalSessions} sessions',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
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
