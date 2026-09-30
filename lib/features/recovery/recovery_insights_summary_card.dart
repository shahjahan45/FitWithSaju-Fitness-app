import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../nutrition/data/nutrition_store.dart';
import 'data/recovery_insights_service.dart';
import 'recovery_insights_screen.dart';

class RecoveryInsightsSummaryCard extends StatelessWidget {
  const RecoveryInsightsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([LocalStore.changes, NutritionStore.changes]),
      builder: (context, _) => FutureBuilder(
        future: RecoveryInsightsService.load(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final delta = data?.trendDelta;
          final deltaLabel = delta == null
              ? 'Building baseline'
              : '${delta > 0 ? '+' : ''}$delta vs prior 7 days';
          return FitCard(
            key: const Key('recovery-insights-summary-card'),
            onTap: () => Navigator.of(context).push(
              FitRoutes.route(
                context,
                motion: FitRouteMotion.detail,
                builder: (_) => const RecoveryInsightsScreen(),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    data == null || data.checkInDays == 0
                        ? '—'
                        : '${data.averageScore}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 17),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '28-DAY RECOVERY INSIGHTS',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: .65,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data?.trendLabel ?? 'Loading recovery pattern',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data == null
                            ? 'Loading your local data…'
                            : '$deltaLabel • ${data.checkInDays}/28 check-ins',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          );
        },
      ),
    );
  }
}
