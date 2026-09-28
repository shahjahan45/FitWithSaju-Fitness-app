<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MealPlanTemplateResource;
use App\Models\MealPlanTemplate;
use Illuminate\Http\Request;

class MealPlanTemplateController extends Controller
{
    public function index(Request $request)
    {
        $query = MealPlanTemplate::query()->published();
        if ($request->filled('goal')) {
            $query->where('goal', (string) $request->input('goal'));
        }
        return MealPlanTemplateResource::collection(
            $query->orderBy('sort_order')->orderBy('name')->get()
        );
    }

    public function show(string $template)
    {
        return new MealPlanTemplateResource(
            MealPlanTemplate::query()->published()->where('slug', $template)->firstOrFail()
        );
    }
}
