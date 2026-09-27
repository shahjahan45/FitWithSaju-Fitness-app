# FitWithSaju v13 — Professional Motion Components

This sprint adds a reusable motion component layer without changing the local-first/no-login business logic.

## Core motion components

- `MotionReveal` — calm fade + 10–14 px section/card entrance
- `PressableScale` — restrained press-depth feedback
- `BreathingGlow` — subtle ambient emphasis for one primary action/card
- `AnimatedNumberText` — count-up stats
- `AnimatedVerticalBar` — chart growth animation
- `AnimatedLinearProgress` — smooth workout progress changes
- `AnimatedCheckBurst` — success/check micro-animation

All components use `AppMotion` tokens and respect `MediaQuery.disableAnimations`.

## Applied screens

### Home
- staggered header/section reveals
- animated logo entrance
- subtle ambient glow on Today's Plan
- animated streak counter
- animated weekly day cells
- staggered quick-workout cards
- professional press feedback on Start/Resume

### Explore
- search/header reveal
- staggered exercise cards
- press-depth microinteraction
- preserved Hero transitions into exercise details
- animated favorite heart state

### Progress
- staggered KPI cards
- animated weekly activity bars
- animated training-volume bars
- existing state-driven data remains unchanged

### More
- staggered section/group reveals
- existing navigation and local tools preserved

### Active Workout
- animated workout progress bar
- smooth set-entry ↔ rest-state transition
- animated/pulsing rest presentation
- press-feedback on Complete Set
- animated success check
- existing resume, set edit/delete, PR and history logic preserved

## Motion philosophy

- Micro feedback: ~140 ms
- Main navigation: 250 ms
- Detail navigation: 320 ms
- Section reveals: 360 ms
- Charts: ~700 ms
- Ambient emphasis: 2200 ms loop

No heavy bounce, spin, or large zoom is introduced.
