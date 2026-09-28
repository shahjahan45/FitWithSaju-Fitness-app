import 'package:flutter/material.dart';

/// Shows a Material dialog and does not return its result until the dialog's
/// reverse transition has fully finished and its overlay entries are removed.
///
/// `showDialog` completes its returned future as soon as the route is popped,
/// before the reverse animation/overlay teardown has necessarily finished.
/// Waiting for [TransitionRoute.completed] avoids rebuilding a store-backed
/// screen while TextField/MediaQuery/Focus dependents are still deactivating.
Future<T?> showSettledDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) async {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final route = DialogRoute<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
  );

  final result = await navigator.push<T>(route);
  await route.completed;
  return result;
}

/// Shows a Material modal bottom sheet and waits until its reverse transition
/// has completed and all overlay entries are removed before returning.
///
/// This is useful for store-backed screens: updating a notifier immediately
/// after a normal [showModalBottomSheet] result can rebuild inherited-widget
/// dependents while the sheet is still being deactivated.
Future<T?> showSettledModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Color? barrierColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  bool useSafeArea = false,
}) async {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final localizations = MaterialLocalizations.of(context);
  final route = ModalBottomSheetRoute<T>(
    builder: builder,
    capturedThemes: InheritedTheme.capture(
      from: context,
      to: navigator.context,
    ),
    isScrollControlled: isScrollControlled,
    barrierLabel: localizations.scrimLabel,
    barrierOnTapHint:
        localizations.scrimOnTapHint(localizations.bottomSheetLabel),
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    isDismissible: isDismissible,
    modalBarrierColor:
        barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
  );
  final result = await navigator.push<T>(route);
  await route.completed;
  return result;
}
