import 'package:flutter/material.dart';

/// Central motion tokens for FitWithSaju.
///
/// Keep navigation motion calm and short. All custom movement respects the
/// platform reduced-motion preference via [reducedMotion].
class AppMotion {
  AppMotion._();

  static const Duration mainNavigation = Duration(milliseconds: 250);
  static const Duration detail = Duration(milliseconds: 320);
  static const Duration detailReverse = Duration(milliseconds: 270);
  static const Duration modal = Duration(milliseconds: 280);
  static const Duration modalReverse = Duration(milliseconds: 250);
  static const Duration internalTab = Duration(milliseconds: 190);
  static const Duration authToHome = Duration(milliseconds: 330);
  static const Duration onboarding = Duration(milliseconds: 320);
  static const Duration success = Duration(milliseconds: 280);
  static const Duration fullScreen = Duration(milliseconds: 320);
  static const Duration reduced = Duration(milliseconds: 120);

  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve indicatorCurve = Curves.easeOutCubic;

  static const double mainNavigationSlide = 16;
  static const double detailSlideFraction = .045;

  static bool reducedMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations ?? false;
  }

  static Duration duration(BuildContext context, Duration normal) {
    return reducedMotion(context) ? reduced : normal;
  }
}

enum FitRouteMotion {
  detail,
  fullScreen,
  fadeScale,
  horizontal,
}

class FitRoutes {
  FitRoutes._();

  /// Creates a route while preserving the native iOS/macOS route gesture.
  /// Custom motion is used on the remaining platforms.
  static Route<T> route<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    FitRouteMotion motion = FitRouteMotion.detail,
  }) {
    final platform = Theme.of(context).platform;
    final preserveNativeBackGesture =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (preserveNativeBackGesture) {
      return MaterialPageRoute<T>(builder: builder);
    }

    final reduce = AppMotion.reducedMotion(context);
    final textDirection = Directionality.of(context);
    final trailingSign = textDirection == TextDirection.rtl ? -1.0 : 1.0;

    final normalDuration = switch (motion) {
      FitRouteMotion.detail => AppMotion.detail,
      FitRouteMotion.fullScreen => AppMotion.fullScreen,
      FitRouteMotion.fadeScale => AppMotion.authToHome,
      FitRouteMotion.horizontal => AppMotion.onboarding,
    };

    return PageRouteBuilder<T>(
      transitionDuration: reduce ? AppMotion.reduced : normalDuration,
      reverseTransitionDuration:
          reduce ? AppMotion.reduced : AppMotion.detailReverse,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.enterCurve,
          reverseCurve: AppMotion.exitCurve,
        );

        if (reduce) {
          return FadeTransition(opacity: curved, child: child);
        }

        switch (motion) {
          case FitRouteMotion.detail:
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(
                    AppMotion.detailSlideFraction * trailingSign,
                    0,
                  ),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          case FitRouteMotion.fullScreen:
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: .97, end: 1).animate(curved),
                child: child,
              ),
            );
          case FitRouteMotion.fadeScale:
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: .98, end: 1).animate(curved),
                child: child,
              ),
            );
          case FitRouteMotion.horizontal:
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(.08 * trailingSign, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
        }
      },
    );
  }
}
