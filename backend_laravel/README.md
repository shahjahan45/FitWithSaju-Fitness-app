# FitWithSaju Laravel Backend (complete project source)

This directory is now a **complete Laravel application source tree**, not a patch/starter folder. It contains `artisan`, `composer.json`, `bootstrap/`, `config/`, `public/`, `routes/`, `app/`, `database/`, `resources/`, `storage/`, tests, `.env.example`, and a local-development `.env`.

> `vendor/` and `node_modules/` are intentionally not included. Install them on your machine with Composer/NPM.

## Requirements

- PHP 8.2+
- Composer
- MySQL / MariaDB
- PHP extensions normally required by Laravel (`pdo_mysql`, `mbstring`, `openssl`, `fileinfo`, etc.)

## 1. Open the backend folder

```powershell
cd backend_laravel
```

## 2. Install Laravel dependencies

```powershell
composer install
```

The ZIP already contains a local `.env` for XAMPP-style MySQL development and a `.env.example` template. The included `.env` is **development-only**. Change the admin password before using the app outside your own computer/network.

If you prefer to recreate `.env`:

```powershell
copy .env.example .env
php artisan key:generate
```

## 3. Create the MySQL database

Create an empty database named:

```text
fitwithsaju
```

The included development `.env` expects:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fitwithsaju
DB_USERNAME=root
DB_PASSWORD=
```

Change those values when your MySQL credentials are different.

## 4. Configure the phone-accessible URL

For Android LAN testing, change `APP_URL` in `.env` from `127.0.0.1` to your PC IPv4 address, for example:

```env
APP_URL=http://192.168.1.25:8000
```

This is important because exercise/recipe media URLs returned by the API use `APP_URL`.

## 5. Migrate, seed and create the public storage link

```powershell
php artisan storage:link
php artisan migrate
php artisan db:seed
```

The seeder creates the FitWithSaju admin account using the `.env` values and seeds the bundled exercise/recipe/template IDs used by Flutter.

Development credentials in the supplied `.env`:

```text
Email: admin@fitwithsaju.local
Password: ChangeMe123!
```

**Change this password in `.env` before a real deployment.** If you already seeded once, update/delete the existing user or run the admin seeder again after changing credentials.

## 6. Copy exercise media

From the Flutter project root on Windows:

```powershell
.\backend_laravel\copy_exercise_media.ps1 -LaravelPath "C:\path\to\FitWithSaju_Starter\backend_laravel"
```

Then ensure the storage link exists:

```powershell
php artisan storage:link
```

Recipe images can be uploaded from the admin panel. Flutter keeps its bundled Figma meal art as fallback when no server image exists.

## 7. Run Laravel for the phone

```powershell
php artisan serve --host=0.0.0.0 --port=8000
```

Admin:

```text
http://YOUR-PC-IP:8000/admin/login
```

Public APIs:

```text
GET /api/exercises?per_page=200
GET /api/recipes?per_page=200
GET /api/meal-plan-templates
```

In Flutter open **More → Content Sync**, enter `http://YOUR-PC-IP:8000`, then run the sync.

## Included Laravel structure

```text
backend_laravel/
├── .env
├── .env.example
├── artisan
├── composer.json
├── app/
│   ├── Http/Controllers/
│   ├── Http/Middleware/
│   ├── Http/Resources/
│   ├── Models/
│   └── Providers/
├── bootstrap/
│   ├── app.php
│   ├── providers.php
│   └── cache/
├── config/
├── database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
├── public/
├── resources/
│   ├── css/
│   ├── js/
│   └── views/
├── routes/
├── storage/
└── tests/
```

## Architecture

The Flutter mobile app remains no-login/offline-first. Laravel manages shared published content (exercises, recipes and meal-plan templates). Personal workouts, food logs, hydration, nutrition preferences and measurements remain on the device in this release.

## Production checklist

- Set `APP_ENV=production` and `APP_DEBUG=false`.
- Generate/use a production `APP_KEY`; never reuse the development ZIP key.
- Use HTTPS and set the real `APP_URL`.
- Use a strong unique admin password.
- Configure backups, logging and database credentials securely.
- Run `php artisan optimize` after deployment.

## Windows / PHP 8.5 compatibility

This project is configured to work with modern XAMPP PHP versions, including PHP 8.5:

- MySQL SSL configuration uses `Pdo\Mysql::ATTR_SSL_CA` when the PHP 8.5 driver-specific PDO class is available and falls back to `PDO::MYSQL_ATTR_SSL_CA` on older PHP versions.
- Deprecations use a dedicated `deprecations` log channel instead of a `null` channel name, avoiding PHP 8.5's null-array-offset warning during `artisan package:discover`.

If a previous Composer install failed, remove the partially installed dependencies before retrying from this corrected project:

```powershell
Remove-Item -Recurse -Force vendor -ErrorAction SilentlyContinue
Remove-Item composer.lock -ErrorAction SilentlyContinue
composer clear-cache
composer install
```

Then verify the PHP CLI used by Composer and the MySQL extension:

```powershell
php -v
php --ini
php -m | findstr /I "pdo_mysql openssl mbstring fileinfo"
```

`pdo_mysql` must be enabled before running migrations.

## SaaS administration UI (v17.4)

The admin shell is intentionally dependency-light and does not require a Tailwind/Vite build to render correctly. The primary admin styling is embedded in the Blade layout so a fresh `composer install` + `php artisan serve` has a complete interface immediately.

The v17.4 admin includes:

- Collapsible desktop sidebar and responsive mobile drawer.
- Sticky workspace top bar and global content search (`/admin/search`).
- Responsive dashboard cards driven by real database counts.
- Content health indicators for publishing, exercise media and nutrition review coverage.
- Custom paginator view used by all content lists. This avoids Laravel's default Tailwind paginator rendering oversized SVG arrows when Tailwind utilities are unavailable.
- Responsive content tables with horizontal scrolling on narrow screens.
- Sectioned forms for exercises, recipes, ingredients and meal-plan templates.
- Redesigned login and account/logout controls.

No existing content schema or public API contract was changed for this visual/admin-workflow upgrade.
