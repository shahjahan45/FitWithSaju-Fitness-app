# FitWithSaju v17.5 — Mobile Stabilization & Completion

## Lifecycle crash fix

The startup/onboarding flow no longer removes the onboarding subtree when the app enters Home. Splash, onboarding and MainShell stay mounted inside a root `IndexedStack`; phase changes only change the active index. This avoids deactivating inherited Focus/MediaQuery/Ticker dependents while a tap or frame is settling.

The onboarding flow was also simplified so Goal → Level → Training Place does not use PageView, ExcludeFocus, route replacement, or a transition controller. The main five-tab shell no longer uses ExcludeFocus/ExcludeSemantics wrappers when switching tabs; it unfocuses before changing tabs and keeps page state mounted.

## Completed mobile Settings

More → Settings now supports:

- Editing goal, experience level, and training place.
- Haptic feedback on/off.
- Interface sound on/off.
- App-level reduced motion override (device accessibility setting is still respected).
- Automatic exercise/recipe content sync on/off.
- Local-first privacy explanation.

Haptic/sound preferences are used by bottom navigation and important workout actions.

## Backup completeness

Backup format v3 now includes:

- Onboarding completion state.
- Goal/level/training place profile.
- App settings.
- Existing workout plans, custom workouts, favorites, history, active workout, weight, measurements, and nutrition data.

Older FitWithSaju backups remain accepted.

## Verification added

- Root onboarding lifecycle widget test using the persistent app-phase stack.
- App preference persistence/backup test.
- LocalStore backup test now verifies profile restoration.
