# v10 Validation

## Static checks completed in this environment

- Relative Dart imports checked: no missing local imports.
- Referenced local image assets checked: no missing assets.
- Structural delimiter audit completed across 30 Dart files: no unmatched delimiters found.
- Android Gradle wrapper retained at 8.14.
- Android Gradle Plugin retained at 8.11.1.
- Kotlin Gradle Plugin retained at 2.2.20.
- Existing v9 motion system retained.
- Added `test/local_store_workout_test.dart` for weekly-plan and custom-workout persistence behavior.

## Device/SDK checks still required

This execution environment does not contain Flutter/Dart or Android/iOS SDKs, so run locally:

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

Recommended physical-device checks:

- Edit every weekday and return to Home.
- Mark a day Rest and confirm Home reflects it on that weekday.
- Copy one day's workout to another day.
- Create, edit, start, and delete a custom workout.
- Favorite/unfavorite exercises and inspect Favorites.
- Add/delete body-weight entries with the keyboard open.
- Add body measurements.
- Complete workouts and confirm Progress and Personal Records update.
- Copy JSON backup data.
- Switch main navigation tabs repeatedly to confirm v9 state preservation and transitions remain smooth.
