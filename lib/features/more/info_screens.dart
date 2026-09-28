import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AboutFitWithSajuScreen extends StatelessWidget {
  const AboutFitWithSajuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About FitWithSaju')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: const [
          _BrandHero(),
          SizedBox(height: 18),
          _InfoSection(
            title: 'Built for consistency',
            icon: Icons.bolt_rounded,
            body:
                'FitWithSaju is a free, no-login fitness companion for planning workouts, tracking sets and personal records, exploring exercise demonstrations, and managing everyday nutrition in one place.',
          ),
          SizedBox(height: 12),
          _FeatureGrid(),
          SizedBox(height: 18),
          _InfoSection(
            title: 'Local-first by design',
            icon: Icons.phone_android_rounded,
            body:
                'Your workout history, body metrics, nutrition logs, hydration entries, preferences, and active-session state are stored locally on your device. Optional content sync is used for public exercise, recipe, and meal-plan content.',
          ),
          SizedBox(height: 12),
          _InfoSection(
            title: 'Nutrition information',
            icon: Icons.restaurant_rounded,
            body:
                'Nutrition values in bundled meal plans are estimates unless a review status says otherwise. FitWithSaju is not a substitute for individualized medical or dietetic advice.',
          ),
          SizedBox(height: 22),
          _VersionCard(),
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Data')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: const [
          _PrivacyHero(),
          SizedBox(height: 18),
          _InfoSection(
            title: 'Stored on this device',
            icon: Icons.lock_person_rounded,
            body:
                'Profile choices, weekly workout plans, custom workouts, favorites, workout history, set data, weight, measurements, nutrition preferences, meal plans, food logs, hydration, shopping-list state, and app settings are stored locally.',
          ),
          SizedBox(height: 12),
          _InfoSection(
            title: 'Optional content sync',
            icon: Icons.cloud_sync_rounded,
            body:
                'If you configure the Laravel content server, the app may download public exercise demonstrations, recipes, and meal-plan templates. Personal workout and nutrition logs are not uploaded by the current mobile architecture.',
          ),
          SizedBox(height: 12),
          _InfoSection(
            title: 'Backup & restore',
            icon: Icons.inventory_2_outlined,
            body:
                'Backup & Restore creates a JSON copy of your local FitWithSaju data for you to store or move manually. Anyone who receives that backup can read the data inside it, so keep it somewhere you trust.',
          ),
          SizedBox(height: 12),
          _InfoSection(
            title: 'Removing your data',
            icon: Icons.delete_outline_rounded,
            body:
                'Because the current app has no user account, uninstalling the app or clearing its storage removes local app data unless you created a backup first. Content cached from the optional server can be reset independently from Content Sync.',
          ),
          SizedBox(height: 12),
          _InfoSection(
            title: 'Health information',
            icon: Icons.health_and_safety_outlined,
            body:
                'Body measurements, weight and nutrition records can be sensitive. FitWithSaju keeps the current personal-data flows local and does not claim medical diagnosis, treatment, or professional nutrition approval.',
          ),
        ],
      ),
    );
  }
}

class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FitWithSaju Guide')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: const [
          _GuideHero(),
          SizedBox(height: 18),
          _GuideStep(
            number: '01',
            title: 'Plan your week',
            icon: Icons.calendar_month_rounded,
            body:
                'Open Workout, tap any weekday and choose the exercises for that day. You can copy a day, create rest days, or build reusable custom workouts.',
          ),
          _GuideStep(
            number: '02',
            title: 'Train and log every set',
            icon: Icons.fitness_center_rounded,
            body:
                'Start a workout, enter weight and reps, complete each set and use the rest timer. Interrupted sessions are saved so you can resume them later.',
          ),
          _GuideStep(
            number: '03',
            title: 'Explore movement demonstrations',
            icon: Icons.explore_rounded,
            body:
                'Use Explore to search by exercise, muscle, body part or equipment. Open an exercise to see the animation, instructions, favorites and strength history.',
          ),
          _GuideStep(
            number: '04',
            title: 'Review progress',
            icon: Icons.auto_graph_rounded,
            body:
                'Progress combines workouts, minutes, sets, volume, history and body-weight tracking. Personal Records and Achievements turn your saved sessions into long-term milestones.',
          ),
          _GuideStep(
            number: '05',
            title: 'Use the meal planner',
            icon: Icons.restaurant_menu_rounded,
            body:
                'Diet & Meal Plan supports weekly templates, day editing, food logging, hydration, meal swaps, saved meals and shopping lists. Planned and consumed nutrition remain separate.',
          ),
          _GuideStep(
            number: '06',
            title: 'Protect your data',
            icon: Icons.backup_rounded,
            body:
                'Use Backup & Restore before changing phones or clearing app storage. Content Sync can refresh public exercise and meal content without replacing your private local logs.',
          ),
        ],
      ),
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173D25), Color(0xFF285D2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Image.asset(
              'assets/images/fitwithsaju_logo.png',
              height: 72,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Move. Train. Progress.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A practical everyday fitness system built around consistency.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .78),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(Icons.shield_rounded, color: AppColors.primary),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Private by default',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5),
                Text(
                  'Your current personal fitness and nutrition records stay on your device unless you choose to export them yourself.',
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideHero extends StatelessWidget {
  const _GuideHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.map_rounded, color: AppColors.primary, size: 28),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your app, end to end',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5),
                Text(
                  'Use these six steps as the fastest path through FitWithSaju.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String body;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.fitness_center_rounded, 'Workout tracking'),
      (Icons.play_circle_outline_rounded, 'Exercise library'),
      (Icons.auto_graph_rounded, 'Progress & PRs'),
      (Icons.restaurant_rounded, 'Meal planning'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(item.$1, color: AppColors.primary, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'FitWithSaju 1.11.0 • Mobile + Content Admin',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;
  final String body;

  const _GuideStep({
    required this.number,
    required this.title,
    required this.icon,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: AppColors.primary),
                Positioned(
                  right: 4,
                  bottom: 3,
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
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
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
