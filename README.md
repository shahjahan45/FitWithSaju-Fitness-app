# FitWithSaju v17.2

Laravel PHP 8.5 / Composer compatibility fixes are included in `backend_laravel/`.

# FitWithSaju v17.1

FitWithSaju is a no-login, offline-first Flutter fitness app with workout tracking, an animated exercise library, Diet & Meal Plan, local progress/backup, and an optional Laravel content-management backend.

## This corrective release

- Fixes onboarding/level-completion navigation instability that could produce Flutter's `_dependents.isEmpty` red-screen assertion.
- Guards onboarding transitions against rapid/double submission.
- Disposes the onboarding `PageController` correctly.
- Hardens the shared `PressableScale` gesture lifecycle so it does not register inherited dependencies during route teardown.
- Fixes nutrition modal sheets for Android system navigation using `MediaQuery.viewPadding.bottom`.
- The visible bottom-sheet surface now ends above the Android 3-button / gesture-navigation area.
- `Log eaten` stays fully visible and clickable above system navigation.
- Replaces the previous Laravel starter/patch with a complete `backend_laravel/` project source tree.
- Adds both `backend_laravel/.env` (local development) and `backend_laravel/.env.example`.

## Flutter

Run:

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

For device performance testing:

```bash
flutter run --profile
```

## Laravel

The complete backend is in:

```text
backend_laravel/
```

Start with:

```powershell
cd backend_laravel
composer install
php artisan storage:link
php artisan migrate
php artisan db:seed
php artisan serve --host=0.0.0.0 --port=8000
```

Before physical-phone content sync, update `APP_URL` in `backend_laravel/.env` to your PC LAN IPv4 address.

See `backend_laravel/README.md` for full setup and the local development admin credentials.

## Bundled content

- 30 exercise definitions with local animated GIF demonstrations
- 12 nutrition recipes with local Figma artwork fallback
- Offline workout plans and nutrition data
- Optional Laravel exercise/recipe/meal-template content sync

Version: `1.9.1+16`

## v17.3 onboarding lifecycle fix

The startup/onboarding chain no longer uses Navigator route replacement/removal.
`AppRoot` owns Splash -> Onboarding -> Main as application state, and onboarding
uses an `IndexedStack` rather than `PageView`. This keeps the four setup steps
mounted and avoids the inherited-widget teardown condition that could surface as:

`framework.dart: '_dependents.isEmpty': is not true`

When testing this corrective build on Android, uninstall the previous debug app
once before reinstalling to ensure stale hot-reload state is not retained.
