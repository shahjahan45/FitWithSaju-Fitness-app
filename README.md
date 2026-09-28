# FitWithSaju v17.5

FitWithSaju is a no-login, offline-first Flutter fitness app with workout planning/tracking, animated exercise demonstrations, progress/PR tracking, Diet & Meal Plan, backup/restore, completed mobile settings, and an optional Laravel content-management backend.

## v17.5 mobile stabilization

- Reworked the startup/onboarding lifecycle to permanently mount Splash, Onboarding and MainShell in one root `IndexedStack`.
- Removed onboarding PageView/ExcludeFocus/route teardown patterns that could trigger Flutter `_dependents.isEmpty` assertions.
- Removed focus-exclusion wrappers from bottom-tab switching while preserving each page's state.
- Added real Settings for profile editing, haptics, sound, reduced motion and auto-sync.
- Added haptic/sound feedback to navigation and workout milestones.
- Backup format v3 now includes onboarding profile and app settings in addition to existing workout/nutrition data.
- Existing Android Diet bottom-sheet SafeArea fix, PHP 8.5 backend compatibility and SaaS admin redesign are retained.

## Flutter

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

For a lifecycle fix like this, uninstall the previous debug APK before the first run of v17.5 so the test starts from a clean process/state.

## Laravel

```powershell
cd backend_laravel
composer install
php artisan optimize:clear
php artisan storage:link
php artisan migrate
php artisan db:seed
php artisan serve --host=0.0.0.0 --port=8000
```

Admin URL: `http://YOUR-PC-IP:8000/admin/login`

Version: `1.9.5+20`
