<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Exercise;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ExerciseController extends Controller
{
    public function index(Request $request)
    {
        $query = Exercise::query();

        if ($request->filled('search')) {
            $search = trim((string) $request->input('search'));
            $query->where(function ($builder) use ($search) {
                $builder->where('name', 'like', "%{$search}%")
                    ->orWhere('source_id', 'like', "%{$search}%");
            });
        }

        if ($request->filled('status')) {
            $query->where('is_active', $request->input('status') === 'active');
        }

        return view('admin.exercises.index', [
            'exercises' => $query->orderBy('sort_order')->orderBy('name')->paginate(24)->withQueryString(),
        ]);
    }

    public function create()
    {
        return view('admin.exercises.create', ['exercise' => new Exercise()]);
    }

    public function store(Request $request)
    {
        $exercise = Exercise::create($this->validated($request));
        $this->storeMedia($request, $exercise);
        return redirect()->route('admin.exercises.edit', $exercise)->with('success', 'Exercise created.');
    }

    public function edit(Exercise $exercise)
    {
        return view('admin.exercises.edit', compact('exercise'));
    }

    public function update(Request $request, Exercise $exercise)
    {
        $exercise->update($this->validated($request, $exercise));
        $this->storeMedia($request, $exercise);
        return back()->with('success', 'Exercise updated.');
    }

    public function destroy(Exercise $exercise)
    {
        $exercise->delete();
        return redirect()->route('admin.exercises.index')->with('success', 'Exercise moved to trash.');
    }

    public function toggle(Exercise $exercise)
    {
        $exercise->update(['is_active' => ! $exercise->is_active]);
        return back()->with('success', $exercise->is_active ? 'Exercise activated.' : 'Exercise hidden from the app.');
    }

    private function validated(Request $request, ?Exercise $exercise = null): array
    {
        $id = $exercise?->id;
        $validated = $request->validate([
            'source_id' => ['required', 'string', 'max:80', Rule::unique('exercises', 'source_id')->ignore($id)],
            'name' => ['required', 'string', 'max:160'],
            'slug' => ['nullable', 'string', 'max:180', Rule::unique('exercises', 'slug')->ignore($id)],
            'description' => ['nullable', 'string', 'max:5000'],
            'sets' => ['required', 'integer', 'min:1', 'max:20'],
            'reps' => ['required', 'string', 'max:40'],
            'rest_seconds' => ['required', 'integer', 'min:0', 'max:1800'],
            'sort_order' => ['required', 'integer', 'min:0', 'max:100000'],
            'target_muscles_text' => ['nullable', 'string', 'max:1500'],
            'body_parts_text' => ['nullable', 'string', 'max:1500'],
            'equipments_text' => ['nullable', 'string', 'max:1500'],
            'secondary_muscles_text' => ['nullable', 'string', 'max:1500'],
            'instructions_text' => ['nullable', 'string', 'max:10000'],
            'media' => ['nullable', 'file', 'mimes:gif,webp', 'max:15360'],
            'thumbnail' => ['nullable', 'file', 'mimes:gif,webp,jpg,jpeg,png', 'max:8192'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $validated['slug'] = $validated['slug'] ?: Str::slug($validated['name'].'-'.$validated['source_id']);
        $validated['target_muscles'] = $this->csv($validated['target_muscles_text'] ?? '');
        $validated['body_parts'] = $this->csv($validated['body_parts_text'] ?? '');
        $validated['equipments'] = $this->csv($validated['equipments_text'] ?? '');
        $validated['secondary_muscles'] = $this->csv($validated['secondary_muscles_text'] ?? '');
        $validated['instructions'] = $this->lines($validated['instructions_text'] ?? '');
        $validated['is_active'] = $request->boolean('is_active');

        unset(
            $validated['target_muscles_text'],
            $validated['body_parts_text'],
            $validated['equipments_text'],
            $validated['secondary_muscles_text'],
            $validated['instructions_text'],
            $validated['media'],
            $validated['thumbnail'],
        );

        return $validated;
    }

    private function storeMedia(Request $request, Exercise $exercise): void
    {
        $updates = [];
        foreach ([
            'media' => ['field' => 'media_path', 'directory' => 'exercises/media'],
            'thumbnail' => ['field' => 'thumbnail_path', 'directory' => 'exercises/thumbs'],
        ] as $input => $config) {
            if (! $request->hasFile($input)) {
                continue;
            }
            $old = $exercise->{$config['field']};
            $updates[$config['field']] = $request->file($input)->store($config['directory'], 'public');
            if ($old) {
                Storage::disk('public')->delete($old);
            }
        }
        if ($updates !== []) {
            $exercise->update($updates);
        }
    }

    private function csv(string $value): array
    {
        return collect(preg_split('/[,\n]/', $value) ?: [])
            ->map(fn ($item) => trim($item))
            ->filter()
            ->unique()
            ->values()
            ->all();
    }

    private function lines(string $value): array
    {
        return collect(preg_split('/\r\n|\r|\n/', $value) ?: [])
            ->map(fn ($item) => trim($item))
            ->filter()
            ->values()
            ->all();
    }
}
