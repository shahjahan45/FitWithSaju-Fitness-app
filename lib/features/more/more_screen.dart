import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../nutrition/nutrition_plan_screen.dart';
import 'achievements_screen.dart';
import 'content_sync_screen.dart';
import 'data_export_screen.dart';
import 'favorites_screen.dart';
import 'measurements_screen.dart';
import 'personal_records_screen.dart';
import 'settings_screen.dart';
import 'info_screens.dart';

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
          const SizedBox(height: 18),
          MotionReveal(
            delay: const Duration(milliseconds: 35),
            child: FutureBuilder<Map<String, String>>(
              future: LocalStore.profile(),
              builder: (context, snapshot) => _ProfileSummary(
                profile: snapshot.data ?? const <String, String>{},
                onTap: () => _open(context, const SettingsScreen()),
              ),
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
                _ActionTile(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Achievements',
                  onTap: () => _open(context, const AchievementsScreen()),
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
                  onTap: () => _open(context, const SettingsScreen()),
                ),
                _ActionTile(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Content Sync',
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
                  icon: Icons.menu_book_rounded,
                  title: 'App Guide',
                  onTap: () => _open(context, const AppGuideScreen()),
                ),
                _ActionTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About FitWithSaju',
                  onTap: () => _open(context, const AboutFitWithSajuScreen()),
                ),
                _ActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy & Data',
                  onTap: () => _open(context, const PrivacyScreen()),
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
}

class _ProfileSummary extends StatelessWidget {
  final Map<String, String> profile;
  final VoidCallback onTap;

  const _ProfileSummary({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final goal = profile['goal']?.trim().isNotEmpty == true
        ? profile['goal']!
        : 'Balanced fitness';
    final level = profile['level']?.trim().isNotEmpty == true
        ? profile['level']!
        : 'Build your level';
    final place = profile['place']?.trim().isNotEmpty == true
        ? profile['place']!
        : 'Any training place';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF173D25), Color(0xFF285D2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFFA5D83F),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$level • $place',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.tune_rounded, color: Color(0xFFA5D83F)),
            ],
          ),
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
