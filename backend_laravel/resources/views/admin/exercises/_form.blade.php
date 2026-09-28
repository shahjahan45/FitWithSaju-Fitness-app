@php
$targets = old('target_muscles_text', implode(', ', $exercise->target_muscles ?? []));
$bodyParts = old('body_parts_text', implode(', ', $exercise->body_parts ?? []));
$equipment = old('equipments_text', implode(', ', $exercise->equipments ?? []));
$secondary = old('secondary_muscles_text', implode(', ', $exercise->secondary_muscles ?? []));
$instructions = old('instructions_text', implode("\n", $exercise->instructions ?? []));
@endphp
<div class="form-grid">
<div class="field"><label>Exercise ID</label><input class="input" name="source_id" required value="{{ old('source_id',$exercise->source_id) }}" placeholder="e.g. 3TZduzM"></div>
<div class="field"><label>Name</label><input class="input" name="name" required value="{{ old('name',$exercise->name) }}"></div>
<div class="field full"><label>Slug (optional)</label><input class="input" name="slug" value="{{ old('slug',$exercise->slug) }}" placeholder="Generated automatically if empty"></div>
<div class="field full"><label>Description</label><textarea class="textarea" name="description">{{ old('description',$exercise->description) }}</textarea></div>
<div class="field"><label>Target muscles (comma separated)</label><input class="input" name="target_muscles_text" value="{{ $targets }}"></div>
<div class="field"><label>Body parts (comma separated)</label><input class="input" name="body_parts_text" value="{{ $bodyParts }}"></div>
<div class="field"><label>Equipment (comma separated)</label><input class="input" name="equipments_text" value="{{ $equipment }}"></div>
<div class="field"><label>Secondary muscles (comma separated)</label><input class="input" name="secondary_muscles_text" value="{{ $secondary }}"></div>
<div class="field"><label>Default sets</label><input class="input" type="number" min="1" max="20" name="sets" value="{{ old('sets',$exercise->sets ?? 3) }}"></div>
<div class="field"><label>Default reps</label><input class="input" name="reps" value="{{ old('reps',$exercise->reps ?? '10–12') }}"></div>
<div class="field"><label>Rest seconds</label><input class="input" type="number" min="0" max="1800" name="rest_seconds" value="{{ old('rest_seconds',$exercise->rest_seconds ?? 60) }}"></div>
<div class="field"><label>Sort order</label><input class="input" type="number" min="0" name="sort_order" value="{{ old('sort_order',$exercise->sort_order ?? 0) }}"></div>
<div class="field full"><label>Instructions (one step per line)</label><textarea class="textarea" style="min-height:180px" name="instructions_text">{{ $instructions }}</textarea></div>
<div class="field"><label>Demonstration media (GIF/WebP)</label><input class="input" type="file" name="media" accept="image/gif,image/webp"></div>
<div class="field"><label>Thumbnail (GIF/WebP/JPG/PNG)</label><input class="input" type="file" name="thumbnail" accept="image/gif,image/webp,image/jpeg,image/png"></div>
<div class="field full"><label style="display:flex;gap:9px;align-items:center"><input type="checkbox" name="is_active" value="1" @checked(old('is_active',$exercise->exists ? $exercise->is_active : true))> Visible in mobile app</label></div>
</div>
<div style="display:flex;gap:10px;margin-top:20px"><button class="btn btn-primary" type="submit">Save exercise</button><a class="btn btn-light" href="{{ route('admin.exercises.index') }}">Cancel</a></div>
