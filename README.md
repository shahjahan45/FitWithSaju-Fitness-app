# FitWithSaju v11

FitWithSaju is a no-login, local-first Flutter workout tracker.

## New in v11

- Every completed set now saves actual weight and reps
- Previous-set values are shown and reused as workout input defaults
- Automatic exercise PR detection
- Live PR feedback during a workout
- Session training-volume calculation
- Rich workout-history details with exercise/set breakdown
- Weekly training-volume chart
- Exercise-specific Personal Records
- Double-tap protection while completing a set

## Existing features retained

- Professional motion/navigation system
- Editable Monday–Sunday workout plans
- Custom workouts
- Favorites
- Body-weight and measurements tracking
- JSON data export
- Transparent FitWithSaju splash/app icon
- No user login required

## Run

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

Version: 1.3.0+7
