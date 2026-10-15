import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/fit_card.dart';
import '../nutrition/data/nutrition_store.dart';
import 'data/weekly_review_models.dart';
import 'data/weekly_review_service.dart';

class WeeklyReviewScreen extends StatefulWidget {
  final DateTime? anchorDate;

  const WeeklyReviewScreen({super.key, this.anchorDate});

  @override
  State<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends State<WeeklyReviewScreen> {
  late Future<WeeklyReviewSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = WeeklyReviewService.load(date: widget.anchorDate);
    LocalStore.changes.addListener(_refresh);
    NutritionStore.changes.addListener(_refresh);
  }

  @override
  void dispose() {
    LocalStore.changes.removeListener(_refresh);
    NutritionStore.changes.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) {
      return;
    }
    setState(() => _future = WeeklyReviewService.load(date: widget.anchorDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Review')),
      body: FutureBuilder<WeeklyReviewSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _WeeklyReviewError(onRetry: _refresh);
          }
          final data = snapshot.data!;
          return FitScrollableScreen(
            listKey: const Key('weekly-review-scroll'),
            bottomSpacing: 30,
            children: [
              MotionReveal(child: _ReviewHero(snapshot: data)),
              const SizedBox(height: 18),
              const MotionReveal(
                delay: Duration(milliseconds: 35),
                child: _SectionHeader(
                  title: 'This week so far',
                  subtitle: 'Compared with the same point last week',
                ),
              ),
              const SizedBox(height: 10),
              MotionReveal(
                delay: const Duration(milliseconds: 60),
                child: _MetricGrid(snapshot: data),
              ),
              const SizedBox(height: 14),
              MotionReveal(
                delay: const Duration(milliseconds: 85),
                child: _SupportHabitsCard(snapshot: data),
              ),
              const SizedBox(height: 14),
              MotionReveal(
                delay: const Duration(milliseconds: 110),
                child: _StreakCard(snapshot: data),
              ),
              if (data.current.bestTrainingDay != null) ...[
                const SizedBox(height: 14),
                MotionReveal(
                  delay: const Duration(milliseconds: 135),
                  child: _BestDayCard(snapshot: data),
                ),
              ],
              const SizedBox(height: 14),
              MotionReveal(
                delay: const Duration(milliseconds: 160),
                child: _GuidanceCard(snapshot: data),
              ),
              const SizedBox(height: 12),
              const Text(
                'Weekly Review is fitness and consistency guidance from your locally stored activity. It is not medical or clinical advice and never changes your workouts automatically.',
                key: Key('weekly-review-disclaimer'),
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WeeklyReviewError extends StatelessWidget {
  final VoidCallback onRetry;

  const _WeeklyReviewError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insights_outlined,
              size: 44,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Weekly Review could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your stored fitness data is unchanged. Retry the review safely.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _ReviewHero extends StatelessWidget {
  final WeeklyReviewSnapshot snapshot;

  const _ReviewHero({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reducedMotion(context);
    final progress = snapshot.current.goalProgress;
    final percent = (progress * 100).round();
    return Container(
      key: const Key('weekly-review-hero'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173D25), Color(0xFF2F6B32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: Color(0xFFA5D83F)),
              SizedBox(width: 8),
              Text(
                'WEEK IN REVIEW',
                style: TextStyle(
                  color: Color(0xFFA5D83F),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            snapshot.headline,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_shortDate(snapshot.current.start)} – ${_shortDate(snapshot.current.end)} • Monday to today',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .72),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: reduce ? progress : 0,
                    end: progress,
                  ),
                  duration: reduce ? AppMotion.reduced : AppMotion.chartReveal,
                  curve: AppMotion.indicatorCurve,
                  builder: (context, value, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: .13),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFA5D83F),
                        ),
                      ),
                      Center(
                        child: Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${snapshot.current.goalsMet} of 4 weekly goals met',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${snapshot.currentTrainingWeekStreak}-week active training rhythm',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _shortDate(DateTime date) => '${date.day}/${date.month}';
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.muted)),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final WeeklyReviewSnapshot snapshot;

  const _MetricGrid({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.fitness_center_rounded,
                label: 'Workouts',
                value: '${snapshot.current.workouts}',
                comparison: _deltaLabel(
                  snapshot.workoutDelta,
                  suffix: ' session',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.timer_rounded,
                label: 'Training time',
                value: _minutes(snapshot.current.trainingMinutes),
                comparison: _deltaLabel(
                  snapshot.minuteDelta,
                  suffix: ' min',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.monitor_weight_outlined,
                label: 'Volume',
                value: '${snapshot.current.trainingVolume.round()} kg',
                comparison: _volumeDelta(snapshot.volumeDelta),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.workspace_premium_rounded,
                label: 'PRs',
                value: '${snapshot.current.personalRecords}',
                comparison: '${snapshot.current.completedSets} sets completed',
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _minutes(int value) {
    if (value < 60) {
      return '${value}m';
    }
    final hours = value ~/ 60;
    final rest = value % 60;
    return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
  }

  static String _deltaLabel(int delta, {required String suffix}) {
    if (delta == 0) {
      return 'Same as last week';
    }
    final sign = delta > 0 ? '+' : '';
    final plural = delta.abs() == 1 ? '' : 's';
    return '$sign$delta$suffix$plural vs last week';
  }

  static String _volumeDelta(double delta) {
    if (delta.abs() < .5) {
      return 'Same as last week';
    }
    final sign = delta > 0 ? '+' : '';
    return '$sign${delta.round()} kg vs last week';
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String comparison;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    return FitCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            comparison,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportHabitsCard extends StatelessWidget {
  final WeeklyReviewSnapshot snapshot;

  const _SupportHabitsCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final current = snapshot.current;
    final previous = snapshot.previousComparable;
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recovery & consistency context',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'Support habits recorded from Monday to today',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _HabitRow(
            icon: Icons.water_drop_rounded,
            label: 'Hydration target days',
            value: '${current.hydrationDays}',
            previous: '${previous.hydrationDays} last week',
          ),
          const Divider(height: 22),
          _HabitRow(
            icon: Icons.favorite_outline_rounded,
            label: 'Readiness check-ins',
            value: '${current.readinessDays}',
            previous: '${previous.readinessDays} last week',
          ),
          const Divider(height: 22),
          _HabitRow(
            icon: Icons.speed_rounded,
            label: 'Readiness guidance average',
            value: current.readinessAverage == null
                ? '—'
                : '${current.readinessAverage}',
            previous: previous.readinessAverage == null
                ? 'No comparison'
                : '${previous.readinessAverage} last week',
          ),
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String previous;

  const _HabitRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.previous,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                previous,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final WeeklyReviewSnapshot snapshot;

  const _StreakCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return FitCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.primary,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Training-week consistency',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${snapshot.currentTrainingWeekStreak} consecutive active weeks • best ${snapshot.bestTrainingWeekStreak}',
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

class _BestDayCard extends StatelessWidget {
  final WeeklyReviewSnapshot snapshot;

  const _BestDayCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final data = snapshot.current;
    final date = data.bestTrainingDay!;
    return FitCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.star_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Strongest training day this week',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_weekday(date)} • ${data.bestTrainingDayVolume.round()} kg volume • ${data.bestTrainingDayMinutes} min',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _weekday(DateTime date) {
    const values = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return values[date.weekday - 1];
  }
}

class _GuidanceCard extends StatelessWidget {
  final WeeklyReviewSnapshot snapshot;

  const _GuidanceCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('weekly-review-guidance'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'FITNESS GUIDANCE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.headline,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            snapshot.guidance,
            style: const TextStyle(color: AppColors.text, height: 1.45),
          ),
        ],
      ),
    );
  }
}
