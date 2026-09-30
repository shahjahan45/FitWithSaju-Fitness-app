# FitWithSaju v23 — Training Calendar & Recovery Planning

This release extends active workout programs with date-aware scheduling.

## Added
- Program training calendar with week navigation
- Completed / upcoming / missed / skipped / rest / pre-enrollment states
- Session rescheduling within the next 14 days
- Skip + restore-original-schedule actions
- Deload week toggle
- Deload workouts use one fewer set and a ~15% lighter suggested starting load
- Program-session IDs are saved in workout history for reliable calendar completion
- Mid-week enrollment no longer marks earlier program days as missed
- Active Program “next session” respects reschedules and missed sessions
- Backup format v5 includes program schedule overrides

## Local-first behavior
Program schedule changes are stored locally with the rest of personal training data. Public Laravel content sync remains unchanged.
