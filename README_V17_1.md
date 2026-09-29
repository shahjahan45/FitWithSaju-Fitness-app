# FitWithSaju v17.1 corrective release

- Replaced the Laravel patch folder with a complete `backend_laravel/` source tree.
- Added `.env`, `.env.example`, `composer.json`, `artisan`, bootstrap/config/public/storage/tests and standard Laravel directories.
- Registered the `admin` middleware directly in `bootstrap/app.php`.
- Added default Laravel user/cache/jobs migrations and the real `DatabaseSeeder.php`.
- Fixed onboarding completion/navigation re-entry and disposed the `PageController`.
- Hardened `PressableScale` so gesture callbacks do not establish inherited-widget dependencies during route teardown.
- Added dynamic Android bottom-system-inset handling to nutrition bottom sheets via `MediaQuery.viewPadding.bottom`.
- `Log eaten` now stays fully above 3-button and gesture navigation areas.

Version: 1.9.1+16
