# v29 validation

Run locally with the Flutter SDK:

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

Relevant new tests:
- `test/weekly_review_test.dart`
- `test/weekly_review_ui_test.dart`

v29 intentionally does not add a Laravel migration or API change.

## Validation performed in the build environment
- Dart relative/package import resolution: PASS
- Dart lib/test delimiter/source-structure scan: PASS
- Laravel PHP syntax lint (`app`, `routes`, `config`, `database`): 49/49 PASS
- Flutter/Dart SDK executables are not installed in this build environment, so `dart format`, `flutter analyze` and `flutter test` must be executed in the local Flutter SDK environment using the commands above.
