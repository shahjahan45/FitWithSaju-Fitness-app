import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../nutrition/nutrition_plan_screen.dart';
import 'content_sync_screen.dart';
import 'data_export_screen.dart';
import 'favorites_screen.dart';
import 'measurements_screen.dart';
import 'personal_records_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        key: const PageStorageKey('more-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const MotionReveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text(
                  'Your fitness tools, all in one place.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const MotionReveal(
            delay: Duration(milliseconds: 55),
            child: _SectionTitle('YOUR FITNESS'),
          ),
          MotionReveal(
            delay: const Duration(milliseconds: 80),
            child: _Group(
              children: [
                _ActionTile(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Diet & Meal Plan',
                  onTap: () => _open(context, const NutritionPlanScreen()),
                ),
                _ActionTile(
                  icon: Icons.favorite_rounded,
                  title: 'Favorites',
                  onTap: () => _open(context, const FavoritesScreen()),
                ),
                _ActionTile(
                  icon: Icons.straighten_rounded,
                  title: 'Measurements',
                  onTap: () => _open(context, const MeasurementsScreen()),
                ),
                _ActionTile(
                  icon: Icons.emoji_events_rounded,
                  title: 'Personal Records',
                  onTap: () => _open(context, const PersonalRecordsScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const MotionReveal(
            delay: Duration(milliseconds: 120),
            child: _SectionTitle('PREFERENCES & DATA'),
          ),
          MotionReveal(
            delay: const Duration(milliseconds: 145),
            child: _Group(
              children: [
                _ActionTile(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () => _info(context, 'Settings',
                      'Units, haptics, sound, and appearance controls are scheduled for the settings sprint.'),
                ),
                _ActionTile(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Exercise Content Sync',
                  onTap: () => _open(context, const ContentSyncScreen()),
                ),
                _ActionTile(
                  icon: Icons.file_download_outlined,
                  title: 'Backup & Restore',
                  onTap: () => _open(context, const DataExportScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const MotionReveal(
            delay: Duration(milliseconds: 185),
            child: _SectionTitle('ABOUT THE APP'),
          ),
          MotionReveal(
            delay: const Duration(milliseconds: 210),
            child: _Group(
              children: [
                _ActionTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About FitWithSaju',
                  onTap: () => _info(
                    context,
                    'FitWithSaju',
                    'Move. Train. Progress. Every day. A free, no-login fitness companion for daily workout planning and progress tracking.',
                  ),
                ),
                _ActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy',
                  onTap: () => _info(
                    context,
                    'Privacy',
                    'Workout plans, favorites, body metrics, and history in this starter are stored locally on your device.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const MotionReveal(
            delay: Duration(milliseconds: 250),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'FitWithSaju',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Move. Train. Progress.',
                    style: TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.detail,
        builder: (_) => screen,
      ),
    );
  }

  static Future<void> _info(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index != children.length - 1)
                const Divider(height: 1, indent: 54, endIndent: 12),
            ],
          );
        }),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(icon, color: AppColors.primary, size: 21),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        trailing:
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        onTap: onTap,
      ),
    );
  }
}
