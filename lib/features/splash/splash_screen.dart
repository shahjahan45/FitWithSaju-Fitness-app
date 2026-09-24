import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';
import '../shell/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.68, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: .90, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _lift = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Timer(const Duration(milliseconds: 2800), _finish);
  }

  Future<void> _finish() async {
    final done = await LocalStore.onboardingComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, __, ___) => done ? const MainShell() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .03),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF7FAFF), Color(0xFFEFF5FF)],
              ),
            ),
          ),
          Positioned(
            left: -80,
            top: -60,
            child: _BlurOrb(
              color: AppColors.secondary.withValues(alpha: .16),
              size: 240,
            ),
          ),
          Positioned(
            right: -90,
            top: 140,
            child: _BlurOrb(
              color: AppColors.primary.withValues(alpha: .16),
              size: 260,
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 150,
            child: Transform.rotate(
              angle: -.08,
              child: Container(
                height: 86,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: .14),
                      AppColors.primary.withValues(alpha: .18),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return FadeTransition(
                  opacity: _fade,
                  child: Transform.translate(
                    offset: Offset(0, _lift.value),
                    child: ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 330,
                        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .80),
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .85),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: .08),
                              blurRadius: 38,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/fitwithsaju_logo.png',
                              height: 210,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Move • Train • Progress',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (i) => AnimatedContainer(
                                  duration: Duration(milliseconds: 300 + (i * 90)),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == 1
                                        ? AppColors.secondary
                                        : AppColors.primary.withValues(alpha: .82),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 18,
          ),
        ],
      ),
    );
  }
}
