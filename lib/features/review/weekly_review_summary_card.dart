import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../nutrition/data/nutrition_store.dart';
import 'data/weekly_review_models.dart';
import 'data/weekly_review_service.dart';
import 'weekly_review_screen.dart';

class WeeklyReviewSummaryCard extends StatelessWidget {
  final String eyebrow;

  const WeeklyReviewSummaryCard({
    super.key,
    this.eyebrow = 'WEEKLY REVIEW',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStore.changes,
      builder: (context, _, __) => ValueListenableBuilder<int>(
        valueListenable: NutritionStore.changes,
        builder: (context, _, __) => FutureBuilder<WeeklyReviewSnapshot>(
          future: WeeklyReviewService.load(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final failed = snapshot.hasError;
            return FitCard(
              key: const Key('weekly-review-summary-card'),
              onTap: () => Navigator.of(context).push(
                FitRoutes.route(
                  context,
                  motion: FitRouteMotion.detail,
                  builder: (_) => const WeeklyReviewScreen(),
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
                    child: const Icon(
                      Icons.insights_rounded,
                      color: AppColors.primary,
                    ),
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
                          failed
                              ? 'Weekly review unavailable'
                              : data == null
                                  ? 'Building your weekly review…'
                                  : data.headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          failed
                              ? 'Tap to open the safe retry screen'
                              : data == null
                                  ? 'Reading your local training data…'
                                  : '${data.current.workouts} workouts • ${data.current.goalsMet}/4 goals • ${data.currentTrainingWeekStreak}-week rhythm',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.muted,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
