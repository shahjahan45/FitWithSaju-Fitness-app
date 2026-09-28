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


## v18 · Complete Meal Planning + High-Protein Week

- Added a professional 7-Day High-Protein plan based on the supplied reference: 4 meals/day and 190–205 g planned protein/day (about 196 g/day average).
- Added 27 stable high-protein recipe IDs with portions, ingredients, allergens, preparation steps, and estimated macros. Protein values follow the supplied reference; calories/carbs/fats remain clearly labeled estimates pending review.
- Added Meal Plan Library with safe allergy/dietary validation before applying a template.
- Added individual day-plan editing: servings, meal time, add meal, remove meal.
- Added unplanned food logging without altering the planned menu.
- Added meal-plan template sync from `/api/meal-plan-templates` with bundled/cached/live fallback.
- Added high-protein template and recipes to Laravel seed data.
- Hardened all nutrition modal bottom sheets with settled-route teardown before store-backed UI updates.
- Active plan selection is included in backup/restore.


## v19 Mobile Completeness & Professional Pages

- Added real Achievements calculated from local workout data.
- Replaced sparse About/Privacy dialogs with full professional pages.
- Added an in-app FitWithSaju Guide.
- Added professional empty states for Favorites, Saved Meals, Workout History, Measurements, Personal Records, Body Weight, and Exercise Strength History.
- Added search to Custom Workout and Day Plan exercise selectors.
- Added Workout History lifetime summary and Measurements latest snapshot.
- Added measurement-entry deletion.
- Improved empty Shopping List and Nutrition Day Editor states.
- Added profile summary card in More and Achievements shortcut in Progress.
