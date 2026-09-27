# Sprint 12 — Recovery, Strength Trends & Restore

## Added

- Resume interrupted workouts from local draft state.
- Active session saves workout identity, exercise position, current set, input values, completed sets, start time, and rest-timer end time.
- Home and Workout screens show a Resume Workout card when an unfinished workout exists.
- Users can explicitly discard an unfinished workout.
- Completed sets in the active session can be edited or deleted before finishing.
- Historical set entries can be edited or deleted from Workout History.
- Historical edits recalculate session volume, set counts, estimated 1RM values, and PR flags.
- Exercise detail now links to Strength History.
- Strength History includes best weight, tracked-set count, Epley estimated 1RM, recent sets, and a daily estimated 1RM trend chart.
- Personal Records now includes estimated 1RM.
- Backup & Restore replaces export-only flow.
- JSON backups can be pasted, validated, confirmed, and restored locally.
- Backup format includes weekly plans, custom workouts, favorites, workout history, body weight, measurements, and an unfinished active workout.

## Data model

Active workout draft key: `active_workout_v1`.

Estimated 1RM uses the Epley estimate:

`weight × (1 + reps / 30)`

This is presented as an estimate, not a measured maximum.

## Version

`1.4.0+8`
