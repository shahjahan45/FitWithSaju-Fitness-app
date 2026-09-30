# FitWithSaju v24 — Daily Readiness & Recovery

## Scope

- One local readiness check-in per calendar date: sleep quality, energy, muscle soreness, and stress (1–5).
- Today's entry can be edited; the original `createdAt` is retained and `updatedAt` changes.
- Readiness score range: 0–100. This is fitness/recovery guidance, not a medical or clinical score.
- Inputs: check-in (70 points), hydration (10), 7-day training-load balance (10), workout frequency (5), active-program/recovery-day context (5).
- Guidance bands: Ready to train; Train as planned; Consider reducing workout volume; Prioritize recovery; Consider rescheduling today's session.
- No workout is changed automatically.

## UI

`RecoveryScreen` provides the readiness ring, check-in editor, recovery signals, guidance, transparent scoring breakdown, 7-day load comparison, active-program session, Training Calendar entry, user-controlled rescheduling, and recent readiness history.

Reusable `ReadinessSummaryCard` integrations are present on Home, Workout, and Progress.

All motion uses existing FitWithSaju motion settings and respects reduced motion. The check-in/reschedule bottom sheets use SafeArea protection for Android system navigation.

## Persistence / backup

Readiness check-ins are stored under `readiness_check_ins_v1` in the existing `LocalStore`. Backup format is now version 6 and includes `readinessCheckIns`. Older backups that omit this field continue to import with an empty readiness history.

## Tests added

- readiness-score calculation and score breakdown
- one check-in per local date
- editing an existing check-in
- readiness history + backup/restore
- hydration contribution
- 7-day workout/training-load context
- program/recovery-day context
- reduced-motion Recovery UI rendering
