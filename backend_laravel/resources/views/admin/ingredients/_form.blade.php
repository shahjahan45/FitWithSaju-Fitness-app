<div class="form-grid">
    <div class="form-section" style="border-top:0;padding-top:0;margin-top:0"><div class="form-section-title">Ingredient details</div><div class="form-section-sub">Reusable metadata shared by recipes and shopping lists.</div></div>
    <div class="field"><label>Name</label><input class="input" name="name" required value="{{ old('name',$ingredient->name) }}" placeholder="Ingredient name"></div>
    <div class="field"><label>Category</label><input class="input" name="category" required value="{{ old('category',$ingredient->category ?? 'Other') }}" placeholder="Produce, Protein, Pantry"></div>
    <div class="field"><label>Default unit</label><input class="input" name="default_unit" value="{{ old('default_unit',$ingredient->default_unit) }}" placeholder="g, ml, pcs"></div>
    <div class="field"><label class="check-row"><input type="checkbox" name="is_active" value="1" @checked(old('is_active',$ingredient->exists ? $ingredient->is_active : true))> Active ingredient</label></div>
</div>
<div class="form-actions"><button class="btn btn-primary" type="submit">Save ingredient</button><a class="btn btn-light" href="{{ route('admin.ingredients.index') }}">Cancel</a></div>
