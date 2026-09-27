# FitWithSaju v14

FitWithSaju is a no-login, offline-first Flutter workout tracker.

## v14 highlights

- Integrated the user-provided exercise catalog from `excisize.rar`
- 30 source exercises with supplied IDs, muscles, body parts, equipment, secondary muscles, and instructions
- 30 animated 360×360 GIF thumbnails for Explore
- 30 animated 720×720 GIF demonstrations for Exercise Detail and Active Workout
- Search across name, target muscle, secondary muscle, body part, and equipment
- Animated body-part filter chips
- Equipment filter bottom sheet
- Professional exercise cards with real motion thumbnails
- Hero transition from exercise thumbnail to the full exercise demonstration
- Step-by-step instruction cards sourced from the supplied exercise metadata
- Real exercise media shown during active workouts
- Existing v12/v13 locally-saved workout IDs remain resolvable for backward compatibility
- New-install weekly plan seeds now use exercises from the supplied catalog
- Updated `TickerMode.of(context)` calls to `TickerMode.valuesOf(context).enabled`
- All v13 motion, workout recovery, PR tracking, strength trends, and backup/restore features retained

Version: `1.6.0+10`

## Exercise media layout

- `assets/exercises/data/` — supplied JSON metadata
- `assets/exercises/thumbs/` — supplied 360×360 GIFs
- `assets/exercises/media/` — supplied 720×720 GIFs

## Run

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

For physical-device performance validation:

```bash
flutter run --profile
```

Because the full supplied GIF catalog is bundled locally, the project/app size is intentionally larger than v13.
