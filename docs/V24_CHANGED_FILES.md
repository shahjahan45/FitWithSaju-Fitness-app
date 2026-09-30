# v24 Changed / Added Files

## Added

- `lib/features/recovery/data/readiness_models.dart`
- `lib/features/recovery/data/readiness_calculator.dart`
- `lib/features/recovery/data/readiness_service.dart`
- `lib/features/recovery/readiness_summary_card.dart`
- `lib/features/recovery/recovery_screen.dart`
- `test/readiness_recovery_test.dart`
- `test/readiness_reduced_motion_test.dart`
- `docs/V24_DAILY_READINESS_RECOVERY.md`
- `docs/V24_VALIDATION.md`
- `docs/V24_CHANGED_FILES.md`

## Updated

- `lib/core/storage/local_store.dart` — readiness persistence + backup format v6
- `lib/features/home/home_screen.dart` — readiness card
- `lib/features/workout/workout_screen.dart` — recovery-before-training card
- `lib/features/progress/progress_screen.dart` — recovery card integration
- `lib/features/more/data_export_screen.dart` — restore messaging includes readiness data
- `test/workout_calendar_test.dart` — backup format version assertion updated to v6
- `pubspec.yaml` — version `1.16.0+31`
- `README.md` — v24 feature notes

The Laravel backend code was preserved without feature-level changes for this local-first recovery sprint.
