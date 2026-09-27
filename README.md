# FitWithSaju v15

FitWithSaju is a no-login, offline-first Flutter workout tracker with an optional Laravel-managed public exercise catalog.

## v15 highlights

- Keeps the user-provided 30-exercise GIF library bundled in the mobile app
- Adds optional Laravel exercise content synchronization
- Remote exercise data is cached locally for offline use
- Configured API refreshes automatically in the background after app startup
- Network GIF/WebP media falls back to the matching bundled GIF when available
- **More -> Exercise Content Sync** shows Live / Cached / Offline state
- API URL can be tested and saved directly from the mobile app
- Explore shows current catalog source status
- Workout planner/custom workouts resolve against the active catalog
- Existing legacy exercise IDs remain supported
- Android local HTTP is permitted only in debug builds for LAN testing
- Release builds remain intended for HTTPS

## Laravel admin starter

`backend_laravel_starter/` now includes:

- session-based admin login
- admin-only middleware
- professional light dashboard
- exercise CRUD
- exercise activation/hiding
- soft deletes
- GIF/WebP media upload
- thumbnail upload
- searchable/filterable public exercise API
- seed data for the same 30 supplied exercises
- environment-controlled admin user seeder

See `backend_laravel_starter/README.md` for setup.

## Exercise assets

- `assets/exercises/data/` — supplied JSON metadata
- `assets/exercises/thumbs/` — 360×360 bundled GIF thumbnails
- `assets/exercises/media/` — 720×720 bundled GIF demonstrations

## Run Flutter

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

Version: `1.8.0+13`


## Sprint 16 — Diet & Meal Plan (Flutter-first)

The Figma-referenced Diet & Meal Plan module is implemented locally before backend wiring.

Included:
- Daily and weekly meal plans with persisted date selection
- Planned vs consumed macro totals
- Meal details, serving/yield controls, ingredients and instructions
- Allergy/diet-aware meal alternatives with undo
- Food logging with historical nutrition snapshots and duplicate protection
- Hydration quick-add, custom/editable entries, history and undo
- Saved meals
- Generated shopping list with independent check state and add/edit/remove manual items
- Nutrition preferences, user-configured macro/water targets and unit preference
- Home shortcut + More entry
- Existing FitWithSaju motion/navigation system
- Four exact local nutrition illustrations exported from the supplied Figma design
- Backup & Restore includes nutrition state

The Laravel nutrition API/admin portion is intentionally deferred. Existing backend files are retained unchanged.
