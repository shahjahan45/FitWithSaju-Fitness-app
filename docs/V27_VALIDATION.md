# FitWithSaju v27 Validation

Run from the Flutter project root:

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

New v27 coverage is in `test/training_balance_test.dart` and `test/training_balance_ui_test.dart` and checks:

- 7-day versus previous 3-week baseline calculation
- legacy numeric-string training volume
- empty-baseline handling
- readiness-aware optional guidance under elevated load
- reduced-motion-safe Training Balance rendering and lazy plan-preview materialization

The development sandbox used to package this build does not include Flutter/Dart binaries, so Flutter analyzer/test execution must be completed on the target Flutter workstation.
