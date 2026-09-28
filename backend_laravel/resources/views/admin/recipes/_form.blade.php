@php
$dietary = old('dietary_tags_text', implode(', ', $recipe->dietary_tags ?? []));
$allergens = old('allergens_text', implode(', ', $recipe->allergens ?? []));
$instructions = old('instructions_text', implode("\n", $recipe->instructions ?? []));
$ingredientLines = old('ingredients_text');
if ($ingredientLines === null && $recipe->exists) {
    $ingredientLines = $recipe->ingredients->map(fn($item) => $item->name.' | '.rtrim(rtrim(number_format((float)$item->pivot->quantity,3,'.',''),'0'),'.').' | '.($item->pivot->unit ?: $item->default_unit).' | '.$item->category)->implode("\n");
}
@endphp
<div class="form-grid">
    <div class="form-section" style="border-top:0;padding-top:0;margin-top:0"><div class="form-section-title">Recipe identity</div><div class="form-section-sub">Core catalog information and meal placement.</div></div>
    <div class="field"><label>Stable recipe ID</label><input class="input" name="source_id" required value="{{ old('source_id',$recipe->source_id) }}" placeholder="berry_oats"></div>
    <div class="field"><label>Name</label><input class="input" name="name" required value="{{ old('name',$recipe->name) }}"></div>
    <div class="field"><label>Meal slot</label><select class="select" name="slot">@foreach(['Breakfast','Lunch','Dinner','Snack'] as $slot)<option value="{{ $slot }}" @selected(old('slot',$recipe->slot)===$slot)>{{ $slot }}</option>@endforeach</select></div>
    <div class="field"><label>Cuisine</label><input class="input" name="cuisine" value="{{ old('cuisine',$recipe->cuisine ?? 'International') }}"></div>
    <div class="field"><label>Prep minutes</label><input class="input" type="number" min="0" name="prep_minutes" value="{{ old('prep_minutes',$recipe->prep_minutes ?? 10) }}"></div>
    <div class="field"><label>Recipe yield</label><input class="input" type="number" min="1" name="yield_servings" value="{{ old('yield_servings',$recipe->yield_servings ?? 1) }}"></div>
    <div class="field"><label>Serving label</label><input class="input" name="serving_label" value="{{ old('serving_label',$recipe->serving_label ?? '1 serving') }}"></div>
    <div class="field"><label>Artwork fallback</label><input class="input" name="artwork" value="{{ old('artwork',$recipe->artwork) }}" placeholder="🍽️"></div>

    <div class="form-section"><div class="form-section-title">Nutrition per serving</div><div class="form-section-sub">Estimated values shown in the mobile meal planner.</div></div>
    <div class="field"><label>Calories</label><input class="input" type="number" step="0.01" min="0" name="calories" value="{{ old('calories',$recipe->calories ?? 0) }}"></div>
    <div class="field"><label>Protein (g)</label><input class="input" type="number" step="0.01" min="0" name="protein" value="{{ old('protein',$recipe->protein ?? 0) }}"></div>
    <div class="field"><label>Carbs (g)</label><input class="input" type="number" step="0.01" min="0" name="carbs" value="{{ old('carbs',$recipe->carbs ?? 0) }}"></div>
    <div class="field"><label>Fat (g)</label><input class="input" type="number" step="0.01" min="0" name="fat" value="{{ old('fat',$recipe->fat ?? 0) }}"></div>
    <div class="field"><label>Dietary tags</label><input class="input" name="dietary_tags_text" value="{{ $dietary }}" placeholder="Halal, Gluten-free"></div>
    <div class="field"><label>Allergens</label><input class="input" name="allergens_text" value="{{ $allergens }}" placeholder="Dairy, Gluten"></div>

    <div class="form-section"><div class="form-section-title">Ingredients & preparation</div><div class="form-section-sub">Structured ingredients and ordered preparation steps.</div></div>
    <div class="field full"><label>Ingredients</label><textarea class="textarea code-input" style="min-height:190px" name="ingredients_text" placeholder="Ingredient | quantity | unit | category">{{ $ingredientLines }}</textarea><div class="field-help">One ingredient per line. Example: Chicken breast | 300 | g | Protein</div></div>
    <div class="field full"><label>Preparation steps</label><textarea class="textarea" style="min-height:180px" name="instructions_text" placeholder="One preparation step per line">{{ $instructions }}</textarea></div>

    <div class="form-section"><div class="form-section-title">Review & publication</div><div class="form-section-sub">Keep nutrition provenance and publication status explicit.</div></div>
    <div class="field"><label>Nutrition provenance</label><input class="input" name="nutrition_provenance" value="{{ old('nutrition_provenance',$recipe->nutrition_provenance ?? 'Estimated sample nutrition') }}"></div>
    <div class="field"><label>Review status</label><select class="select" name="review_status">@foreach(['unreviewed','reviewed','needs_review'] as $status)<option value="{{ $status }}" @selected(old('review_status',$recipe->review_status ?? 'unreviewed')===$status)>{{ str_replace('_',' ',ucfirst($status)) }}</option>@endforeach</select></div>
    <div class="field"><label>Reviewer <span class="muted">Only when verified</span></label><input class="input" name="reviewed_by" value="{{ old('reviewed_by',$recipe->reviewed_by) }}" placeholder="Name / role"></div>
    <div class="field"><label>Publication status</label><select class="select" name="status">@foreach(['draft','published','inactive'] as $status)<option value="{{ $status }}" @selected(old('status',$recipe->status ?? 'draft')===$status)>{{ ucfirst($status) }}</option>@endforeach</select></div>
    <div class="field"><label>Sort order</label><input class="input" type="number" min="0" name="sort_order" value="{{ old('sort_order',$recipe->sort_order ?? 0) }}"></div>
    <div class="field"><label>Recipe image</label><input class="input" type="file" name="image" accept="image/jpeg,image/png,image/webp">@if($recipe->image_path)<div class="field-help">Current image remains unless you upload a replacement.</div>@endif</div>
    <div class="field full"><label>Slug <span class="muted">Optional</span></label><input class="input" name="slug" value="{{ old('slug',$recipe->slug) }}" placeholder="Generated automatically when empty"></div>
</div>
<div class="form-actions"><button class="btn btn-primary" type="submit">Save recipe</button><a class="btn btn-light" href="{{ route('admin.recipes.index') }}">Cancel</a></div>
