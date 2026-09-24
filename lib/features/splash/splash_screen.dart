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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0, .72, curve: Curves.easeOut));
    _scale = Tween<double>(begin: .76, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    Timer(const Duration(milliseconds: 2450), _finish);
  }

  Future<void> _finish() async {
    final done = await LocalStore.onboardingComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 550),
      pageBuilder: (_, __, ___) => done ? const MainShell() : const OnboardingScreen(),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        const DecoratedBox(decoration: BoxDecoration(
          gradient: RadialGradient(center: Alignment(0, -.18), radius: 1.15,
            colors: [Color(0xFF251209), Color(0xFF07111B), AppColors.background]),
        )),
        Positioned(left: -100, top: 180, child: _Glow(color: AppColors.secondary.withValues(alpha: .17), size: 260)),
        Positioned(right: -100, top: 250, child: _Glow(color: AppColors.primary.withValues(alpha: .17), size: 260)),
        Center(child: FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Image.asset('assets/images/fitwithsaju_logo.png', fit: BoxFit.contain),
          ),
        ))),
        Positioned(left: 44, right: 44, bottom: 70, child: AnimatedBuilder(animation: _controller, builder: (_, __) =>
          LinearProgressIndicator(value: _controller.value, minHeight: 3, borderRadius: BorderRadius.circular(99),
            backgroundColor: AppColors.border, color: AppColors.primary),
        )),
      ]),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color; final double size;
  const _Glow({required this.color, required this.size});
  @override Widget build(BuildContext context) => Container(width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 20)]));
}
