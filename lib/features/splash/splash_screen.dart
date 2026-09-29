import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';

/// Pure visual splash screen.
///
/// Android's native launch splash hands off to this screen as soon as Flutter
/// can draw. The full FitWithSaju lockup is rendered with BoxFit.contain so the
/// artwork is never cropped on narrow/tall phones.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .72, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: .94, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _lift = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reducedMotion(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF7),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFAFCF8), Color(0xFFF3F7F1)],
              ),
            ),
          ),
          Positioned(
            left: -120,
            top: -145,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: .05),
              ),
            ),
          ),
          Positioned(
            right: -130,
            bottom: -150,
            child: Container(
              width: 370,
              height: 370,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: .035),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return FadeTransition(
                    opacity: _fade,
                    child: Transform.translate(
                      offset: Offset(0, reduceMotion ? 0 : _lift.value),
                      child: Transform.scale(
                        scale: reduceMotion ? 1 : _scale.value,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final available = constraints.maxWidth * .70;
                            final logoWidth =
                                available.clamp(220.0, 310.0).toDouble();
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Semantics(
                                  image: true,
                                  label: 'FitWithSaju',
                                  child: SizedBox(
                                    width: logoWidth,
                                    child: Image.asset(
                                      'assets/images/fitwithsaju_logo.png',
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      filterQuality: FilterQuality.high,
                                      gaplessPlayback: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Every day stronger.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: .1,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: 68,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child: LinearProgressIndicator(
                                      value: _controller.value,
                                      minHeight: 4,
                                      backgroundColor: AppColors.border,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
