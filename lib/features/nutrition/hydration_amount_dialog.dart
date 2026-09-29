import 'package:flutter/material.dart';

import '../../core/navigation/settled_dialog.dart';

/// Opens the custom hydration amount dialog and waits until its route has
/// completely left the overlay before returning.
///
/// The returned value is always millilitres so callers can persist it without
/// depending on the visible unit system.
Future<int?> showHydrationAmountDialog(
  BuildContext context, {
  required String units,
}) async {
  final controller = TextEditingController();
  final us = units == 'US customary';
  try {
    final entered = await showSettledDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add water'),
        content: TextField(
          key: const Key('hydration-custom-water-field'),
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount',
            suffixText: us ? 'fl oz' : 'ml',
          ),
          onSubmitted: (text) => Navigator.of(dialogContext).pop(
            int.tryParse(text),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('hydration-custom-water-add'),
            onPressed: () => Navigator.of(dialogContext).pop(
              int.tryParse(controller.text),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (entered == null || entered <= 0) {
      return null;
    }
    return us ? (entered * 29.5735).round() : entered;
  } finally {
    controller.dispose();
  }
}
