<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Exercise;
use App\Models\Ingredient;
use App\Models\MealPlanTemplate;
use App\Models\Recipe;

class DashboardController extends Controller
{
    public function __invoke()
    {
        return view('admin.dashboard', [
            'exerciseCount' => Exercise::count(),
            'activeExerciseCount' => Exercise::active()->count(),
            'mediaCount' => Exercise::whereNotNull('media_path')->count(),
            'recipeCount' => Recipe::count(),
            'publishedRecipeCount' => Recipe::published()->count(),
            'ingredientCount' => Ingredient::count(),
            'templateCount' => MealPlanTemplate::count(),
            'recentExercises' => Exercise::latest('updated_at')->limit(4)->get(),
            'recentRecipes' => Recipe::latest('updated_at')->limit(4)->get(),
        ]);
    }
}
