import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../nutrition/data/nutrition_store.dart';
import 'data/weekly_goal_models.dart';
import 'data/weekly_goal_service.dart';
import 'weekly_goals_screen.dart';

class WeeklyGoalsSummaryCard extends StatelessWidget {
  final String eyebrow;
  const WeeklyGoalsSummaryCard({
    super.key,
    this.eyebrow = 'WEEKLY GOALS',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStore.changes,
      builder: (context, _, __) => ValueListenableBuilder<int>(
        valueListenable: NutritionStore.changes,
        builder: (context, _, __) => FutureBuilder<WeeklyGoalsSnapshot>(
          future: WeeklyGoalService.load(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const SizedBox.shrink();
            }
            final data = snapshot.data;
            return FitCard(
              key: const Key('weekly-goals-summary-card'),
              onTap: () => Navigator.of(context).push(
                FitRoutes.route(
                  context,
                  motion: FitRouteMotion.detail,
                  builder: (_) => const WeeklyGoalsScreen(),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.flag_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: .7,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data == null
                              ? 'Loading weekly progress…'
                              : '${data.goalsMet} of 4 goals complete',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            minHeight: 7,
                            value: data?.overallProgress ?? 0,
                            backgroundColor: AppColors.surfaceAlt,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
