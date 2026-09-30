# FitWithSaju v26 – Stability & Weekly Recovery Review

## Red-screen / runtime hardening

### Home narrow-screen overflow

The Today Workout card no longer keeps duration and exercise count inside one rigid Row. A responsive Wrap allows the metadata to move cleanly on compact Android widths and larger accessibility text sizes.

### Material ancestor safety

Interactive/decorated paths now explicitly retain a transparent Material ancestor, including:

- BreathingGlow content
- Workout copy-day choices
- Training Calendar reschedule choices
- Recovery quick-reschedule choices

This protects ListTile/ink rendering in modal/test contexts without changing the visual design.

### Legacy/local-data tolerance

Recovery calculations now safely accept numeric workout volume values whether they are stored as JSON numbers or numeric strings. Invalid, negative, NaN or infinite values are ignored instead of causing a type exception.

Workout-program schedule parsing now accepts duration fields stored as numbers or strings. Deload duration calculation also remains valid for very short custom workout durations.

### Graceful load failures

Recovery and Recovery Insights now show a professional Retry state if an unexpected local-data read fails. Existing local workout/nutrition data is not deleted or modified by this fallback.

## Weekly Recovery Review

The v25 28-day insights model was extended with derived 7-day training context:

- last7Workouts
- last7Volume
- previous7Workouts
- previous7Volume
- weeklyVolumeRatio
- weeklyReviewLabel

No new persistence key or backup migration is required. Values are derived from existing workout history and readiness check-ins.

## Safeguards

- no medical or clinical claims
- no automatic workout cancellation
- no automatic workout rescheduling
- no automatic reduction of stored workout sets/volume
- all guidance remains user-controlled
