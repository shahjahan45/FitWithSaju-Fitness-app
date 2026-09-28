<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Ingredient;
use App\Models\Recipe;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class RecipeController extends Controller
{
    public function index(Request $request)
    {
        $query = Recipe::query();
        if ($request->filled('search')) {
            $search = trim((string) $request->input('search'));
            $query->where(function ($builder) use ($search) {
                $builder->where('name', 'like', "%{$search}%")
                    ->orWhere('source_id', 'like', "%{$search}%")
                    ->orWhere('cuisine', 'like', "%{$search}%");
            });
        }
        if ($request->filled('status')) {
            $query->where('status', (string) $request->input('status'));
        }
        if ($request->filled('slot')) {
            $query->where('slot', (string) $request->input('slot'));
        }
        if ($request->filled('review')) {
            $query->where('review_status', (string) $request->input('review'));
        }
        return view('admin.recipes.index', [
            'recipes' => $query->orderBy('sort_order')->orderBy('name')->paginate(24)->withQueryString(),
        ]);
    }

    public function create()
    {
        return view('admin.recipes.create', ['recipe' => new Recipe()]);
    }

    public function store(Request $request)
    {
        $recipe = Recipe::create($this->validated($request));
        $this->syncIngredients($request, $recipe);
        $this->storeImage($request, $recipe);
        return redirect()->route('admin.recipes.edit', $recipe)->with('success', 'Recipe created.');
    }

    public function edit(Recipe $recipe)
    {
        $recipe->load('ingredients');
        return view('admin.recipes.edit', compact('recipe'));
    }

    public function update(Request $request, Recipe $recipe)
    {
        $recipe->update($this->validated($request, $recipe));
        $this->syncIngredients($request, $recipe);
        $this->storeImage($request, $recipe);
        return back()->with('success', 'Recipe updated.');
    }

    public function destroy(Recipe $recipe)
    {
        $recipe->delete();
        return redirect()->route('admin.recipes.index')->with('success', 'Recipe moved to trash.');
    }

    public function publish(Recipe $recipe)
    {
        $recipe->update(['status' => $recipe->status === 'published' ? 'inactive' : 'published']);
        return back()->with('success', $recipe->status === 'published' ? 'Recipe published.' : 'Recipe removed from the public API.');
    }

    private function validated(Request $request, ?Recipe $recipe = null): array
    {
        $id = $recipe?->id;
        $validated = $request->validate([
            'source_id' => ['required', 'string', 'max:100', Rule::unique('recipes', 'source_id')->ignore($id)],
            'name' => ['required', 'string', 'max:180'],
            'slug' => ['nullable', 'string', 'max:190', Rule::unique('recipes', 'slug')->ignore($id)],
            'slot' => ['required', Rule::in(['Breakfast', 'Lunch', 'Dinner', 'Snack'])],
            'cuisine' => ['required', 'string', 'max:80'],
            'prep_minutes' => ['required', 'integer', 'min:0', 'max:1440'],
            'yield_servings' => ['required', 'integer', 'min:1', 'max:100'],
            'serving_label' => ['required', 'string', 'max:80'],
            'calories' => ['required', 'numeric', 'min:0', 'max:10000'],
            'protein' => ['required', 'numeric', 'min:0', 'max:1000'],
            'carbs' => ['required', 'numeric', 'min:0', 'max:2000'],
            'fat' => ['required', 'numeric', 'min:0', 'max:1000'],
            'artwork' => ['nullable', 'string', 'max:20'],
            'dietary_tags_text' => ['nullable', 'string', 'max:2000'],
            'allergens_text' => ['nullable', 'string', 'max:2000'],
            'instructions_text' => ['required', 'string', 'max:20000'],
            'ingredients_text' => ['required', 'string', 'max:30000'],
            'nutrition_provenance' => ['nullable', 'string', 'max:255'],
            'review_status' => ['required', Rule::in(['unreviewed', 'reviewed', 'needs_review'])],
            'reviewed_by' => ['nullable', 'string', 'max:160'],
            'status' => ['required', Rule::in(['draft', 'published', 'inactive'])],
            'sort_order' => ['required', 'integer', 'min:0', 'max:100000'],
            'image' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:8192'],
        ]);

        $validated['slug'] = $validated['slug'] ?: Str::slug($validated['name'].'-'.$validated['source_id']);
        $validated['dietary_tags'] = $this->csv($validated['dietary_tags_text'] ?? '');
        $validated['allergens'] = $this->csv($validated['allergens_text'] ?? '');
        $validated['instructions'] = $this->lines($validated['instructions_text']);
        $validated['reviewed_at'] = $validated['review_status'] === 'reviewed' ? now() : null;
        unset($validated['dietary_tags_text'], $validated['allergens_text'], $validated['instructions_text'], $validated['ingredients_text'], $validated['image']);
        return $validated;
    }

    private function syncIngredients(Request $request, Recipe $recipe): void
    {
        $lines = $this->lines((string) $request->input('ingredients_text', ''));
        $sync = [];
        foreach ($lines as $index => $line) {
            $parts = array_map('trim', explode('|', $line));
            if (count($parts) < 3) {
                continue;
            }
            [$name, $quantity, $unit] = $parts;
            $category = $parts[3] ?? 'Other';
            if ($name === '' || ! is_numeric($quantity)) {
                continue;
            }
            $ingredient = Ingredient::firstOrCreate(
                ['name' => $name],
                [
                    'slug' => Str::slug($name),
                    'category' => $category ?: 'Other',
                    'default_unit' => $unit ?: null,
                    'is_active' => true,
                ]
            );
            if ($ingredient->category !== $category && $category !== '') {
                $ingredient->update(['category' => $category]);
            }
            $sync[$ingredient->id] = [
                'quantity' => (float) $quantity,
                'unit' => $unit ?: $ingredient->default_unit,
                'sort_order' => $index,
            ];
        }
        $recipe->ingredients()->sync($sync);
    }

    private function storeImage(Request $request, Recipe $recipe): void
    {
        if (! $request->hasFile('image')) {
            return;
        }
        $old = $recipe->image_path;
        $path = $request->file('image')->store('nutrition/recipes', 'public');
        $recipe->update(['image_path' => $path]);
        if ($old) {
            Storage::disk('public')->delete($old);
        }
    }

    private function csv(string $value): array
    {
        return collect(preg_split('/[,\n]/', $value) ?: [])->map(fn ($item) => trim($item))->filter()->unique()->values()->all();
    }

    private function lines(string $value): array
    {
        return collect(preg_split('/\r\n|\r|\n/', $value) ?: [])->map(fn ($item) => trim($item))->filter()->values()->all();
    }
}
