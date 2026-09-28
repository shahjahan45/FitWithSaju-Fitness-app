<?php

namespace Database\Seeders;

use App\Models\MealPlanTemplate;
use Illuminate\Database\Seeder;

class MealPlanTemplateSeeder extends Seeder
{
    public function run(): void
    {
        MealPlanTemplate::updateOrCreate(
            ['slug' => 'balanced-week-sample'],
            [
                'name' => 'Balanced Week · Sample',
                'description' => 'Sample weekly structure using FitWithSaju recipe IDs. Nutrition remains estimated until reviewed.',
                'goal' => 'Balanced eating',
                'days' => $this->days(),
                'status' => 'published',
                'sort_order' => 0,
            ]
        );
    }

    private function days(): array
    {
        $rotations = [
            ['berry_oats','chicken_rice','salmon_greens','yogurt_berries'],
            ['avocado_eggs','lentil_bowl','beef_quinoa','apple_peanut'],
            ['banana_chia','tuna_wrap','tofu_stirfry','hummus_veg'],
        ];
        $days = [];
        foreach (['monday','tuesday','wednesday','thursday','friday','saturday','sunday'] as $index => $day) {
            $r = $rotations[$index % 3];
            $days[$day] = [
                ['slot' => 'Breakfast', 'recipe_id' => $r[0], 'time' => '08:00', 'servings' => 1],
                ['slot' => 'Lunch', 'recipe_id' => $r[1], 'time' => '13:00', 'servings' => 1],
                ['slot' => 'Snack', 'recipe_id' => $r[3], 'time' => '16:30', 'servings' => 1],
                ['slot' => 'Dinner', 'recipe_id' => $r[2], 'time' => '19:00', 'servings' => 1],
            ];
        }
        return $days;
    }
}
