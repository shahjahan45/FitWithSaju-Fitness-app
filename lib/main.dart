import 'dart:async';

import 'package:flutter/material.dart';

import 'app/fitwithsaju_app.dart';
import 'app/startup_bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Start local cache/settings loading immediately, but do not block the first
  // Flutter frame. This shortens the Android native splash handoff.
  unawaited(StartupBootstrap.ensureInitialized());

  runApp(const FitWithSajuApp());
}
