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

## v19.2 · Global Android Safe-Area Layout

- Added `FitScrollableScreen`, `FitSafeBody`, and `fitPagePadding()` as reusable safe-area layout primitives.
- Bottom content spacing now uses the real `MediaQuery.viewPadding.bottom` plus normal visual breathing room instead of fixed bottom-only padding.
- Fixed Settings so the Local-first personal data card has natural content height and can scroll fully above Android system navigation.
- Rebuilt Backup & Restore as a fully scrollable page with a bounded internal JSON viewer and responsive Import/Copy actions.
- Import Backup now uses a keyboard-safe body and responsive action layout.
- Applied safe bottom padding to standalone Nutrition, More, Progress, Workout, and Explore detail screens so the same Android navigation-bar overlap does not reappear elsewhere.
- Added safe-area regression tests for both 3-button-style and gesture-style bottom insets.

Version: `1.11.2+25`


## v19.3 test stabilization
- Hydration lifecycle widget test now uses stable widget keys and `tester.ensureVisible()` instead of an ambiguous global `scrollUntilVisible()`.
- Added stable keys for the custom water amount field and submit button.
- No runtime hydration behavior or UI design changed.

## v20 · Startup Branding & Performance

- Added Android mask-safe native splash artwork so the full FitWithSaju runner, wordmark and tagline remain visible.
- Separated adaptive launcher artwork from native splash artwork.
- Improved Flutter splash sizing with `BoxFit.contain` and responsive layout.
- Moved non-critical catalog/cache startup work behind the first Flutter frame for a faster handoff from the Android splash.

## v21 · Workout Programs

- Added Foundation 3-Day, Strength 4-Day and Hypertrophy 5-Day weekly training structures.
- Program application safely replaces the Monday–Sunday weekly plan without deleting workout history, PRs, measurements or nutrition data.
- Hydration lifecycle regression coverage now tests the reusable custom-water dialog directly.

## v22 · Active Program Tracking

- Workout programs are now multi-week enrollments instead of one-time templates.
- Added persistent active-program state, start date, duration, training-day count and archived program history.
- Program workouts use stable `program_<program>_<day>` session IDs for real progress attribution.
- Added Active Program dashboard with week number, adherence, total completion, weekly schedule, next session and start-today action.
- Added Active Program cards to Workout and Progress.
- Program switching archives the previous enrollment; ending/finishing a program preserves the weekly plan and all workout history.
- Backup format v4 includes active-program state and program history.

Version: `1.14.0+29`
