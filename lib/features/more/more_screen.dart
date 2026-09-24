import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.favorite_rounded, 'Favorites'),
      (Icons.straighten_rounded, 'Measurements'),
      (Icons.emoji_events_rounded, 'Personal Records'),
      (Icons.file_download_outlined, 'Export My Data'),
      (Icons.settings_rounded, 'Settings'),
      (Icons.info_outline_rounded, 'About FitWithSaju'),
      (Icons.privacy_tip_outlined, 'Privacy'),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const Text(
            'More',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your preferences and personal fitness tools.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: Icon(item.$1, color: AppColors.primary),
                title: Text(
                  item.$2,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
