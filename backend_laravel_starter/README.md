# FitWithSaju Laravel Backend Starter

This folder is starter application code to copy into a fresh Laravel project.

## Suggested setup

```bash
composer create-project laravel/laravel fitwithsaju-api
cd fitwithsaju-api
```

Copy the files from this folder into the matching Laravel directories.

Then configure `.env` for MySQL and run:

```bash
php artisan migrate
php artisan serve --host=0.0.0.0 --port=8000
```

The public mobile API intentionally has no end-user authentication.
Admin authentication should be implemented in the dedicated Admin sprint.
