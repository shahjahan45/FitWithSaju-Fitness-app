# FitWithSaju v27 – Weekly Training Balance & Plan Preview

## What changed

v27 extends the existing readiness/recovery system with a training-context layer that compares the user's most recent seven days with their own prior three-week training baseline.

### Training Balance

- last 7-day workout count and training volume
- average weekly workout count and training volume from the previous 21 days
- transparent current-volume-to-baseline comparison
- labels for building baseline, lighter, near baseline, above baseline and well above baseline
- optional guidance that can also consider the recent 7-day readiness average
- legacy numeric-string workout values are tolerated rather than causing runtime failures

This is fitness guidance only. It is not a medical, clinical, injury-risk, or overtraining diagnosis.

### Next 7 Days preview

The new Training Balance screen previews the real saved schedule for the next seven days.

- active workout program: uses `WorkoutProgramSchedule`, including rescheduled sessions, rest days and deload status
- no active program: uses the existing Monday–Sunday local workout planner
- active-program users can open the existing Training Calendar directly
- no workout is automatically changed, cancelled, skipped or rescheduled

### Integration

Training Balance cards are added to:

- Workout
- Progress
- Recovery Insights

All cards use the same local-first service and existing `LocalStore` data.

## Persistence / backup

No new persistence key is introduced. Training balance and plan preview are derived from existing workout history, readiness check-ins, weekly plan, active program and program schedule overrides. Existing backup format remains compatible.
