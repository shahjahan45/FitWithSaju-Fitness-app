import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/fit_card.dart';
import '../nutrition/data/nutrition_store.dart';
import 'data/readiness_models.dart';
import 'data/recovery_insights_models.dart';
import 'data/recovery_insights_service.dart';
import 'training_balance_summary_card.dart';

class RecoveryInsightsScreen extends StatefulWidget {
  final DateTime? anchorDate;

  const RecoveryInsightsScreen({super.key, this.anchorDate});

  @override
  State<RecoveryInsightsScreen> createState() => _RecoveryInsightsScreenState();
}

class _RecoveryInsightsScreenState extends State<RecoveryInsightsScreen> {
  int _reloadToken = 0;

  void _retry() => setState(() => _reloadToken++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Insights')),
      body: AnimatedBuilder(
        animation:
            Listenable.merge([LocalStore.changes, NutritionStore.changes]),
        builder: (context, _) {
          final token = _reloadToken;
          return FutureBuilder<RecoveryInsights>(
            key: ValueKey(token),
            future: RecoveryInsightsService.load(date: widget.anchorDate),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _InsightsLoadError(onRetry: _retry);
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return _InsightsContent(data: snapshot.data!);
            },
          );
        },
      ),
    );
  }
}

class _InsightsLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _InsightsLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FitCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.insights_outlined,
                  size: 34,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Recovery insights are temporarily unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your local data is safe. FitWithSaju will not show a crash screen when an older or partial record cannot be read.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  final RecoveryInsights data;

  const _InsightsContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return FitScrollableScreen(
      listKey: const Key('recovery-insights-scroll'),
      topPadding: 10,
      bottomSpacing: 30,
      children: [
        const MotionReveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your recovery pattern',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 6),
              Text(
                'A 28-day fitness guidance view built from your saved check-ins and training history.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        MotionReveal(
          delay: const Duration(milliseconds: 45),
          child: _OverviewCard(data: data),
        ),
        const SizedBox(height: 16),
        MotionReveal(
          delay: const Duration(milliseconds: 70),
          child: _WeeklyRecoveryReviewCard(data: data),
        ),
        const SizedBox(height: 12),
        const MotionReveal(
          delay: Duration(milliseconds: 85),
          child: TrainingBalanceSummaryCard(
            eyebrow: 'TRAINING LOAD CONTEXT',
          ),
        ),
        const SizedBox(height: 16),
        MotionReveal(
          delay: const Duration(milliseconds: 105),
          child: _ReadinessChartCard(data: data),
        ),
        const SizedBox(height: 16),
        MotionReveal(
          delay: const Duration(milliseconds: 125),
          child: _SignalsCard(data: data),
        ),
        const SizedBox(height: 16),
        MotionReveal(
          delay: const Duration(milliseconds: 155),
          child: _TrainingContextCard(data: data),
        ),
        const SizedBox(height: 16),
        MotionReveal(
          delay: const Duration(milliseconds: 185),
          child: _ObservationsCard(data: data),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final RecoveryInsights data;

  const _OverviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final delta = data.trendDelta;
    final trendValue = delta == null ? '—' : '${delta > 0 ? '+' : ''}$delta';
    return Container(
      key: const Key('recovery-insights-overview'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F8E5)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: .24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
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
                    const Text(
                      '28-DAY READINESS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.checkInDays == 0
                          ? 'No baseline yet'
                          : data.trendLabel,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.consistencyLabel,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.checkInDays == 0 ? '—' : '${data.averageScore}',
                      style: const TextStyle(
                          fontSize: 23, fontWeight: FontWeight.w900),
                    ),
                    const Text(
                      'AVG',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _OverviewMetric(
                  label: 'Check-ins',
                  value: '${data.checkInDays}/28',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewMetric(
                  label: '7-day trend',
                  value: trendValue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewMetric(
                  label: 'This week',
                  value: data.last7Average?.toString() ?? '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Readiness is fitness/recovery guidance only. It is not a medical or clinical score.',
            style:
                TextStyle(fontSize: 10.5, color: AppColors.muted, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRecoveryReviewCard extends StatelessWidget {
  final RecoveryInsights data;

  const _WeeklyRecoveryReviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final volumeRatio = data.weeklyVolumeRatio;
    final volumeContext = volumeRatio == null
        ? 'Building load comparison'
        : '${((volumeRatio - 1) * 100).abs().round()}% ${volumeRatio >= 1 ? 'more' : 'less'} volume vs last week';
    final checkInsThisWeek = data.history.where((point) {
      final start = data.anchorDate.subtract(const Duration(days: 6));
      return !point.date.isBefore(start) &&
          !point.date.isAfter(data.anchorDate);
    }).length;

    return FitCard(
      key: const Key('weekly-recovery-review-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                foregroundColor: AppColors.primary,
                child: Icon(Icons.calendar_view_week_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WEEKLY RECOVERY REVIEW',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.weeklyReviewLabel,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _WeeklyReviewMetric(
                label: 'Readiness',
                value: data.last7Average?.toString() ?? '—',
                subtitle: data.previous7Average == null
                    ? 'No prior baseline'
                    : 'Prior ${data.previous7Average}',
              ),
              _WeeklyReviewMetric(
                label: 'Check-ins',
                value: '$checkInsThisWeek/7',
                subtitle: 'This week',
              ),
              _WeeklyReviewMetric(
                label: 'Training',
                value: '${data.last7Workouts}',
                subtitle: data.last7Workouts == 1 ? 'Workout' : 'Workouts',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.monitor_heart_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '${data.last7Volume.round()} kg • $volumeContext. Review the pattern, then decide how you want to train; FitWithSaju does not change sessions automatically.',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11.5,
                      height: 1.4,
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

class _WeeklyReviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const _WeeklyReviewMetric({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 8.5),
          ),
        ],
      ),
    );
  }
}

class _ReadinessChartCard extends StatelessWidget {
  final RecoveryInsights data;

  const _ReadinessChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart_rounded, color: AppColors.primary),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  '28-day readiness trend',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Only dates with saved check-ins are plotted.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          if (data.history.isEmpty)
            const SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  'Complete daily check-ins to build your trend.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else
            _AnimatedReadinessChart(data: data),
        ],
      ),
    );
  }
}

class _AnimatedReadinessChart extends StatelessWidget {
  final RecoveryInsights data;

  const _AnimatedReadinessChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reducedMotion(context);
    return SizedBox(
      key: const Key('recovery-insights-chart'),
      height: 175,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: reduce ? 1 : 0, end: 1),
        duration: reduce ? Duration.zero : AppMotion.chartReveal,
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) => CustomPaint(
          painter: _ReadinessChartPainter(
            anchor: data.anchorDate,
            history: data.history,
            progress: progress,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ReadinessChartPainter extends CustomPainter {
  final DateTime anchor;
  final List<ReadinessHistoryPoint> history;
  final double progress;

  _ReadinessChartPainter({
    required this.anchor,
    required this.history,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 4.0;
    const right = 4.0;
    const top = 8.0;
    const bottom = 24.0;
    final chartWidth = math.max(1.0, size.width - left - right).toDouble();
    final chartHeight = math.max(1.0, size.height - top - bottom).toDouble();

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: .8)
      ..strokeWidth = 1;
    for (final level in <double>[.25, .5, .75, 1]) {
      final y = top + chartHeight * (1 - level);
      canvas.drawLine(
          Offset(left, y), Offset(size.width - right, y), gridPaint);
    }

    if (history.isEmpty) {
      return;
    }

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: .10)
      ..style = PaintingStyle.fill;
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    final fill = Path();
    final offsets = <Offset>[];
    for (final point in history) {
      final day = DateTime(point.date.year, point.date.month, point.date.day);
      final dayIndex =
          day.difference(anchor.subtract(const Duration(days: 27))).inDays;
      if (dayIndex < 0 || dayIndex > 27) {
        continue;
      }
      final x = left + chartWidth * (dayIndex / 27);
      final normalized = (point.score / 100).clamp(0.0, 1.0).toDouble();
      final y = top + chartHeight * (1 - normalized * progress);
      offsets.add(Offset(x, y));
    }
    if (offsets.isEmpty) {
      return;
    }

    path.moveTo(offsets.first.dx, offsets.first.dy);
    for (var index = 1; index < offsets.length; index++) {
      path.lineTo(offsets[index].dx, offsets[index].dy);
    }
    fill
      ..moveTo(offsets.first.dx, top + chartHeight)
      ..lineTo(offsets.first.dx, offsets.first.dy);
    for (var index = 1; index < offsets.length; index++) {
      fill.lineTo(offsets[index].dx, offsets[index].dy);
    }
    fill
      ..lineTo(offsets.last.dx, top + chartHeight)
      ..close();

    if (offsets.length > 1) {
      canvas.drawPath(fill, fillPaint);
      canvas.drawPath(path, linePaint);
    }
    for (final offset in offsets) {
      canvas.drawCircle(offset, 4, pointPaint);
      canvas.drawCircle(
        offset,
        6.5,
        Paint()
          ..color = AppColors.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final textStyle = const TextStyle(fontSize: 9, color: AppColors.muted);
    _paintLabel(canvas, '28d ago', Offset(left, size.height - 14), textStyle);
    _paintLabel(
      canvas,
      'Today',
      Offset(size.width - right - 24, size.height - 14),
      textStyle,
    );
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ReadinessChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.history != history ||
        oldDelegate.anchor != anchor;
  }
}

class _SignalsCard extends StatelessWidget {
  final RecoveryInsights data;

  const _SignalsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasData = data.checkInDays > 0;
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recovery signal averages',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 4),
          const Text(
            'Average of your saved 1–5 check-in ratings over the last 28 days.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.1,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              _SignalAverage(
                icon: Icons.bedtime_outlined,
                label: 'Sleep',
                value: hasData ? data.averageSleep : null,
                positive: true,
              ),
              _SignalAverage(
                icon: Icons.bolt_rounded,
                label: 'Energy',
                value: hasData ? data.averageEnergy : null,
                positive: true,
              ),
              _SignalAverage(
                icon: Icons.accessibility_new_rounded,
                label: 'Soreness',
                value: hasData ? data.averageSoreness : null,
                positive: false,
              ),
              _SignalAverage(
                icon: Icons.psychology_alt_outlined,
                label: 'Stress',
                value: hasData ? data.averageStress : null,
                positive: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignalAverage extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? value;
  final bool positive;

  const _SignalAverage({
    required this.icon,
    required this.label,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final score = value;
    final normalized = score == null
        ? 0.0
        : positive
            ? ((score - 1) / 4).clamp(0.0, 1.0).toDouble()
            : ((5 - score) / 4).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  score == null ? '—' : '${score.toStringAsFixed(1)} / 5',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: normalized,
                  minHeight: 4,
                  backgroundColor: AppColors.border,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingContextCard extends StatelessWidget {
  final RecoveryInsights data;

  const _TrainingContextCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final ratio = data.trainingVolumeRatio;
    final comparison = ratio == null
        ? 'Not enough previous 28-day volume for a direct comparison.'
        : '${((ratio - 1) * 100).abs().round()}% ${ratio >= 1 ? 'higher' : 'lower'} volume than the previous 28 days.';
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Training-load context',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            comparison,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TrainingMetric(
                  label: 'Last 28 days',
                  volume: data.volume28,
                  workouts: data.workouts28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TrainingMetric(
                  label: 'Previous 28',
                  volume: data.previousVolume28,
                  workouts: data.previousWorkouts28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrainingMetric extends StatelessWidget {
  final String label;
  final double volume;
  final int workouts;

  const _TrainingMetric({
    required this.label,
    required this.volume,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 10)),
          const SizedBox(height: 5),
          Text(
            '${volume.round()} kg',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          Text(
            '$workouts workout${workouts == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ObservationsCard extends StatelessWidget {
  final RecoveryInsights data;

  const _ObservationsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                foregroundColor: AppColors.primary,
                child: Icon(Icons.auto_awesome_rounded),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Patterns to notice',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...data.observations.map(
            (observation) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      observation,
                      style: const TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
