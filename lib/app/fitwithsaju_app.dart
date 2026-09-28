import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_root.dart';

class FitWithSajuApp extends StatelessWidget {
  const FitWithSajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitWithSaju',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppRoot(),
    );
  }
}
