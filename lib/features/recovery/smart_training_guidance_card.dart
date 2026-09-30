import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../nutrition/data/nutrition_store.dart';
import 'data/readiness_service.dart';
import 'data/recovery_insights_calculator.dart';
import 'recovery_screen.dart';

class SmartTrainingGuidanceCard extends StatelessWidget {
  const SmartTrainingGuidanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([LocalStore.changes, NutritionStore.changes]),
      builder: (context, _) => FutureBuilder(
        future: ReadinessService.load(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final session = data?.programSession;
          final guidance = RecoveryInsightsCalculator.guidance(
            assessment: data?.assessment,
            hasProgramSessionToday: session != null && !session.isRest,
            isRestOrDeloadDay:
                session?.isRest == true || session?.isDeload == true,
          );

          return FitCard(
            key: const Key('smart-training-guidance-card'),
            onTap: () => Navigator.of(context).push(
              FitRoutes.route(
                context,
                motion: FitRouteMotion.detail,
                builder: (_) => const RecoveryScreen(),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      foregroundColor: AppColors.primary,
                      child: Icon(Icons.tune_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SMART TRAINING GUIDANCE',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .65,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            guidance.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  guidance.subtitle,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _GuidanceMetric(
                        label: 'Effort',
                        value: guidance.effortLabel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GuidanceMetric(
                        label: 'Volume',
                        value: guidance.volumeLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Optional guidance only — your workout is never changed automatically.',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GuidanceMetric extends StatelessWidget {
  final String label;
  final String value;

  const _GuidanceMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 9.5)),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
