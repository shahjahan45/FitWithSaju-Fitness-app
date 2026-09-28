# FitWithSaju v17.1 · Backend + Android Sheet/Onboarding Fixes

Version: **1.9.1+16**

This build keeps the v17 nutrition/exercise content sync and adds three corrective changes:

1. A complete Laravel project source under `backend_laravel/`, including `.env`, `.env.example`, `artisan`, Composer config, bootstrap/config/public/storage/tests, migrations and seeders.
2. A guarded onboarding completion route that prevents duplicate async navigation and avoids the reported `_dependents.isEmpty` red-screen failure.
3. System-navigation-aware nutrition bottom sheets. Their visible surface is offset above `MediaQuery.viewPadding.bottom`, so the `Log eaten` CTA does not overlap Samsung/Android navigation buttons or gesture insets.

See `backend_laravel/README.md` and `README_V17_1.md` for setup/details.
