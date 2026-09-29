# FitWithSaju v17.2 — Laravel PHP 8.5 / Composer Fix

- Fixed invalid `PDO::ATTR_SSL_CA` usage.
- Uses `Pdo\Mysql::ATTR_SSL_CA` on PHP 8.5 when available, with `PDO::MYSQL_ATTR_SSL_CA` fallback.
- Added a real `deprecations` log channel so `LOG_DEPRECATIONS_CHANNEL` is never null during package discovery.
- Updated `.env` and `.env.example`.
- Added clean Composer retry instructions for Windows/XAMPP.
- Flutter application functionality is unchanged from v17.1.
