import 'dart:async';

import 'package:flutter/material.dart';

import '../core/storage/local_store.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/splash/splash_screen.dart';

enum _AppPhase { splash, onboarding, main }

/// Stable application gate for startup, onboarding and the main app.
///
/// All three phase trees remain mounted for the lifetime of the application.
/// Switching phase only changes the visible IndexedStack child, so Flutter does
/// not have to deactivate Focus/MediaQuery/Ticker inherited dependents while a
/// tap, animation or text-field update is still completing.
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
    final activeIndex = _phase.index;
    final children = <Widget>[
      const SplashScreen(),
      OnboardingScreen(onComplete: _finishOnboarding),
      const MainShell(),
    ];

    return IndexedStack(
      key: const ValueKey('app-phase-stack'),
      index: activeIndex,
      sizing: StackFit.expand,
      children: List.generate(children.length, (index) {
        final active = index == activeIndex;
        return TickerMode(
          enabled: active,
          child: IgnorePointer(
            ignoring: !active,
            child: children[index],
          ),
        );
      }),
    );
  }
}
