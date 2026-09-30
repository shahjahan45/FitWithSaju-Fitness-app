# FitWithSaju v25 – Recovery Insights & Smart Training Guidance

## What changed

v25 extends the local-first Daily Readiness & Recovery system introduced in v24 without replacing any existing architecture or persistence.

### 28-day Recovery Insights

- 28-day readiness average and check-in consistency
- recent 7-day average compared with the previous 7-day period
- animated 28-day readiness chart
- average sleep, energy, soreness and stress signals
- last 28-day training volume and workout count
- comparison against the previous 28 days
- plain-language patterns generated from the user's own stored fitness data
- explicit non-medical / non-clinical wording

### Smart Training Guidance

- optional session effort guidance derived from the existing readiness assessment
- optional volume ranges for normal, moderate, lighter and recovery-first days
- protects active rest/deload intent
- can suggest considering rescheduling when readiness is low
- never edits, cancels, skips, reduces or reschedules a workout automatically
- the user remains in control of all workout changes

### Integration

- Recovery screen: richer smart guidance plus link to 28-day Recovery Insights
- Workout screen: Smart Training Guidance card
- Progress screen: 28-day Recovery Insights summary card
- Home continues to use the existing daily readiness card

### Data and backup

The new insights are derived from existing v24 data:

- readiness check-ins
- hydration logs
- workout history
- active program/calendar context

No second copy of this data is stored, so the existing v24 backup format remains compatible and no backup migration is required.

## Version

`1.17.0+32`

## Validation commands

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```
