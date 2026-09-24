# FitWithSaju Starter

A Phase-2 Flutter starter for the FitWithSaju fitness application.

## Included now

- Premium animated splash screen
- No-login first-use onboarding
- Main animated bottom navigation
- Home dashboard
- Weekly workout strip
- Today's workout card
- Quick workout categories
- Exercise library with search/filter-ready structure
- Exercise details
- Active workout foundation
- Rest timer UI foundation
- Progress dashboard
- Settings screen
- Sample exercise/workout models and local demo repository
- Laravel backend starter folder with migrations/routes/controller examples
- Android platform structure and AndroidManifest

## Design direction

- Deep graphite / black sports-performance UI
- Electric lime-green highlight
- Smooth motion and micro-interactions
- Large rounded cards and clear typography
- No user authentication required

## Run on your PC

1. Extract this ZIP.
2. Open the `FitWithSaju_Starter` folder in VS Code or Android Studio.
3. Run:

```bash
flutter clean
flutter pub get
flutter run
```

If your local Flutter version wants to refresh the Android/iOS platform files, run:

```bash
flutter create .
flutter pub get
flutter run
```

The `lib/` source in this package is the important FitWithSaju application source and will be preserved.

## Next development milestone

Next recommended work:
1. Local database persistence (Isar/SQLite)
2. Editable daily workout planner
3. Real set/rep/weight tracking
4. Workout history
5. Exercise GIF/WebP media API
6. Laravel admin dashboard CRUD
7. Flutter/Laravel API connection

## Backend starter

The `backend_laravel_starter/` directory contains starter Laravel application code to merge into a fresh Laravel project.

Create a Laravel project on a machine with Composer:

```bash
composer create-project laravel/laravel fitwithsaju-api
```

Then copy the starter files into the matching folders and run:

```bash
php artisan migrate
php artisan serve --host=0.0.0.0 --port=8000
```

This starter intentionally does not require app-user authentication. Admin authentication is planned separately.


## v2 continuation included
- Official supplied FitWithSaju logo integrated
- Branded Android launcher icon
- Persistent onboarding/profile preferences with SharedPreferences
- Persistent exercise favorites
- Editable workout weight/reps
- Completed workout history persistence and history screen
- Custom workout builder foundation
- Orange + blue brand accent system matched to logo
