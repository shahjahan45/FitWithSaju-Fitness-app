import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/demo_repository.dart';
import 'active_workout_screen.dart';
import 'custom_workout_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = DemoRepository.todaysWorkout;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const Text(
            'Workout',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Plan your week. Train one day at a time.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          const Text(
            'Weekly plan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...[
            ('Monday', 'Push Day', true),
            ('Tuesday', 'Pull Day', true),
            ('Wednesday', 'Legs', true),
            ('Thursday', 'Push Day', false),
            ('Friday', 'Pull Day', false),
            ('Saturday', 'Full Body', false),
            ('Sunday', 'Rest', false),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FitCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.$3
                            ? AppColors.primary.withValues(alpha: .12)
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.$3 ? Icons.check_rounded : Icons.calendar_today_rounded,
                        color: item.$3 ? AppColors.primary : AppColors.muted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            item.$2,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_horiz_rounded, color: AppColors.muted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ActiveWorkoutScreen(workout: workout),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Start Today’s Workout',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.secondary), foregroundColor: AppColors.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomWorkoutScreen())),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Custom Workout', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
