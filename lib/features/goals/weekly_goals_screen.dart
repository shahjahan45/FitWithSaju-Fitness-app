import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/navigation/settled_dialog.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/fit_card.dart';
import '../nutrition/data/nutrition_store.dart';
import 'data/weekly_goal_models.dart';
import 'data/weekly_goal_service.dart';

class WeeklyGoalsScreen extends StatefulWidget {
  const WeeklyGoalsScreen({super.key});

  @override
  State<WeeklyGoalsScreen> createState() => _WeeklyGoalsScreenState();
}

class _WeeklyGoalsScreenState extends State<WeeklyGoalsScreen> {
  late Future<WeeklyGoalsSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = WeeklyGoalService.load();
    LocalStore.changes.addListener(_refreshFromStore);
    NutritionStore.changes.addListener(_refreshFromStore);
  }

  @override
  void dispose() {
    LocalStore.changes.removeListener(_refreshFromStore);
    NutritionStore.changes.removeListener(_refreshFromStore);
    super.dispose();
  }

  void _refreshFromStore() {
    if (!mounted) return;
    setState(() => _future = WeeklyGoalService.load());
  }

  Future<void> _editTargets(WeeklyGoalTargets current) async {
    var workouts = current.workouts;
    var minutes = current.trainingMinutes;
    var hydration = current.hydrationDays;
    var readiness = current.readinessDays;

    final result = await showSettledModalBottomSheet<WeeklyGoalTargets>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Material(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              bottom: true,
              maintainBottomViewPadding: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Set weekly goals',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Keep targets realistic. FitWithSaju never adds workouts automatically to make you hit a goal.',
                      style: TextStyle(color: AppColors.muted, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    _GoalStepper(
                      label: 'Workouts',
                      value: workouts,
                      suffix: 'sessions',
                      onMinus: workouts > 1
                          ? () => setSheetState(() => workouts--)
                          : null,
                      onPlus: workouts < 7
                          ? () => setSheetState(() => workouts++)
                          : null,
                    ),
                    _GoalStepper(
                      label: 'Training time',
                      value: minutes,
                      suffix: 'min',
                      onMinus: minutes > 30
                          ? () => setSheetState(() => minutes -= 30)
                          : null,
                      onPlus: minutes < 840
                          ? () => setSheetState(() => minutes += 30)
                          : null,
                    ),
                    _GoalStepper(
                      label: 'Hydration target days',
                      value: hydration,
                      suffix: 'days',
                      onMinus: hydration > 1
                          ? () => setSheetState(() => hydration--)
                          : null,
                      onPlus: hydration < 7
                          ? () => setSheetState(() => hydration++)
                          : null,
                    ),
                    _GoalStepper(
                      label: 'Readiness check-ins',
                      value: readiness,
                      suffix: 'days',
                      onMinus: readiness > 1
                          ? () => setSheetState(() => readiness--)
                          : null,
                      onPlus: readiness < 7
                          ? () => setSheetState(() => readiness++)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        key: const Key('weekly-goals-save-targets'),
                        onPressed: () => Navigator.of(sheetContext).pop(
                          WeeklyGoalTargets(
                            workouts: workouts,
                            trainingMinutes: minutes,
                            hydrationDays: hydration,
                            readinessDays: readiness,
                          ),
                        ),
                        child: const Text(
                          'Save weekly goals',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    if (result == null) return;
    await LocalStore.saveWeeklyGoals(
      workouts: result.workouts,
      trainingMinutes: result.trainingMinutes,
      hydrationDays: result.hydrationDays,
      readinessDays: result.readinessDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Goals')),
      body: FutureBuilder<WeeklyGoalsSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_outlined, size: 42, color: AppColors.muted),
                    const SizedBox(height: 12),
                    const Text(
                      'Weekly goals could not be loaded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refreshFromStore,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final data = snapshot.data!;
          return FitScrollableScreen(
            listKey: const Key('weekly-goals-scroll'),
            bottomSpacing: 28,
            children: [
              MotionReveal(child: _HeroCard(snapshot: data)),
              const SizedBox(height: 16),
              MotionReveal(
                delay: const Duration(milliseconds: 40),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'This week',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ),
                    TextButton.icon(
                      key: const Key('weekly-goals-edit'),
                      onPressed: () => _editTargets(data.targets),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('Edit goals'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              MotionReveal(
                delay: const Duration(milliseconds: 70),
                child: _ProgressGoalCard(
                  icon: Icons.fitness_center_rounded,
                  title: 'Workouts',
                  value: data.workouts,
                  formatter: (progress) =>
                      '${progress.current} / ${progress.target} sessions',
                ),
              ),
              const SizedBox(height: 10),
              MotionReveal(
                delay: const Duration(milliseconds: 90),
                child: _ProgressGoalCard(
                  icon: Icons.timer_rounded,
                  title: 'Training time',
                  value: data.trainingMinutes,
                  formatter: (progress) =>
                      '${progress.current} / ${progress.target} min',
                ),
              ),
              const SizedBox(height: 10),
              MotionReveal(
                delay: const Duration(milliseconds: 110),
                child: _ProgressGoalCard(
                  icon: Icons.water_drop_rounded,
                  title: 'Hydration consistency',
                  value: data.hydrationDays,
                  formatter: (progress) =>
                      '${progress.current} / ${progress.target} target days',
                ),
              ),
              const SizedBox(height: 10),
              MotionReveal(
                delay: const Duration(milliseconds: 130),
                child: _ProgressGoalCard(
                  icon: Icons.favorite_outline_rounded,
                  title: 'Readiness check-ins',
                  value: data.readinessDays,
                  formatter: (progress) =>
                      '${progress.current} / ${progress.target} days',
                ),
              ),
              const SizedBox(height: 16),
              MotionReveal(
                delay: const Duration(milliseconds: 160),
                child: FitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              data.coachingTitle,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.coachingMessage,
                        style: const TextStyle(color: AppColors.muted, height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Last week: ${data.previousWeekGoalsMet} of 4 targets met',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Weekly goals are fitness habit targets, not medical guidance. They never override readiness, rest days, deloads or your own judgement.',
                style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.4),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final WeeklyGoalsSnapshot snapshot;
  const _HeroCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reducedMotion(context);
    final percent = (snapshot.overallProgress * 100).round();
    return Container(
      key: const Key('weekly-goals-hero'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF183D24), Color(0xFF2F6B32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: reduce ? snapshot.overallProgress : 0.0,
                end: snapshot.overallProgress,
              ),
              duration: reduce ? AppMotion.reduced : AppMotion.chartReveal,
              curve: AppMotion.indicatorCurve,
              builder: (context, value, _) => Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 9,
                    backgroundColor: Colors.white.withValues(alpha: .12),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFA5D83F)),
                  ),
                  Center(
                    child: Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEEKLY CONSISTENCY',
                  style: TextStyle(
                    color: Color(0xFFA5D83F),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${snapshot.goalsMet} of 4 goals complete',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_shortDate(snapshot.weekStart)} – ${_shortDate(snapshot.weekEnd)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .72),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _shortDate(DateTime date) => '${date.day}/${date.month}';
}

class _ProgressGoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final WeeklyGoalProgress value;
  final String Function(WeeklyGoalProgress progress) formatter;

  const _ProgressGoalCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return FitCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
              if (value.complete)
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: value.ratio,
              backgroundColor: AppColors.surfaceAlt,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatter(value),
            style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _GoalStepper extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const _GoalStepper({
    required this.label,
    required this.value,
    required this.suffix,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text('$value $suffix', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            IconButton.filledTonal(onPressed: onMinus, icon: const Icon(Icons.remove_rounded)),
            const SizedBox(width: 4),
            IconButton.filled(onPressed: onPlus, icon: const Icon(Icons.add_rounded)),
          ],
        ),
      ),
    );
  }
}
