# FitWithSaju v29 — Weekly Review & Consistency Streaks

## Added
- Professional Weekly Review screen derived from existing local workout, weekly-goal, hydration and readiness data.
- Monday-to-today comparison against the same Monday-to-weekday period from the previous week for a fair in-progress comparison.
- Weekly workout count, training minutes, training volume, completed sets and PR count.
- Hydration target-day and readiness check-in context.
- Average readiness guidance score for the reviewed period. This remains fitness/recovery guidance only, not a medical or clinical score.
- Current consecutive active-training-week streak and best historical active-training-week streak.
- Strongest training day for the current week using training volume and training time.
- User-controlled weekly guidance that never adds, cancels, reduces or reschedules workouts automatically.
- Weekly Review summary cards on Home and Progress plus a More menu entry.

## Stability
- Progress metrics now safely parse older numeric values stored as strings.
- Training volume can be reconstructed from saved sets if an older history entry has no stored total volume.
- Weekly Review has a safe retry state rather than surfacing a red screen if derived data cannot load.

## Persistence and backup
v29 adds no new personal-data store. Weekly Review is derived from data already covered by the existing backup, so Backup & Restore remains format version 7 and is backward compatible.
