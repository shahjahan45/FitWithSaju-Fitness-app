<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\RecipeResource;
use App\Models\Recipe;
use Illuminate\Http\Request;

class RecipeController extends Controller
{
    public function index(Request $request)
    {
        $query = Recipe::query()->published()->with('ingredients');

        if ($request->filled('search')) {
            $search = trim((string) $request->input('search'));
            $query->where(function ($builder) use ($search) {
                $builder->where('name', 'like', "%{$search}%")
                    ->orWhere('source_id', 'like', "%{$search}%")
                    ->orWhere('cuisine', 'like', "%{$search}%");
            });
        }
        if ($request->filled('slot')) {
            $query->where('slot', (string) $request->input('slot'));
        }
        if ($request->filled('cuisine')) {
            $query->where('cuisine', (string) $request->input('cuisine'));
        }
        if ($request->filled('dietary')) {
            $query->whereJsonContains('dietary_tags', (string) $request->input('dietary'));
        }
        if ($request->filled('exclude_allergen')) {
            $allergen = (string) $request->input('exclude_allergen');
            $query->where(function ($builder) use ($allergen) {
                $builder->whereNull('allergens')->orWhereJsonDoesntContain('allergens', $allergen);
            });
        }

        $perPage = min(max((int) $request->integer('per_page', 60), 1), 200);
        $items = $query->orderBy('sort_order')->orderBy('name')->paginate($perPage)->withQueryString();

        return RecipeResource::collection($items);
    }

    public function show(string $recipe)
    {
        $item = Recipe::query()
            ->published()
            ->with('ingredients')
            ->where(function ($query) use ($recipe) {
                $query->where('source_id', $recipe)->orWhere('slug', $recipe);
            })
            ->firstOrFail();

        return new RecipeResource($item);
    }
}
