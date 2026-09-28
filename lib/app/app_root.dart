import 'dart:async';

import 'package:flutter/material.dart';

import '../core/storage/local_store.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/splash/splash_screen.dart';

enum _AppPhase { splash, onboarding, main }

/// Owns the startup/onboarding state without creating/removing Navigator routes.
///
/// Keeping this flow route-free avoids tearing down Navigator/Overlay inherited
/// elements while onboarding buttons or page transitions are still settling.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  _AppPhase _phase = _AppPhase.splash;
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveStartup());
  }

  Future<void> _resolveStartup() async {
    if (_resolving) {
      return;
    }
    _resolving = true;

    try {
      final results = await Future.wait<Object>([
        Future<Object>.delayed(
          const Duration(milliseconds: 2450),
          () => true,
        ),
        LocalStore.onboardingComplete(),
      ]);

      if (!mounted) {
        return;
      }

      final onboardingComplete = results[1] as bool;
      setState(() {
        _phase = onboardingComplete ? _AppPhase.main : _AppPhase.onboarding;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      // A storage-read failure should never strand the user on splash.
      setState(() => _phase = _AppPhase.onboarding);
    } finally {
      _resolving = false;
    }
  }

  void _finishOnboarding() {
    if (!mounted || _phase == _AppPhase.main) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _phase = _AppPhase.main);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _AppPhase.splash => const SplashScreen(),
      _AppPhase.onboarding => OnboardingScreen(
          onComplete: _finishOnboarding,
        ),
      _AppPhase.main => const MainShell(),
    };
  }
}
