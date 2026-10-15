# FitWithSaju v27.1 – Explore + Measurements Android UI Hotfix

## Fixed: Favorites → Browse exercises red screen

`ExploreScreen` was originally designed as a tab body. When Favorites opened it through the custom `PageRouteBuilder`, the new route did not contain its own `Material` surface. The Explore search `TextField` could therefore fail with:

`No Material widget found. TextField widgets require a Material widget ancestor within the closest LookupBoundary.`

The screen now owns a `Material` surface, so it is safe both inside the main tab shell and when pushed as a standalone route. Favorites opens it with a dedicated back control while preserving the existing exercise catalog, filters, search, GIF/media, favorites and detail navigation.

## Fixed: Measurements bottom sheet / Android system navigation overlap

The Add Measurements sheet previously added only `MediaQuery.viewInsets.bottom`, which protects against the software keyboard but does not reliably reserve Android 3-button/gesture navigation space.

The sheet now uses:

- transparent modal route with its own rounded Material surface
- explicit bottom `SafeArea`
- `maintainBottomViewPadding: true`
- keyboard-aware animated bottom padding
- a fixed bottom Save Measurements action outside the scrolling field list
- a scrollable measurement field area for compact screens
- responsive maximum height
- waits for the bottom-sheet reverse transition to fully settle before disposing input controllers or refreshing storage-backed UI
- disabled Save action until at least one valid positive measurement is entered

This keeps Save Measurements visibly above Android system controls on Samsung 3-button and gesture-navigation layouts, including when the keyboard is open.

## Regression coverage

Added `test/v27_1_ui_hotfix_test.dart` covering:

- standalone Explore search input Material ancestry
- standalone Explore back affordance
- Measurements Save action inside a bottom SafeArea with maintained bottom view padding
- no captured Flutter framework exception in either flow

## Version

`1.19.1+36`
