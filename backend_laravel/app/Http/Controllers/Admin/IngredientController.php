<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Ingredient;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class IngredientController extends Controller
{
    public function index(Request $request)
    {
        $query = Ingredient::query()->withCount('recipes');
        if ($request->filled('search')) {
            $search = trim((string) $request->input('search'));
            $query->where('name', 'like', "%{$search}%");
        }
        if ($request->filled('category')) {
            $query->where('category', (string) $request->input('category'));
        }
        return view('admin.ingredients.index', [
            'ingredients' => $query->orderBy('category')->orderBy('name')->paginate(30)->withQueryString(),
            'categories' => Ingredient::query()->select('category')->distinct()->orderBy('category')->pluck('category'),
        ]);
    }

    public function create()
    {
        return view('admin.ingredients.create', ['ingredient' => new Ingredient()]);
    }

    public function store(Request $request)
    {
        Ingredient::create($this->validated($request));
        return redirect()->route('admin.ingredients.index')->with('success', 'Ingredient created.');
    }

    public function edit(Ingredient $ingredient)
    {
        return view('admin.ingredients.edit', compact('ingredient'));
    }

    public function update(Request $request, Ingredient $ingredient)
    {
        $ingredient->update($this->validated($request, $ingredient));
        return back()->with('success', 'Ingredient updated.');
    }

    public function destroy(Ingredient $ingredient)
    {
        if ($ingredient->recipes()->exists()) {
            return back()->withErrors(['ingredient' => 'This ingredient is used by recipes and cannot be deleted.']);
        }
        $ingredient->delete();
        return redirect()->route('admin.ingredients.index')->with('success', 'Ingredient deleted.');
    }

    private function validated(Request $request, ?Ingredient $ingredient = null): array
    {
        $id = $ingredient?->id;
        $data = $request->validate([
            'name' => ['required', 'string', 'max:160', Rule::unique('ingredients', 'name')->ignore($id)],
            'category' => ['required', 'string', 'max:80'],
            'default_unit' => ['nullable', 'string', 'max:30'],
            'is_active' => ['nullable', 'boolean'],
        ]);
        $data['slug'] = Str::slug($data['name']);
        $data['is_active'] = $request->boolean('is_active');
        return $data;
    }
}
