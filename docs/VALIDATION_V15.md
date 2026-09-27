# v15 validation

Static checks performed in the build environment:

- Relative Dart imports resolve
- Referenced Flutter assets exist
- Android manifest XML parses
- Main release manifest includes INTERNET permission
- Cleartext HTTP is enabled only in the Android debug manifest for LAN development
- No new Flutter package dependency added
- 30 bundled exercises remain present
- Exercise API model mapping tests added
- Laravel seed data generated from the same supplied 30-exercise metadata
- PHP `-l` syntax validation passed for all included backend PHP files
- ZIP integrity checked before delivery

Still run on the developer machine:

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

Laravel validation after copying the starter into a real Laravel application:

```bash
php artisan migrate
php artisan db:seed --class=ExerciseSeeder
php artisan db:seed --class=FitWithSajuAdminSeeder
php artisan storage:link
php artisan route:list
```
