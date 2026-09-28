<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Exercise;
use App\Models\Ingredient;
use App\Models\MealPlanTemplate;
use App\Models\Recipe;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    public function __invoke(Request $request)
    {
        $query = trim((string) $request->string('q'));

        $exercises = collect();
        $recipes = collect();
        $ingredients = collect();
        $templates = collect();

        if ($query !== '') {
            $like = '%'.$query.'%';

            $exercises = Exercise::query()
                ->where(fn ($q) => $q->where('name', 'like', $like)->orWhere('source_id', 'like', $like))
                ->latest('updated_at')->limit(8)->get();

            $recipes = Recipe::query()
                ->where(fn ($q) => $q->where('name', 'like', $like)->orWhere('source_id', 'like', $like)->orWhere('cuisine', 'like', $like))
                ->latest('updated_at')->limit(8)->get();

            $ingredients = Ingredient::query()
                ->where(fn ($q) => $q->where('name', 'like', $like)->orWhere('category', 'like', $like))
                ->latest('updated_at')->limit(8)->get();

            $templates = MealPlanTemplate::query()
                ->where(fn ($q) => $q->where('name', 'like', $like)->orWhere('goal', 'like', $like)->orWhere('slug', 'like', $like))
                ->latest('updated_at')->limit(8)->get();
        }

        return view('admin.search.index', compact('query', 'exercises', 'recipes', 'ingredients', 'templates'));
    }
}
