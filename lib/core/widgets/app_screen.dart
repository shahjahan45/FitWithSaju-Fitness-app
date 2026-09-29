import 'package:flutter/material.dart';

/// Shared page-safe spacing for standalone FitWithSaju screens.
///
/// The bottom spacing is the device's real system navigation/gesture inset plus
/// the requested visual breathing room. This keeps the final control/card able
/// to scroll fully above Android system UI on 3-button and gesture navigation.
EdgeInsets fitPagePadding(
  BuildContext context, {
  double horizontal = 20,
  double top = 8,
  double bottom = 24,
}) {
  final systemBottomInset = MediaQuery.viewPaddingOf(context).bottom;
  return EdgeInsets.fromLTRB(
    horizontal,
    top,
    horizontal,
    systemBottomInset + bottom,
  );
}

class FitScrollableScreen extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final double horizontalPadding;
  final double topPadding;
  final double bottomSpacing;
  final ScrollPhysics? physics;
  final Key? listKey;

  const FitScrollableScreen({
    super.key,
    required this.children,
    this.controller,
    this.horizontalPadding = 20,
    this.topPadding = 8,
    this.bottomSpacing = 24,
    this.physics,
    this.listKey,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        key: listKey,
        controller: controller,
        physics: physics,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: fitPagePadding(
          context,
          horizontal: horizontalPadding,
          top: topPadding,
          bottom: bottomSpacing,
        ),
        children: children,
      ),
    );
  }
}

/// Safe non-scrollable body for input-heavy screens.
///
/// SafeArea owns the actual navigation inset while [bottomSpacing] provides the
/// extra visual space requested by the FitWithSaju layout. Scaffold's default
/// `resizeToAvoidBottomInset` keeps this body above the software keyboard.
class FitSafeBody extends StatelessWidget {
  final Widget child;
  final double horizontalPadding;
  final double topPadding;
  final double bottomSpacing;

  const FitSafeBody({
    super.key,
    required this.child,
    this.horizontalPadding = 20,
    this.topPadding = 8,
    this.bottomSpacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      maintainBottomViewPadding: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding,
          horizontalPadding,
          bottomSpacing,
        ),
        child: child,
      ),
    );
  }
}
