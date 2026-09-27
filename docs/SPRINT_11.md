# Sprint 11 — Set Tracking, PRs & Rich History

## Implemented

- Persistent set-level workout history
- Weight and reps saved for every completed set
- Training volume calculation (`weight × reps`)
- Previous-set lookup and prefill per exercise/set number
- Automatic exercise personal-record detection
- Live PR feedback during workouts
- Workout completion summary with volume and PR count
- Detailed workout-history session screen
- Exercise-by-exercise set breakdown
- Weekly training-volume chart on Progress
- Exercise-specific Personal Records screen
- Local-store helpers for previous set, records and volume
- Double-tap protection on Complete Set
- Backward compatibility for older workout-history entries

## Data stored per completed set

- exerciseId
- exerciseName
- muscle
- setNumber
- weight
- reps
- volume
- isPR
- completedAt

## Next recommended sprint

- Edit/delete an individual completed set
- Resume an interrupted workout
- Exercise history chart over time
- 1RM estimate and strength trend
- Import JSON backup
- Exercise media/GIF API integration
