# FitWithSaju safe-area layout

Standalone screens should use the shared helpers in `lib/core/widgets/app_screen.dart`.

- `FitScrollableScreen` is for normal scrollable pages. Its bottom content padding is `MediaQuery.viewPadding.bottom + bottomSpacing`.
- `FitSafeBody` is for non-scrollable/input-heavy pages. It uses `SafeArea(bottom: true, maintainBottomViewPadding: true)` and works with Scaffold keyboard resizing.
- `fitPagePadding(context, bottom: ...)` is available for existing `ListView`/`GridView` screens that need to preserve their current structure while becoming system-inset aware.

Do not replace these with fixed device-specific bottom margins. Main-shell pages remain protected by the bottom navigation SafeArea; pushed/detail pages should use one of the helpers above.
