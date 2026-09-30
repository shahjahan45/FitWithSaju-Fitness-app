import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/workout_factory.dart';
import '../nutrition/nutrition_home_shortcut.dart';
import '../recovery/readiness_summary_card.dart';
import '../workout/active_workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStore.changes,
      builder: (context, _, __) {
        return FutureBuilder<List<dynamic>>(
          future: Future.wait<dynamic>([
            LocalStore.todayPlan(),
            LocalStore.weeklyPlan(),
            LocalStore.history(),
            LocalStore.activeWorkout(),
          ]),
          builder: (context, snapshot) {
            final todayPlan = snapshot.hasData
                ? snapshot.data![0] as Map<String, dynamic>
                : <String, dynamic>{
                    'day': LocalStore.weekDays[DateTime.now().weekday - 1],
                    'title': 'Loading…',
                    'isRest': true,
                    'durationMinutes': 0,
                    'exerciseIds': <String>[],
                  };
            final weeklyPlan = snapshot.hasData
                ? snapshot.data![1] as List<Map<String, dynamic>>
                : <Map<String, dynamic>>[];
            final history = snapshot.hasData
                ? snapshot.data![2] as List<Map<String, dynamic>>
                : <Map<String, dynamic>>[];
            final activeDraft = snapshot.hasData
                ? snapshot.data![3] as Map<String, dynamic>?
                : null;
            return _HomeContent(
              todayPlan: todayPlan,
              weeklyPlan: weeklyPlan,
              history: history,
              activeDraft: activeDraft,
            );
          },
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final Map<String, dynamic> todayPlan;
  final List<Map<String, dynamic>> weeklyPlan;
  final List<Map<String, dynamic>> history;
  final Map<String, dynamic>? activeDraft;

  const _HomeContent({
    required this.todayPlan,
    required this.weeklyPlan,
    required this.history,
    required this.activeDraft,
  });

  @override
  Widget build(BuildContext context) {
    final isRest = todayPlan['isRest'] == true;
    final workout = WorkoutFactory.fromPlan(todayPlan);
    final streak = _calculateStreak(history);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9FBF7), Color(0xFFF2F6EE)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          key: const PageStorageKey('home-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            const MotionReveal(
              child: _HomeHeader(),
            ),
            const SizedBox(height: 24),
            if (activeDraft != null) ...[
              MotionReveal(
                delay: const Duration(milliseconds: 55),
                child: _ResumeWorkoutCard(draft: activeDraft!),
              ),
              const SizedBox(height: 14),
            ],
            const MotionReveal(
              delay: Duration(milliseconds: 75),
              child: ReadinessSummaryCard(),
            ),
            const SizedBox(height: 14),
            MotionReveal(
              delay: const Duration(milliseconds: 90),
              child: BreathingGlow(
                color: const Color(0xFF2F6B32),
                child: _TodayWorkoutCard(
                  isRest: isRest,
                  title: todayPlan['title'].toString(),
                  subtitle: isRest
                      ? 'Recharge and come back stronger.'
                      : workout.subtitle,
                  durationMinutes: workout.durationMinutes,
                  exerciseCount: workout.exercises.length,
                  enabled: !isRest && workout.exercises.isNotEmpty,
                  onStart: () {
                    if (activeDraft != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Resume or discard your current workout before starting another one.',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      FitRoutes.route(
                        context,
                        motion: FitRouteMotion.fullScreen,
                        builder: (_) => ActiveWorkoutScreen(workout: workout),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const MotionReveal(
              delay: Duration(milliseconds: 125),
              child: NutritionHomeShortcut(),
            ),
            const SizedBox(height: 26),
            MotionReveal(
              delay: const Duration(milliseconds: 160),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'This week',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 17,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      AnimatedNumberText(
                        value: streak.toDouble(),
                        formatter: (value) => '${value.round()}-day streak',
                        duration: const Duration(milliseconds: 520),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            MotionReveal(
              delay: const Duration(milliseconds: 190),
              child: _WeekStrip(plan: weeklyPlan),
            ),
            const SizedBox(height: 26),
            const MotionReveal(
              delay: Duration(milliseconds: 230),
              child: Text(
                'Quick workouts',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 136,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  MotionReveal(
                    delay: Duration(milliseconds: 255),
                    offsetX: 12,
                    offsetY: 0,
                    child: _QuickCard(
                      icon: Icons.flash_on_rounded,
                      title: '10 Min',
                      subtitle: 'A short burst of movement',
                    ),
                  ),
                  MotionReveal(
                    delay: Duration(milliseconds: 295),
                    offsetX: 12,
                    offsetY: 0,
                    child: _QuickCard(
                      icon: Icons.accessibility_new_rounded,
                      title: 'Full Body',
                      subtitle: 'Train all major muscle groups',
                    ),
                  ),
                  MotionReveal(
                    delay: Duration(milliseconds: 335),
                    offsetX: 12,
                    offsetY: 0,
                    child: _QuickCard(
                      icon: Icons.monitor_heart_rounded,
                      title: 'Cardio',
                      subtitle: 'Conditioning and endurance',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const MotionReveal(
              delay: Duration(milliseconds: 365),
              child: FitCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Small progress every day becomes big results.',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateStreak(List<Map<String, dynamic>> items) {
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
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FitWithSaju',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Make time for your stronger self.',
                style: TextStyle(
                  fontSize: 27,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: .90, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset('assets/images/fitwithsaju_logo.png'),
          ),
        ),
      ],
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  final bool isRest;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final int exerciseCount;
  final bool enabled;
  final VoidCallback onStart;

  const _TodayWorkoutCard({
    required this.isRest,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.exerciseCount,
    required this.enabled,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF163F2F), Color(0xFF0E3124)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -35,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFAEEA56).withValues(alpha: .08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRest ? 'TODAY • RECOVERY' : 'TODAY’S PLAN',
                style: const TextStyle(
                  color: Color(0xFFAEEA56),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
              if (!isRest) ...[
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$durationMinutes min',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$exerciseCount exercises',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: PressableScale(
                    onTap: enabled ? onStart : null,
                    borderRadius: BorderRadius.circular(14),
                    pressedScale: .985,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: enabled
                            ? const Color(0xFFA8E63B)
                            : Colors.white.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Start today’s workout',
                        style: TextStyle(
                          color: enabled
                              ? const Color(0xFF153020)
                              : Colors.white54,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ResumeWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> draft;

  const _ResumeWorkoutCard({required this.draft});

  @override
  Widget build(BuildContext context) {
    final workout = WorkoutFactory.fromDraft(draft);
    final completed = ((draft['sets'] as Iterable?) ?? const []).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: .35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.play_arrow_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WORKOUT IN PROGRESS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  workout.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '$completed completed sets',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          PressableScale(
            onTap: workout.exercises.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      FitRoutes.route(
                        context,
                        motion: FitRouteMotion.fullScreen,
                        builder: (_) => ActiveWorkoutScreen(
                          workout: workout,
                          resumeDraft: draft,
                        ),
                      ),
                    ),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Resume',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final List<Map<String, dynamic>> plan;
  const _WeekStrip({required this.plan});

  @override
  Widget build(BuildContext context) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIndex = DateTime.now().weekday - 1;
    return Row(
      children: List.generate(7, (index) {
        final item = index < plan.length ? plan[index] : null;
        final isRest = item?['isRest'] == true;
        final today = index == todayIndex;
        return Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: .94, end: 1),
            duration: Duration(milliseconds: 260 + (index * 30)),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: today
                    ? const Color(0xFF2F6B32)
                    : isRest
                        ? Colors.white
                        : const Color(0xFFF0F8E2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: today ? const Color(0xFF2F6B32) : AppColors.border,
                ),
                boxShadow: today
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2F6B32).withValues(alpha: .16),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    letters[index],
                    style: TextStyle(
                      color: today ? Colors.white : AppColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    isRest ? Icons.remove_rounded : Icons.check_rounded,
                    size: 15,
                    color: today ? Colors.white : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FBF4)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: .035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
