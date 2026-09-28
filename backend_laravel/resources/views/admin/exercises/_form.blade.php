@php
$targets = old('target_muscles_text', implode(', ', $exercise->target_muscles ?? []));
$bodyParts = old('body_parts_text', implode(', ', $exercise->body_parts ?? []));
$equipment = old('equipments_text', implode(', ', $exercise->equipments ?? []));
$secondary = old('secondary_muscles_text', implode(', ', $exercise->secondary_muscles ?? []));
$instructions = old('instructions_text', implode("\n", $exercise->instructions ?? []));
@endphp
<div class="form-grid">
    <div class="form-section" style="border-top:0;padding-top:0;margin-top:0"><div class="form-section-title">Exercise identity</div><div class="form-section-sub">Stable identifiers and display copy used by the mobile catalog.</div></div>
    <div class="field"><label>Exercise ID</label><input class="input" name="source_id" required value="{{ old('source_id',$exercise->source_id) }}" placeholder="e.g. 3TZduzM"></div>
    <div class="field"><label>Name</label><input class="input" name="name" required value="{{ old('name',$exercise->name) }}" placeholder="Exercise name"></div>
    <div class="field full"><label>Slug <span class="muted">Optional</span></label><input class="input" name="slug" value="{{ old('slug',$exercise->slug) }}" placeholder="Generated automatically when empty"></div>
    <div class="field full"><label>Description</label><textarea class="textarea" name="description" placeholder="Short coaching description or movement overview">{{ old('description',$exercise->description) }}</textarea></div>

    <div class="form-section"><div class="form-section-title">Classification</div><div class="form-section-sub">Used by Explore filters and exercise recommendations.</div></div>
    <div class="field"><label>Target muscles</label><input class="input" name="target_muscles_text" value="{{ $targets }}" placeholder="glutes, quadriceps"></div>
    <div class="field"><label>Body parts</label><input class="input" name="body_parts_text" value="{{ $bodyParts }}" placeholder="upper legs"></div>
    <div class="field"><label>Equipment</label><input class="input" name="equipments_text" value="{{ $equipment }}" placeholder="smith machine"></div>
    <div class="field"><label>Secondary muscles</label><input class="input" name="secondary_muscles_text" value="{{ $secondary }}" placeholder="hamstrings, calves"></div>

    <div class="form-section"><div class="form-section-title">Workout defaults</div><div class="form-section-sub">Starting values users see when this movement enters a workout.</div></div>
    <div class="field"><label>Default sets</label><input class="input" type="number" min="1" max="20" name="sets" value="{{ old('sets',$exercise->sets ?? 3) }}"></div>
    <div class="field"><label>Default reps</label><input class="input" name="reps" value="{{ old('reps',$exercise->reps ?? '10–12') }}"></div>
    <div class="field"><label>Rest seconds</label><input class="input" type="number" min="0" max="1800" name="rest_seconds" value="{{ old('rest_seconds',$exercise->rest_seconds ?? 60) }}"></div>
    <div class="field"><label>Sort order</label><input class="input" type="number" min="0" name="sort_order" value="{{ old('sort_order',$exercise->sort_order ?? 0) }}"></div>
    <div class="field full"><label>Instructions <span class="muted">One step per line</span></label><textarea class="textarea" style="min-height:180px" name="instructions_text" placeholder="Set up the machine...&#10;Brace your core...">{{ $instructions }}</textarea></div>

    <div class="form-section"><div class="form-section-title">Media & visibility</div><div class="form-section-sub">Upload lightweight demonstrations and control mobile availability.</div></div>
    <div class="field"><label>Demonstration media</label><input class="input" type="file" name="media" accept="image/gif,image/webp"><div class="field-help">GIF or WebP, up to 15 MB.</div></div>
    <div class="field"><label>Thumbnail</label><input class="input" type="file" name="thumbnail" accept="image/gif,image/webp,image/jpeg,image/png"><div class="field-help">GIF, WebP, JPG or PNG, up to 8 MB.</div></div>
    <div class="field full"><label class="check-row"><input type="checkbox" name="is_active" value="1" @checked(old('is_active',$exercise->exists ? $exercise->is_active : true))> Visible in mobile app</label></div>
</div>
<div class="form-actions"><button class="btn btn-primary" type="submit">Save exercise</button><a class="btn btn-light" href="{{ route('admin.exercises.index') }}">Cancel</a></div>
