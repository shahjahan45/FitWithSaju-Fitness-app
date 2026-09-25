import 'package:flutter/material.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
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

  Future<void> _next() async {
    if (_page < 3) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      await LocalStore.saveProfile(goal: goal, level: level, place: place);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    }
  }

  Future<void> _skip() async {
    await LocalStore.skipOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _IntroPage(onStart: _next),
      _SelectionPage(
        eyebrow: 'YOUR GOAL',
        title: 'What are you training for?',
        subtitle: 'Choose your focus to personalize the FitWithSaju experience.',
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
        subtitle: 'We will keep every workout simple, practical, and motivating.',
        options: const ['Beginner', 'Intermediate', 'Advanced'],
        selected: level,
        onSelected: (v) => setState(() => level = v),
      ),
      _SelectionPage(
        eyebrow: 'TRAINING PLACE',
        title: 'Where do you usually train?',
        subtitle: 'Choose the place that matches your daily routine.',
        options: const ['Gym', 'Home', 'Both'],
        selected: place,
        onSelected: (v) => setState(() => place = v),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_page > 0)
            TextButton(
              onPressed: _skip,
              child: const Text('Skip', style: TextStyle(color: AppColors.muted)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF9FBFD), Color(0xFFF2F6FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (v) => setState(() => _page = v),
                  children: pages,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: i == _page ? 26 : 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: i == _page ? AppColors.secondary : const Color(0xFFBCC8D8),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (_page > 0)
                      PrimaryButton(
                        label: _page == 3 ? 'Start My Journey' : 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _next,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  final VoidCallback onStart;
  const _IntroPage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -120,
          top: -90,
          child: Container(
            width: 330,
            height: 330,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withOpacity(.08),
            ),
          ),
        ),
        Positioned(
          left: -80,
          right: -80,
          bottom: -20,
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              color: AppColors.secondary.withOpacity(.07),
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 110,
          child: Opacity(
            opacity: .08,
            child: Icon(
              Icons.directions_run_rounded,
              size: 210,
              color: AppColors.secondary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Image.asset(
                'assets/images/fitwithsaju_logo.png',
                width: 240,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              const Text(
                'Move. Train. Progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17307A),
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Build strength. Move better. Live stronger.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 1),
              Container(
                width: double.infinity,
                height: 66,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(.22),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4AB0FF), Color(0xFF1267FF)],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: onStart,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 30),
                          SizedBox(width: 12),
                          Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              eyebrow,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            height: 1.06,
            fontWeight: FontWeight.w900,
            letterSpacing: -.8,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 16,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: selected == option ? AppColors.primarySoft : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selected == option ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Icon(
                      selected == option ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: selected == option ? AppColors.primary : AppColors.muted,
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
