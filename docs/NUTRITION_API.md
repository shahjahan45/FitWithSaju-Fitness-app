# FitWithSaju Nutrition Content API Contract

## GET /api/recipes

Returns published recipes only. Supported query parameters:

- `search`
- `slot=Breakfast|Lunch|Dinner|Snack`
- `cuisine`
- `dietary`
- `exclude_allergen`
- `per_page` (1–200)

Each recipe contains a stable `id`, nutrition per serving, ingredients, instructions, allergens, review metadata, and optional `image_url`.

## GET /api/recipes/{id-or-slug}

Returns one published recipe.

## GET /api/meal-plan-templates

Returns published templates. Optional `goal` filter.

## GET /api/meal-plan-templates/{slug}

Returns a single published template.

## Mobile sync behavior

Flutter treats Laravel as an optional public-content source:

1. bundled recipes are always available;
2. successful API recipes are cached;
3. matching bundled IDs retain local artwork as image fallback;
4. API content can be reset without deleting personal nutrition records;
5. food-log snapshots are not recomputed when recipe content later changes.

## Personal-data boundary in v17

These endpoints intentionally do not accept personal food/hydration records. The mobile app remains no-login and stores personal records locally. This is a deliberate privacy/architecture boundary, not a missing fallback disguised as a successful sync.

## v18 meal-plan template behavior

The Flutter client now synchronizes `/api/meal-plan-templates` alongside recipes and exercises. Published templates are cached for offline use and merged with the bundled templates.

Bundled templates include:
- `balanced-week-sample`
- `high-protein-7-day`

`high-protein-7-day` contains four meals per day and references stable `hp_*` recipe IDs. Protein values mirror the user-supplied reference plan (190–205 g/day, about 196 g/day average). Calories, carbohydrates and fats are sample estimates and remain marked as unreviewed until content review is completed in the Laravel admin.

Applying a template replaces planned meals only. Existing food logs and hydration entries are preserved. Flutter validates dietary/allergy restrictions before applying and refuses incompatible templates rather than silently relaxing exclusions.
