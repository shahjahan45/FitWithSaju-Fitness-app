# Sprint 15 — Exercise Admin + API Sync

## Mobile

- Optional Laravel exercise catalog sync
- Bundled 30-exercise catalog remains the offline fallback
- Cached remote catalog is restored on app launch
- Configured servers refresh in the background after startup
- Network GIF/WebP media falls back to the matching bundled asset when available
- More -> Exercise Content Sync provides API URL configuration, status, manual sync, and offline reset
- Explore shows LIVE / CACHED / OFFLINE catalog status
- Workout plan/custom workout resolution uses the active catalog while preserving legacy IDs

## Laravel starter

- Session admin login and admin-only middleware
- Professional light admin layout
- Dashboard metrics
- Exercise CRUD
- Search and active/hidden filtering
- Activate/hide action
- Soft deletes
- GIF/WebP media and thumbnail upload
- Public paginated exercise API
- Search/body-part/equipment/muscle API filters
- Seeder for the same 30 user-provided exercise IDs
- Admin-account seeder controlled by environment variables

## Data boundary

Only public exercise content syncs from Laravel. Workout history, body metrics, plans, favorites, PRs, and active sessions remain local to the phone.
