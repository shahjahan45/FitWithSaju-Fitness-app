import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import 'data/training_balance_models.dart';
import 'data/training_balance_service.dart';
import 'training_balance_screen.dart';

class TrainingBalanceSummaryCard extends StatelessWidget {
  final String eyebrow;

  const TrainingBalanceSummaryCard({
    super.key,
    this.eyebrow = 'TRAINING BALANCE',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStore.changes,
      builder: (context, _, __) => FutureBuilder<TrainingBalanceSnapshot>(
        future: TrainingBalanceService.load(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final loadFailed = snapshot.hasError;
          final ratio = data?.balance.volumeRatio;
          final ratioLabel = ratio == null ? '—' : '${(ratio * 100).round()}%';
          return FitCard(
            key: const Key('training-balance-summary-card'),
            onTap: () => Navigator.of(context).push(
              FitRoutes.route(
                context,
                motion: FitRouteMotion.detail,
                builder: (_) => const TrainingBalanceScreen(),
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
                    ratioLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: ratioLabel.length > 4 ? 13 : 16,
                    ),
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
                          letterSpacing: .65,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loadFailed
                            ? 'Training context unavailable'
                            : data?.balance.label ?? 'Loading training context',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        loadFailed
                            ? 'Tap to open the safe retry screen'
                            : data == null
                                ? 'Reading your local workout history…'
                                : '${data.balance.currentWorkouts} workouts • ${data.balance.currentVolume.round()} kg in 7 days',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
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
