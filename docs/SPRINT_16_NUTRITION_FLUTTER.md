# Sprint 16 — Diet & Meal Plan (Flutter-first)

## Scope
This sprint implements the mobile nutrition experience before Laravel nutrition backend work. The existing Laravel exercise/content-sync starter is left unchanged.

## Figma direction
The nutrition screens follow the supplied Figma visual language: light `#F6F8F4` canvas, dark green `#193D2B` summary card, brand green `#2E651F`, lime accent `#A5D83F`, `#EAF3DF` tinted controls, 16–24 px rounded cards, restrained motion and compact typography hierarchy.

## Implemented flows
- Home nutrition shortcut
- More → Diet & Meal Plan
- Daily plan with persisted date selection and previous/next-week navigation
- Weekly overview
- Meal detail with Hero transition
- Recipe-yield scaling separate from consumed serving amount
- Dietary/allergy-safe meal alternatives and undo
- Food logs with macro snapshot, duplicate-source protection, portion editing and undo
- Hydration entries stored by local date; metric and fl-oz display conversion; edit and undo
- Saved meals
- Shopping list aggregation by ingredient + compatible unit, per-item checked state, add/edit/remove manual items, clipboard export
- Nutrition preferences and editable stored targets
- Backup/restore integration

## Nutrition data
The bundled recipes are clearly presented as sample content and estimated nutrition. No dietitian-review claim is made. User targets are editable and stored locally.

## Timezone behavior
Nutrition and hydration records are keyed by the local calendar date at the time they are created. Existing records keep that date key if the device timezone changes later.

## Backend
Nutrition backend/admin/API work is deferred to the next backend sprint.


## Figma assets
Four vector nutrition illustrations from the supplied Figma file are exported into local PNG assets for the matching sample meals (oats, main meal/chicken, salmon, yogurt). They are bundled locally and do not depend on temporary Figma URLs at runtime. Other bundled sample recipes use lightweight local emoji fallbacks until dedicated artwork is supplied.
