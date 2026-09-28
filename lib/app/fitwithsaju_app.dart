import 'package:flutter/material.dart';

import '../core/settings/app_preferences.dart';
import '../core/theme/app_theme.dart';
import 'app_root.dart';

class FitWithSajuApp extends StatelessWidget {
  const FitWithSajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppPreferenceState>(
      valueListenable: AppPreferences.listenable,
      builder: (context, _, __) {
        return MaterialApp(
          title: 'FitWithSaju',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const AppRoot(),
        );
      },
    );
  }
}
