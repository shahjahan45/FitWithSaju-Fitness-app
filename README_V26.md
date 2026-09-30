# FitWithSaju v26 – Stability & Weekly Recovery Review

v26 continues directly from v25 and focuses first on eliminating the reported Flutter red-screen/layout paths, then adds a weekly recovery review derived from the existing local readiness and workout data.

## Stability fixes

- Replaced the rigid Home workout metadata row with a responsive Wrap to prevent narrow-screen RenderFlex overflow.
- Added explicit transparent Material ancestry around animated/decorated content and reschedule/copy ListTiles that can otherwise trigger Material-ancestor assertions in isolated routes/tests.
- Hardened readiness/recovery training-volume parsing so older/imported values stored as strings do not cause runtime type-cast failures.
- Hardened active-program duration parsing for older backup/program data stored as strings.
- Prevented invalid deload-duration clamp bounds for very short custom workout durations.
- Added graceful Recovery and Recovery Insights error states with Retry instead of leaving the user on a crash/loading path.

## Weekly Recovery Review

The existing 28-day Recovery Insights screen now includes a 7-day review showing:

- current 7-day readiness average
- prior 7-day readiness average
- current-week check-in consistency
- current 7-day workout count
- current 7-day training volume
- volume comparison with the previous 7-day period
- a plain-language weekly recovery direction

The review remains fitness/recovery guidance only and never changes a workout automatically.

## Version

`1.18.0+33`
