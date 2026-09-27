# FitWithSaju Motion System

## Central configuration

All navigation timing and curves are defined in:

`lib/core/motion/app_motion.dart`

Current mapping:

- Main bottom navigation: 250 ms, fade + 16 px directional slide
- Detail/list routes: 320 ms, trailing-edge slide + fade
- Full-screen workout: 320 ms, 0.97 → 1.0 scale + fade
- Modal/bottom sheet: 280 ms entrance / 250 ms reverse
- Internal onboarding/tab movement: 190–320 ms depending on action
- Onboarding completion → Home: 330 ms fade + 0.98 → 1.0 scale
- Success content: 280 ms fade + 0.96 → 1.0 scale

## State preservation

`MainShell` keeps Home, Workout, Explore, Progress, and More mounted inside an `IndexedStack`.

Inactive destinations are wrapped with:

- `TickerMode(enabled: false)`
- `IgnorePointer`
- `ExcludeFocus`
- `ExcludeSemantics`

This preserves scroll/form/filter state while preventing interaction and unnecessary ticker work on inactive pages.

## Hero transitions

Explore exercise cards use a stable tag:

`exercise-art-<exercise id>`

Only the exercise visual participates in Hero motion. The rest of the page uses the route fade/slide.

## Platform behavior

On iOS/macOS, detail/full-screen helpers use the platform `MaterialPageRoute` to retain native back/swipe behavior. Android and other platforms use the custom FitWithSaju transitions.

## Reduced motion

When `MediaQuery.disableAnimations` is enabled:

- Bottom destination content does not slide.
- Route movement/scaling falls back to a short fade.
- The bottom selected indicator updates immediately.
- Onboarding pages jump rather than slide.
- Success content does not scale.

## Validation checklist

Run locally on the supported devices:

- Switch repeatedly among Home, Workout, Explore, Progress, and More.
- Tap several destinations quickly and confirm the latest destination settles cleanly.
- Type into Explore search, switch tabs, then return and confirm the text remains.
- Scroll Home/Workout/Progress, switch tabs, and confirm positions remain.
- Open an exercise, verify the Hero visual and return with Android Back / iOS swipe-back.
- Start a workout and verify full-screen fade/scale navigation.
- Complete a workout and verify success appears only after local history save succeeds.
- Drag the success sheet down and verify the reverse sheet animation.
- Enable Reduce Motion and verify slides/scales are removed or shortened.
- Test larger text and RTL layouts.
- Run `flutter run --profile` on a physical Android/iOS device and inspect jank in DevTools.


## Current authentication scope

The current FitWithSaju starter intentionally has no end-user login/authentication flow. No login screen was added as part of this motion update. The requested login-to-home motion token is applied to the existing onboarding/entry completion → Home transition so the current no-login product behavior remains intact.
