import 'package:flutter/material.dart';

import 'nutrition_widgets.dart';

/// A bottom-sheet surface that ends above the device system-navigation area.
///
/// The modal route itself should use `backgroundColor: Colors.transparent` and
/// `showDragHandle: false`. This widget then draws the visible sheet surface
/// above [MediaQuery.viewPadding.bottom], so neither the button nor the sheet
/// background sits behind Android 3-button/gesture navigation.
class NutritionBottomSheetSafeArea extends StatelessWidget {
  final Widget child;
  final EdgeInsets contentPadding;
  final double extraBottomSpacing;
  final bool avoidKeyboard;
  final bool showDragHandle;
  final Color backgroundColor;

  const NutritionBottomSheetSafeArea({
    super.key,
    required this.child,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 4, 20, 0),
    this.extraBottomSpacing = 16,
    this.avoidKeyboard = true,
    this.showDragHandle = true,
    this.backgroundColor = NutritionPalette.canvas,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final keyboardInset =
        avoidKeyboard ? MediaQuery.viewInsetsOf(context).bottom : 0.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Padding(
        // This transparent gap is the Android/iOS system navigation area.
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Material(
          color: backgroundColor,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDragHandle) ...[
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: NutritionPalette.ink.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Padding(
                padding: contentPadding.copyWith(
                  bottom: contentPadding.bottom + extraBottomSpacing,
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
