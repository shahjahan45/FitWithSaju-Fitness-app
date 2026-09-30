# FitWithSaju v26 validation

## Added/updated tests

- legacy string training-volume parsing
- legacy string program-duration parsing
- very short deload duration safety
- Material ancestor safety for animated decorated content
- narrow Android Home layout regression coverage
- weekly recovery review calculation
- weekly recovery review reduced-motion UI rendering

## Flutter commands to run locally

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

## Current execution environment

This packaging environment does not include `flutter` or `dart`, so those commands cannot be truthfully reported as executed here. Static source/import checks, Laravel PHP syntax checks, and ZIP integrity are performed before packaging.

## Validation completed in packaging environment

```text
Dart import-path check: PASS
Dart delimiter structure check: PASS
Laravel PHP syntax: PASS (49 files)
Known v24 blocker WorkoutCalendarScreen._shortDate: absent
```
