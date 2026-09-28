@php $daysJson = old('days_json', $template->exists ? json_encode($template->days, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES) : "{\n  \"monday\": [\n    {\"slot\": \"Breakfast\", \"recipe_id\": \"berry_oats\", \"time\": \"08:00\"}\n  ]\n}"); @endphp
<div class="form-grid">
    <div class="form-section" style="border-top:0;padding-top:0;margin-top:0"><div class="form-section-title">Template details</div><div class="form-section-sub">Reusable weekly structure delivered through the public content API.</div></div>
    <div class="field"><label>Name</label><input class="input" name="name" required value="{{ old('name',$template->name) }}"></div>
    <div class="field"><label>Goal</label><input class="input" name="goal" value="{{ old('goal',$template->goal ?? 'Balanced eating') }}"></div>
    <div class="field full"><label>Slug <span class="muted">Optional</span></label><input class="input" name="slug" value="{{ old('slug',$template->slug) }}" placeholder="Generated automatically when empty"></div>
    <div class="field full"><label>Description</label><textarea class="textarea" name="description">{{ old('description',$template->description) }}</textarea></div>
    <div class="form-section"><div class="form-section-title">Weekly structure</div><div class="form-section-sub">Reference recipes by stable recipe ID. Publishing does not overwrite a user’s existing local plan.</div></div>
    <div class="field full"><label>Days JSON</label><textarea class="textarea code-input" style="min-height:380px" name="days_json">{{ $daysJson }}</textarea></div>
    <div class="form-section"><div class="form-section-title">Publication</div><div class="form-section-sub">Control API visibility and ordering.</div></div>
    <div class="field"><label>Status</label><select class="select" name="status">@foreach(['draft','published','inactive'] as $status)<option value="{{ $status }}" @selected(old('status',$template->status ?? 'draft')===$status)>{{ ucfirst($status) }}</option>@endforeach</select></div>
    <div class="field"><label>Sort order</label><input class="input" type="number" min="0" name="sort_order" value="{{ old('sort_order',$template->sort_order ?? 0) }}"></div>
</div>
<div class="form-actions"><button class="btn btn-primary" type="submit">Save template</button><a class="btn btn-light" href="{{ route('admin.meal-templates.index') }}">Cancel</a></div>
