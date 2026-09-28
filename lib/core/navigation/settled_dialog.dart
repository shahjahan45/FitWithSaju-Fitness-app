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
