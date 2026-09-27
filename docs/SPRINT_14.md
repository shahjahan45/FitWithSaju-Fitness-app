# Sprint 14 — Real Exercise Media Library

## Source used
The exercise catalog and media in this sprint are sourced from the user-provided `excisize.rar` archive.

## Implemented
- 30 exercises integrated
- Source exercise IDs retained
- Target muscles, secondary muscles, body parts, equipment, and instructions integrated
- 360×360 animated GIF thumbnails
- 720×720 animated GIF demonstrations
- Explore search across all exercise metadata
- Body-part filters
- Equipment filter sheet
- Animated exercise cards
- Hero-connected detail transition
- Animated detail media
- Active workout media
- Legacy local exercise IDs remain resolvable
- New weekly-plan seed uses source exercises
- TickerMode deprecation fix for Flutter 3.35+

## Performance choices
- Explore uses the supplied 360×360 GIFs in a lazy `ListView`.
- Detail and Active Workout use one 720×720 GIF at a time.
- Workout editors intentionally keep lightweight icons instead of eagerly decoding every GIF.
- No new Flutter package dependency is required.

## Device validation still required
Run `flutter analyze`, `flutter test`, and `flutter run --profile` on the target Android device.
