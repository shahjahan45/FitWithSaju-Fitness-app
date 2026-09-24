import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import 'history_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const Text(
            'Progress',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Consistency is your strongest metric.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: const [
              _StatCard(label: 'Workouts', value: '5', icon: Icons.bolt_rounded),
              _StatCard(label: 'Training', value: '4h 25m', icon: Icons.timer_rounded),
              _StatCard(label: 'Sets', value: '112', icon: Icons.repeat_rounded),
              _StatCard(label: 'Streak', value: '7 days', icon: Icons.local_fire_department_rounded),
            ],
          ),
          const SizedBox(height: 24),
          FitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly activity',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final heights = [72.0, 110.0, 88.0, 126.0, 56.0, 92.0, 42.0];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: heights[i],
                                decoration: BoxDecoration(
                                  color: i == 3
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(alpha: .18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FitCard(
            child: ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: .12),
                child: Icon(Icons.monitor_weight_rounded, color: AppColors.primary),
              ),
              title: Text(
                'Workout history',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                'View your completed sessions stored on this device',
                style: TextStyle(color: AppColors.muted),
              ),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
