import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/local_store.dart';
import '../../core/widgets/primary_button.dart';
import '../shell/main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  String goal = 'Build Muscle';
  String level = 'Beginner';
  String place = 'Gym';

  Future<void> _continue() async {
    if (_page < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      await LocalStore.saveProfile(goal: goal, level: level, place: place);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _SelectionPage(
        eyebrow: 'YOUR GOAL',
        title: 'What are you training for?',
        subtitle: 'Choose a direction. You can change this anytime.',
        options: const [
          'Build Muscle',
          'Lose Weight',
          'Stay Fit',
          'Increase Strength',
          'Improve Mobility',
          'Home Training',
        ],
        selected: goal,
        onSelected: (v) => setState(() => goal = v),
      ),
      _SelectionPage(
        eyebrow: 'YOUR LEVEL',
        title: 'Where are you starting?',
        subtitle: 'We will keep the experience simple and practical.',
        options: const ['Beginner', 'Intermediate', 'Advanced'],
        selected: level,
        onSelected: (v) => setState(() => level = v),
      ),
      _SelectionPage(
        eyebrow: 'TRAINING PLACE',
        title: 'Where do you usually train?',
        subtitle: 'FitWithSaju works for gym and home workouts.',
        options: const ['Gym', 'Home', 'Both'],
        selected: place,
        onSelected: (v) => setState(() => place = v),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async { await LocalStore.skipOnboarding(); if (!context.mounted) return; Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell())); },
            child: const Text(
              'Skip',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (v) => setState(() => _page = v),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: i == _page ? 28 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: i == _page
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: _page == 2 ? 'Start My Journey' : 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _continue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionPage extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _SelectionPage({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -.8,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: selected == option
                      ? AppColors.primary.withValues(alpha: .10)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected == option
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      selected == option
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: selected == option
                          ? AppColors.primary
                          : AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
