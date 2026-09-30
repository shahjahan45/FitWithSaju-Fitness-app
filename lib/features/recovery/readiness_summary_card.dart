import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../nutrition/data/nutrition_store.dart';
import 'data/readiness_service.dart';
import 'recovery_screen.dart';

class ReadinessSummaryCard extends StatelessWidget {
  final String eyebrow;

  const ReadinessSummaryCard({
    super.key,
    this.eyebrow = 'DAILY READINESS',
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([LocalStore.changes, NutritionStore.changes]),
      builder: (context, _) => FutureBuilder(
        future: ReadinessService.load(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final score = data?.assessment?.score;
          final hydration = data?.hydrationProgress ?? 0;
          final label = data?.assessment?.label ?? 'Complete today’s check-in';

          return FitCard(
            onTap: () => Navigator.of(context).push(
              FitRoutes.route(
                context,
                motion: FitRouteMotion.detail,
                builder: (_) => const RecoveryScreen(),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: score == null ? 0 : score / 100,
                        strokeWidth: 6,
                        backgroundColor: AppColors.surfaceAlt,
                        color: AppColors.primary,
                      ),
                      Text(
                        score == null ? '—' : '$score',
                        key: const Key('readiness-summary-score'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: .7,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        score == null
                            ? 'Sleep, energy, soreness and stress • guidance only'
                            : 'Hydration ${(hydration * 100).round()}% • 7-day training context included',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          height: 1.3,
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
    );
  }
}
