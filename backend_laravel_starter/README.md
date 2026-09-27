# FitWithSaju Laravel Exercise Admin + Public API (v15 starter)

This folder contains the Laravel-side files for the FitWithSaju exercise catalog. The Flutter app still works completely offline; server sync is optional.

## What this backend starter adds

- Session-based admin login
- Admin-only middleware
- Exercise dashboard and CRUD
- Search + active/hidden filtering
- GIF/WebP/video media uploads
- Thumbnail uploads
- Activate/hide exercise without deleting it
- Soft deletes
- JSON public exercise API with pagination/search/filtering
- Seeder for the same 30 exercises bundled in the Flutter app
- Stable `source_id` values so workout plans/history continue to resolve after sync

## 1. Create a normal Laravel project

```bash
composer create-project laravel/laravel fitwithsaju-api
cd fitwithsaju-api
```

Configure MySQL in `.env`.

## 2. Copy the starter files

Copy the contents of `backend_laravel_starter/` into the matching Laravel directories. Merge `routes/web.php`, `routes/api.php`, and your existing `DatabaseSeeder` if those files already contain application code.

Register the `admin` middleware alias using `bootstrap_app_middleware_snippet.txt`.

## 3. Configure the admin account

Add to `.env`:

```env
FITWITHSAJU_ADMIN_NAME="FitWithSaju Admin"
FITWITHSAJU_ADMIN_EMAIL=admin@example.com
FITWITHSAJU_ADMIN_PASSWORD="CHANGE_THIS_TO_A_STRONG_PASSWORD"
```

Do not commit the real password.

## 4. Copy the bundled exercise GIFs into Laravel storage

From the FitWithSaju Flutter project, copy:

- `assets/exercises/media/*.gif` -> Laravel `storage/app/public/exercises/media/`
- `assets/exercises/thumbs/*.gif` -> Laravel `storage/app/public/exercises/thumbs/`

The included `ExerciseSeeder` already points each exercise ID to these paths.

On Windows you can copy both folders automatically from the Flutter project:

```powershell
.\backend_laravel_starter\copy_exercise_media.ps1 -LaravelPath "C:\path\to\fitwithsaju-api"
```

Then run:

```bash
php artisan storage:link
php artisan migrate
php artisan db:seed --class=ExerciseSeeder
php artisan db:seed --class=FitWithSajuAdminSeeder
```

## 5. Run locally

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Admin:

```text
http://YOUR-PC-IP:8000/admin/login
```

Mobile API:

```text
http://YOUR-PC-IP:8000/api/exercises?per_page=200
```

On a physical Android phone, do not use `localhost`; use the PC IPv4 address on the same Wi-Fi/LAN.

## 6. Connect the Flutter app

Open:

**More -> Exercise Content Sync**

Enter:

```text
http://YOUR-PC-IP:8000
```

Tap **Test & Sync Exercises**.

The Flutter app saves the downloaded catalog locally. If the server becomes unavailable, the cached catalog remains usable. **Use Bundled Offline Catalog** removes the downloaded catalog and immediately falls back to the 30 exercise animations shipped in the app.

## Production notes

- Use HTTPS in production.
- Keep `APP_URL` correct so exercise media URLs point to the public server.
- Restrict the admin account and use a strong password.
- The public exercise API intentionally has no end-user authentication because FitWithSaju mobile users do not log in.
- User workout history, measurements, plans, PRs and active sessions remain local to the device in the current architecture.
