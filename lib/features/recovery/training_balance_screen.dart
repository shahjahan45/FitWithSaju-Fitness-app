import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/fit_card.dart';
import '../workout/workout_calendar_screen.dart';
import 'data/training_balance_models.dart';
import 'data/training_balance_service.dart';

class TrainingBalanceScreen extends StatefulWidget {
  final DateTime? anchorDate;

  const TrainingBalanceScreen({super.key, this.anchorDate});

  @override
  State<TrainingBalanceScreen> createState() => _TrainingBalanceScreenState();
}

class _TrainingBalanceScreenState extends State<TrainingBalanceScreen> {
  int _reloadToken = 0;

  void _retry() => setState(() => _reloadToken++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training Balance')),
      body: ValueListenableBuilder<int>(
        valueListenable: LocalStore.changes,
        builder: (context, _, __) {
          final token = _reloadToken;
          return FutureBuilder<TrainingBalanceSnapshot>(
            key: ValueKey(token),
            future: TrainingBalanceService.load(date: widget.anchorDate),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _LoadError(onRetry: _retry);
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return _TrainingBalanceContent(data: snapshot.data!);
            },
          );
        },
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({required this.onRetry});

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
                  Icons.balance_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Training balance is temporarily unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your saved training data is unchanged. Retry after the local data refresh completes.',
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

class _TrainingBalanceContent extends StatelessWidget {
  final TrainingBalanceSnapshot data;

  const _TrainingBalanceContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return FitScrollableScreen(
      listKey: const Key('training-balance-scroll'),
      topPadding: 10,
      bottomSpacing: 30,
      children: [
        const MotionReveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Train with context',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 6),
              Text(
                'Compare your last 7 days with your recent training baseline, then review the next 7 days before deciding how to train.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        MotionReveal(
          delay: const Duration(milliseconds: 45),
          child: _BalanceHero(data: data),
        ),
        const SizedBox(height: 16),
        MotionReveal(
          delay: const Duration(milliseconds: 80),
          child: _RecoveryContextCard(data: data),
        ),
        const SizedBox(height: 16),
        MotionReveal(
          delay: const Duration(milliseconds: 115),
          child: _PlanPreviewCard(data: data),
        ),
        if (data.hasActiveProgram) ...[
          const SizedBox(height: 12),
          MotionReveal(
            delay: const Duration(milliseconds: 145),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  FitRoutes.route(
                    context,
                    motion: FitRouteMotion.detail,
                    builder: (_) => const WorkoutCalendarScreen(),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Open Training Calendar'),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const MotionReveal(
          delay: Duration(milliseconds: 175),
          child: _GuidanceNotice(),
        ),
      ],
    );
  }
}

class _BalanceHero extends StatelessWidget {
  final TrainingBalanceSnapshot data;

  const _BalanceHero({required this.data});

  @override
  Widget build(BuildContext context) {
    final balance = data.balance;
    final ratio = balance.volumeRatio;
    final progress =
        ratio == null ? 0.0 : (ratio.clamp(0.0, 1.75) / 1.75).toDouble();
    final ratioLabel = ratio == null ? '—' : '${(ratio * 100).round()}%';

    return Container(
      key: const Key('training-balance-hero'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF0F8E7)],
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
          const Text(
            '7-DAY TRAINING BALANCE',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .75,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            balance.label,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            ratio == null
                ? 'Complete more training sessions to establish a 3-week comparison baseline.'
                : '$ratioLabel of your average weekly volume from the previous 3 weeks.',
            style: const TextStyle(color: AppColors.muted, height: 1.35),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: AppColors.primary.withValues(alpha: .10),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Last 7 days',
                  value: '${balance.currentVolume.round()} kg',
                  caption: '${balance.currentWorkouts} workouts',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: '3-week baseline',
                  value: balance.baselineWeeklyVolume <= 0
                      ? '—'
                      : '${balance.baselineWeeklyVolume.round()} kg',
                  caption: balance.baselineWeeklyWorkouts <= 0
                      ? 'Building baseline'
                      : '${balance.baselineWeeklyWorkouts.toStringAsFixed(1)} workouts/week',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
          ),
        ],
      ),
    );
  }
}

class _RecoveryContextCard extends StatelessWidget {
  final TrainingBalanceSnapshot data;

  const _RecoveryContextCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final readiness = data.readinessAverage7;
    return FitCard(
      key: const Key('training-balance-recovery-context'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                foregroundColor: AppColors.primary,
                child: Icon(Icons.monitor_heart_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RECOVERY CONTEXT',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      readiness == null
                          ? 'Add readiness check-ins'
                          : '$readiness average readiness',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.readinessCheckIns7}/7 check-ins in the recent 7-day window',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              data.balance.guidance,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanPreviewCard extends StatelessWidget {
  final TrainingBalanceSnapshot data;

  const _PlanPreviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return FitCard(
      key: const Key('training-balance-plan-preview'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                foregroundColor: AppColors.primary,
                child: Icon(Icons.event_note_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEXT 7 DAYS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.hasActiveProgram
                          ? data.activeProgramName!
                          : 'Your weekly workout plan',
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
          if (data.upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No upcoming sessions in this 7-day window.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else
            ...data.upcoming.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlanPreviewRow(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanPreviewRow extends StatelessWidget {
  final TrainingPlanPreviewItem item;

  const _PlanPreviewRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final day = _shortWeekday(item.date.weekday);
    final badge = item.isRest
        ? 'Recovery'
        : item.isDeload
            ? 'Deload'
            : item.isRescheduled
                ? 'Moved'
                : item.status == 'today'
                    ? 'Today'
                    : 'Planned';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.isRest
                  ? AppColors.surface
                  : AppColors.primary.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${item.date.day}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  item.dayLabel,
                  style:
                      const TextStyle(color: AppColors.muted, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: item.isRest ? AppColors.surface : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: item.isRest ? AppColors.muted : AppColors.primary,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _shortWeekday(int weekday) => const <String>[
        'MON',
        'TUE',
        'WED',
        'THU',
        'FRI',
        'SAT',
        'SUN'
      ][weekday - 1];
}

class _GuidanceNotice extends StatelessWidget {
  const _GuidanceNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Training Balance is fitness guidance, not a medical or injury-risk score. FitWithSaju never changes your workout plan automatically.',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
