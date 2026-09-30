import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/navigation/settled_dialog.dart';
import '../../core/settings/app_preferences.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/fit_card.dart';
import '../nutrition/data/nutrition_store.dart';
import '../workout/workout_calendar_screen.dart';
import 'data/readiness_models.dart';
import 'data/readiness_service.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  late Future<ReadinessSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = ReadinessService.load();
  }

  void _reload() {
    setState(() => _future = ReadinessService.load());
  }

  Future<void> _checkIn(ReadinessCheckIn? existing) async {
    final values = await showSettledModalBottomSheet<_CheckInValues>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _CheckInSheet(existing: existing),
    );
    if (values == null) {
      return;
    }
    await LocalStore.saveReadinessCheckIn(
      date: DateTime.now(),
      sleepQuality: values.sleep,
      energy: values.energy,
      soreness: values.soreness,
      stress: values.stress,
    );
    AppPreferences.successFeedback();
    if (!mounted) {
      return;
    }
    _reload();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(existing == null
            ? 'Today’s readiness check-in saved.'
            : 'Today’s readiness check-in updated.'),
      ),
    );
  }

  Future<void> _openCalendar() async {
    await Navigator.of(context).push(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.detail,
        builder: (_) => const WorkoutCalendarScreen(),
      ),
    );
    if (mounted) {
      _reload();
    }
  }

  Future<void> _quickReschedule(ReadinessSnapshot data) async {
    final session = data.programSession;
    if (session == null ||
        session.isRest ||
        session.isCompleted ||
        session.isSkipped) {
      return;
    }
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final picked = await showSettledModalBottomSheet<DateTime>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Move today’s session',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                'Choose a new day. Nothing changes until you select one.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 310,
                child: ListView.separated(
                  itemCount: 13,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final date = base.add(Duration(days: index + 1));
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySoft,
                        foregroundColor: AppColors.primary,
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      title: Text(
                        _weekday(date.weekday),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(_dateLabel(date)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(sheetContext).pop(date),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) {
      return;
    }
    await LocalStore.rescheduleProgramSession(
      programId: session.programId,
      sessionKey: session.sessionKey,
      scheduledDate: picked,
    );
    if (!mounted) {
      return;
    }
    _reload();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Session moved to ${_dateLabel(picked)}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recovery & Readiness')),
      body: AnimatedBuilder(
        animation:
            Listenable.merge([LocalStore.changes, NutritionStore.changes]),
        builder: (context, _) => FutureBuilder<ReadinessSnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            return _RecoveryContent(
              data: data,
              onCheckIn: () => _checkIn(data.checkIn),
              onCalendar: _openCalendar,
              onReschedule: data.assessment?.isLow == true
                  ? () => _quickReschedule(data)
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _RecoveryContent extends StatelessWidget {
  final ReadinessSnapshot data;
  final VoidCallback onCheckIn;
  final VoidCallback onCalendar;
  final VoidCallback? onReschedule;

  const _RecoveryContent({
    required this.data,
    required this.onCheckIn,
    required this.onCalendar,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final assessment = data.assessment;
    final checkIn = data.checkIn;
    return FitScrollableScreen(
      listKey: const Key('recovery-scroll'),
      topPadding: 10,
      bottomSpacing: 30,
      children: [
        const MotionReveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How ready are you today?',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 6),
              Text(
                'A fitness and recovery guidance score — not a medical or clinical assessment.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        MotionReveal(
          delay: const Duration(milliseconds: 55),
          child: _HeroReadinessCard(
            assessment: assessment,
            hasCheckIn: checkIn != null,
            onCheckIn: onCheckIn,
          ),
        ),
        const SizedBox(height: 16),
        if (checkIn != null) ...[
          MotionReveal(
            delay: const Duration(milliseconds: 90),
            child: _SignalGrid(checkIn: checkIn, data: data),
          ),
          const SizedBox(height: 16),
        ],
        if (assessment != null) ...[
          MotionReveal(
            delay: const Duration(milliseconds: 125),
            child: _RecommendationCard(assessment: assessment),
          ),
          const SizedBox(height: 16),
          MotionReveal(
            delay: const Duration(milliseconds: 150),
            child: _ScoreBreakdownCard(assessment: assessment),
          ),
          const SizedBox(height: 16),
        ],
        MotionReveal(
          delay: const Duration(milliseconds: 175),
          child: _TrainingLoadCard(load: data.trainingLoad),
        ),
        const SizedBox(height: 16),
        if (data.programSession != null) ...[
          MotionReveal(
            delay: const Duration(milliseconds: 205),
            child: _ProgramSessionCard(
              data: data,
              onCalendar: onCalendar,
              onReschedule: onReschedule,
            ),
          ),
          const SizedBox(height: 16),
        ],
        MotionReveal(
          delay: const Duration(milliseconds: 235),
          child: _ReadinessHistoryCard(data: data),
        ),
      ],
    );
  }
}

class _HeroReadinessCard extends StatelessWidget {
  final ReadinessAssessment? assessment;
  final bool hasCheckIn;
  final VoidCallback onCheckIn;

  const _HeroReadinessCard({
    required this.assessment,
    required this.hasCheckIn,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final score = assessment?.score ?? 0;
    return Container(
      key: const Key('readiness-hero-card'),
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
            color: AppColors.primary.withValues(alpha: .10),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ReadinessRing(score: score, enabled: assessment != null),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      assessment?.label ?? 'Check in to calculate readiness',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      assessment == null
                          ? 'Your four recovery inputs combine with hydration and recent training context.'
                          : 'Guidance only. You stay in control of every workout decision.',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('readiness-check-in-button'),
              onPressed: onCheckIn,
              icon: Icon(
                  hasCheckIn ? Icons.edit_rounded : Icons.add_task_rounded),
              label: Text(hasCheckIn
                  ? 'Edit today’s check-in'
                  : 'Start daily check-in'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessRing extends StatelessWidget {
  final int score;
  final bool enabled;

  const _ReadinessRing({required this.score, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reducedMotion(context);
    final end = enabled ? score / 100 : 0.0;
    return SizedBox(
      width: 104,
      height: 104,
      child: TweenAnimationBuilder<double>(
        key: const Key('readiness-score-ring'),
        tween: Tween<double>(begin: reduceMotion ? end : 0, end: end),
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 760),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 9,
                strokeCap: StrokeCap.round,
                backgroundColor: AppColors.surfaceAlt,
                color: AppColors.primary,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  enabled ? '${(value * 100).round()}' : '—',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const Text(
                  '/ 100',
                  style: TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalGrid extends StatelessWidget {
  final ReadinessCheckIn checkIn;
  final ReadinessSnapshot data;

  const _SignalGrid({required this.checkIn, required this.data});

  @override
  Widget build(BuildContext context) {
    final items = <_SignalData>[
      _SignalData('Sleep', '${checkIn.sleepQuality}/5', Icons.bedtime_outlined),
      _SignalData('Energy', '${checkIn.energy}/5', Icons.bolt_rounded),
      _SignalData(
          'Soreness', '${checkIn.soreness}/5', Icons.accessibility_new_rounded),
      _SignalData(
          'Stress', '${checkIn.stress}/5', Icons.psychology_alt_outlined),
      _SignalData(
        'Hydration',
        '${(data.hydrationProgress * 100).round()}%',
        Icons.water_drop_outlined,
      ),
      _SignalData(
        '7-day sessions',
        '${data.trainingLoad.last7DaysWorkouts}',
        Icons.fitness_center_rounded,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: .95,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: AppColors.primary, size: 20),
              const SizedBox(height: 8),
              Text(
                item.value,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignalData {
  final String label;
  final String value;
  final IconData icon;
  const _SignalData(this.label, this.value, this.icon);
}

class _RecommendationCard extends StatelessWidget {
  final ReadinessAssessment assessment;
  const _RecommendationCard({required this.assessment});

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
                  'Today’s guidance',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            assessment.label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            assessment.recommendation,
            style: const TextStyle(color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 12),
          const Text(
            'FitWithSaju never cancels, skips, or changes a workout automatically.',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ScoreBreakdownCard extends StatelessWidget {
  final ReadinessAssessment assessment;
  const _ScoreBreakdownCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final b = assessment.breakdown;
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How the score is built',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 4),
          const Text(
            'Transparent weighting from your check-in and fitness context.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          _BreakdownRow('Check-in signals', b.checkInPoints, 70),
          _BreakdownRow('Hydration today', b.hydrationPoints, 10),
          _BreakdownRow('7-day training load', b.trainingLoadPoints, 10),
          _BreakdownRow('Workout frequency', b.frequencyPoints, 5),
          _BreakdownRow('Program / recovery day', b.programPoints, 5),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double points;
  final double maxPoints;
  const _BreakdownRow(this.label, this.points, this.maxPoints);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(
            '${points.toStringAsFixed(points % 1 == 0 ? 0 : 1)} / ${maxPoints.round()}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TrainingLoadCard extends StatelessWidget {
  final TrainingLoadContext load;
  const _TrainingLoadCard({required this.load});

  @override
  Widget build(BuildContext context) {
    final ratio = load.volumeRatio;
    final contextText = ratio == null
        ? 'Not enough previous-week volume for a direct comparison.'
        : '${((ratio - 1) * 100).abs().round()}% ${ratio >= 1 ? 'higher' : 'lower'} than the previous 7 days.';
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7-day training load',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            contextText,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LoadMetric(
                  label: 'Last 7 days',
                  value: '${load.last7DaysVolume.round()} kg',
                  subtitle: '${load.last7DaysWorkouts} workouts',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LoadMetric(
                  label: 'Previous 7',
                  value: '${load.previous7DaysVolume.round()} kg',
                  subtitle: '${load.previous7DaysWorkouts} workouts',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadMetric extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  const _LoadMetric(
      {required this.label, required this.value, required this.subtitle});

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
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          Text(subtitle,
              style: const TextStyle(color: AppColors.muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ProgramSessionCard extends StatelessWidget {
  final ReadinessSnapshot data;
  final VoidCallback onCalendar;
  final VoidCallback? onReschedule;

  const _ProgramSessionCard({
    required this.data,
    required this.onCalendar,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final session = data.programSession!;
    final status = session.isRest
        ? 'Recovery / rest day'
        : session.isDeload
            ? 'Deload session'
            : session.isCompleted
                ? 'Completed'
                : 'Scheduled today';
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.secondarySoft,
                foregroundColor: AppColors.secondary,
                child: Icon(session.isRest
                    ? Icons.bedtime_outlined
                    : Icons.event_available_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TODAY’S PROGRAM',
                      style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(session.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 17)),
                    Text(status,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCalendar,
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Training Calendar'),
                ),
              ),
            ],
          ),
          if (onReschedule != null &&
              !session.isRest &&
              !session.isCompleted) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                key: const Key('readiness-quick-reschedule'),
                onPressed: onReschedule,
                icon: const Icon(Icons.event_repeat_rounded),
                label: const Text('Quick reschedule'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadinessHistoryCard extends StatelessWidget {
  final ReadinessSnapshot data;
  const _ReadinessHistoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final history = data.history;
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent readiness',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
              if (data.averageScore != null)
                Text(
                  'Avg ${data.averageScore}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Your last 7 calendar days with saved check-ins.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text('No readiness history yet.',
                    style: TextStyle(color: AppColors.muted)),
              ),
            )
          else ...[
            SizedBox(height: 110, child: _TrendBars(history: history)),
            const SizedBox(height: 14),
            if (data.bestDay != null && data.lowestDay != null)
              Row(
                children: [
                  Expanded(
                    child: _HistoryHighlight(
                      label: 'Best recovery',
                      value: '${data.bestDay!.score}',
                      date: _shortWeekday(data.bestDay!.date),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HistoryHighlight(
                      label: 'Lowest recovery',
                      value: '${data.lowestDay!.score}',
                      date: _shortWeekday(data.lowestDay!.date),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            ...history.reversed.take(4).map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_shortWeekday(point.date)} • ${_dateLabel(point.date)}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${point.score}/100',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _TrendBars extends StatelessWidget {
  final List<ReadinessHistoryPoint> history;
  const _TrendBars({required this.history});

  @override
  Widget build(BuildContext context) {
    final byDate = <String, int>{
      for (final point in history)
        LocalStore.localDateKey(point.date): point.score,
    };
    final now = DateTime.now();
    final days = List<DateTime>.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index)),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: days.map((day) {
        final score = byDate[LocalStore.localDateKey(day)];
        final height = score == null ? 8.0 : 18 + (score / 100 * 62);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  score?.toString() ?? '',
                  style: const TextStyle(fontSize: 9, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                AnimatedVerticalBar(
                  height: height,
                  decoration: BoxDecoration(
                    color: score == null
                        ? AppColors.border
                        : AppColors.primary
                            .withValues(alpha: .28 + ((score / 100) * .55)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 6),
                Text(_shortWeekday(day).substring(0, 1),
                    style:
                        const TextStyle(fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HistoryHighlight extends StatelessWidget {
  final String label;
  final String value;
  final String date;
  const _HistoryHighlight(
      {required this.label, required this.value, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(date, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class _CheckInValues {
  final int sleep;
  final int energy;
  final int soreness;
  final int stress;
  const _CheckInValues(
      {required this.sleep,
      required this.energy,
      required this.soreness,
      required this.stress});
}

class _CheckInSheet extends StatefulWidget {
  final ReadinessCheckIn? existing;
  const _CheckInSheet({required this.existing});

  @override
  State<_CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<_CheckInSheet> {
  late double sleep;
  late double energy;
  late double soreness;
  late double stress;

  @override
  void initState() {
    super.initState();
    sleep = (widget.existing?.sleepQuality ?? 3).toDouble();
    energy = (widget.existing?.energy ?? 3).toDouble();
    soreness = (widget.existing?.soreness ?? 3).toDouble();
    stress = (widget.existing?.stress ?? 3).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + keyboard),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null
                  ? 'Daily readiness check-in'
                  : 'Edit today’s check-in',
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            const Text(
              'Rate how you feel right now. 1 is low and 5 is high. For soreness and stress, a higher rating means more soreness/stress.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            _RatingSlider(
              key: const Key('readiness-sleep-slider'),
              label: 'Sleep quality',
              value: sleep,
              icon: Icons.bedtime_outlined,
              onChanged: (value) => setState(() => sleep = value),
            ),
            _RatingSlider(
              key: const Key('readiness-energy-slider'),
              label: 'Energy',
              value: energy,
              icon: Icons.bolt_rounded,
              onChanged: (value) => setState(() => energy = value),
            ),
            _RatingSlider(
              key: const Key('readiness-soreness-slider'),
              label: 'Muscle soreness',
              value: soreness,
              icon: Icons.accessibility_new_rounded,
              onChanged: (value) => setState(() => soreness = value),
            ),
            _RatingSlider(
              key: const Key('readiness-stress-slider'),
              label: 'Stress',
              value: stress,
              icon: Icons.psychology_alt_outlined,
              onChanged: (value) => setState(() => stress = value),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                key: const Key('readiness-save-check-in'),
                onPressed: () => Navigator.of(context).pop(
                  _CheckInValues(
                    sleep: sleep.round(),
                    energy: energy.round(),
                    soreness: soreness.round(),
                    stress: stress.round(),
                  ),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save check-in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSlider extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final ValueChanged<double> onChanged;

  const _RatingSlider({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 9),
                Expanded(
                    child: Text(label,
                        style: const TextStyle(fontWeight: FontWeight.w800))),
                Container(
                  width: 34,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('${value.round()}',
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              label: '${value.round()}',
              onChanged: (next) {
                if (next.round() != value.round()) {
                  AppPreferences.selectionFeedback();
                }
                onChanged(next);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text('1',
                      style: TextStyle(color: AppColors.muted, fontSize: 10)),
                  Spacer(),
                  Text('5',
                      style: TextStyle(color: AppColors.muted, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _weekday(int weekday) {
  const labels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  return labels[(weekday - 1).clamp(0, 6)];
}

String _shortWeekday(DateTime date) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[(date.weekday - 1).clamp(0, 6)];
}

String _dateLabel(DateTime date) {
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
    'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}';
}
