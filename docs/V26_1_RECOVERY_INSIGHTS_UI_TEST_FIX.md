# FitWithSaju v26.1 — Recovery Insights UI Test Hotfix

## Fixed

The reduced-motion Recovery Insights widget test could fail because it expected the 28-day chart to already exist in the initial widget-test viewport. `FitScrollableScreen` correctly uses a lazily built `ListView`, so children below the viewport/cache boundary are not guaranteed to be materialized immediately on every Flutter version or test surface.

The test now:

- uses a deterministic anchor date;
- renders `RecoveryInsightsScreen` with that anchor date;
- verifies the overview, weekly review, and fitness-guidance content first;
- explicitly checks for unexpected Flutter exceptions;
- scrolls the actual Recovery Insights list until the chart section is materialized;
- verifies the chart and checks again for runtime exceptions.

`RecoveryInsightsScreen` accepts an optional `anchorDate` only for deterministic loading/testing. Normal app navigation continues to omit it and therefore uses the current local calendar date exactly as before.

## Version

`1.18.1+34`

## Local validation

Run on a Flutter workstation:

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```
