<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MealPlanTemplate;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class MealPlanTemplateController extends Controller
{
    public function index(Request $request)
    {
        $query = MealPlanTemplate::query();
        if ($request->filled('search')) {
            $query->where('name', 'like', '%'.trim((string) $request->input('search')).'%');
        }
        if ($request->filled('status')) {
            $query->where('status', (string) $request->input('status'));
        }
        return view('admin.meal-templates.index', [
            'templates' => $query->orderBy('sort_order')->orderBy('name')->paginate(20)->withQueryString(),
        ]);
    }

    public function create()
    {
        return view('admin.meal-templates.create', ['template' => new MealPlanTemplate()]);
    }

    public function store(Request $request)
    {
        $template = MealPlanTemplate::create($this->validated($request));
        return redirect()->route('admin.meal-templates.edit', $template)->with('success', 'Meal plan template created.');
    }

    public function edit(MealPlanTemplate $meal_template)
    {
        return view('admin.meal-templates.edit', ['template' => $meal_template]);
    }

    public function update(Request $request, MealPlanTemplate $meal_template)
    {
        $meal_template->update($this->validated($request, $meal_template));
        return back()->with('success', 'Meal plan template updated.');
    }

    public function destroy(MealPlanTemplate $meal_template)
    {
        $meal_template->delete();
        return redirect()->route('admin.meal-templates.index')->with('success', 'Meal plan template deleted.');
    }

    private function validated(Request $request, ?MealPlanTemplate $template = null): array
    {
        $id = $template?->id;
        $data = $request->validate([
            'name' => ['required', 'string', 'max:180'],
            'slug' => ['nullable', 'string', 'max:190', Rule::unique('meal_plan_templates', 'slug')->ignore($id)],
            'description' => ['nullable', 'string', 'max:3000'],
            'goal' => ['required', 'string', 'max:80'],
            'days_json' => ['required', 'string', 'max:50000'],
            'status' => ['required', Rule::in(['draft', 'published', 'inactive'])],
            'sort_order' => ['required', 'integer', 'min:0', 'max:100000'],
        ]);
        $decoded = json_decode($data['days_json'], true);
        if (! is_array($decoded)) {
            throw ValidationException::withMessages(['days_json' => 'Days must be valid JSON.']);
        }
        $data['slug'] = $data['slug'] ?: Str::slug($data['name']);
        $data['days'] = $decoded;
        unset($data['days_json']);
        return $data;
    }
}
