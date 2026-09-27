import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/workout_factory.dart';
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
            return _HomeContent(
              todayPlan: todayPlan,
              weeklyPlan: weeklyPlan,
              history: history,
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

  const _HomeContent({
    required this.todayPlan,
    required this.weeklyPlan,
    required this.history,
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
            Row(
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
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Image.asset('assets/images/fitwithsaju_logo.png'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF123C2B),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF123C2B).withValues(alpha: .18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
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
                    todayPlan['title'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isRest ? 'Recharge and come back stronger.' : workout.subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (!isRest) ...[
                    const SizedBox(height: 15),
                    Text(
                      '${workout.durationMinutes} min  •  ${workout.exercises.length} exercises',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFA8E63B),
                          foregroundColor: const Color(0xFF153020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: workout.exercises.isEmpty
                            ? null
                            : () => Navigator.of(context).push(
                                  FitRoutes.route(
                                    context,
                                    motion: FitRouteMotion.fullScreen,
                                    builder: (_) => ActiveWorkoutScreen(workout: workout),
                                  ),
                                ),
                        child: const Text(
                          'Start today’s workout',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'This week',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  '$streak-day streak',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _WeekStrip(plan: weeklyPlan),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Quick workouts',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 136,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _QuickCard(
                    icon: Icons.flash_on_rounded,
                    title: '10 Min',
                    subtitle: 'A short burst of movement',
                  ),
                  _QuickCard(
                    icon: Icons.accessibility_new_rounded,
                    title: 'Full Body',
                    subtitle: 'Train all major muscle groups',
                  ),
                  _QuickCard(
                    icon: Icons.monitor_heart_rounded,
                    title: 'Cardio',
                    subtitle: 'Conditioning and endurance',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const FitCard(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Small progress every day becomes big results.',
                      style: TextStyle(fontWeight: FontWeight.w800, height: 1.35),
                    ),
                  ),
                ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),
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
