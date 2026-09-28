<?php

namespace Database\Seeders;

use App\Models\MealPlanTemplate;
use Illuminate\Database\Seeder;

class MealPlanTemplateSeeder extends Seeder
{
    public function run(): void
    {
        MealPlanTemplate::updateOrCreate(
            ['slug' => 'high-protein-7-day'],
            [
                'name' => '7-Day High-Protein',
                'description' => 'Four meals per day based on the supplied high-protein reference. Daily protein ranges from 190–205 g (about 196 g/day average). Protein values follow the reference; other macros are estimates pending review.',
                'goal' => 'Muscle gain',
                'days' => $this->highProteinDays(),
                'status' => 'published',
                'sort_order' => 0,
            ]
        );

        MealPlanTemplate::updateOrCreate(
            ['slug' => 'balanced-week-sample'],
            [
                'name' => 'Balanced Week · Sample',
                'description' => 'Sample weekly structure using FitWithSaju recipe IDs. Nutrition remains estimated until reviewed.',
                'goal' => 'Balanced eating',
                'days' => $this->days(),
                'status' => 'published',
                'sort_order' => 10,
            ]
        );
    }

    private function highProteinDays(): array
    {
        return [
            'monday' => [
                ['slot' => 'Breakfast', 'recipe_id' => 'hp_eggs_whites_berries', 'time' => '08:00', 'servings' => 1],
                ['slot' => 'Lunch', 'recipe_id' => 'hp_chicken_rice_broccoli', 'time' => '13:00', 'servings' => 1],
                ['slot' => 'Snack', 'recipe_id' => 'hp_yogurt_whey_berries', 'time' => '16:30', 'servings' => 1],
                ['slot' => 'Dinner', 'recipe_id' => 'hp_salmon_vegetables', 'time' => '19:00', 'servings' => 1],
            ],
            'tuesday' => [
                ['slot' => 'Breakfast', 'recipe_id' => 'hp_protein_oatmeal_yogurt', 'time' => '08:00', 'servings' => 1],
                ['slot' => 'Lunch', 'recipe_id' => 'hp_beef_potatoes_veg', 'time' => '13:00', 'servings' => 1],
                ['slot' => 'Snack', 'recipe_id' => 'hp_cottage_berries_eggs', 'time' => '16:30', 'servings' => 1],
                ['slot' => 'Dinner', 'recipe_id' => 'hp_chicken_salad', 'time' => '19:00', 'servings' => 1],
            ],
            'wednesday' => [
                ['slot' => 'Breakfast', 'recipe_id' => 'hp_eggs_turkey_toast', 'time' => '08:00', 'servings' => 1],
                ['slot' => 'Lunch', 'recipe_id' => 'hp_shrimp_rice_veg', 'time' => '13:00', 'servings' => 1],
                ['slot' => 'Snack', 'recipe_id' => 'hp_yogurt_whey_berries', 'time' => '16:30', 'servings' => 1],
                ['slot' => 'Dinner', 'recipe_id' => 'hp_steak_vegetables', 'time' => '19:00', 'servings' => 1],
            ],
            'thursday' => [
                ['slot' => 'Breakfast', 'recipe_id' => 'hp_eggwhite_omelet_turkey', 'time' => '08:00', 'servings' => 1],
                ['slot' => 'Lunch', 'recipe_id' => 'hp_chicken_sweetpotato_broccoli', 'time' => '13:00', 'servings' => 1],
                ['slot' => 'Snack', 'recipe_id' => 'hp_shake_yogurt', 'time' => '16:30', 'servings' => 1],
                ['slot' => 'Dinner', 'recipe_id' => 'hp_whitefish_vegetables', 'time' => '19:00', 'servings' => 1],
            ],
            'friday' => [
                ['slot' => 'Breakfast', 'recipe_id' => 'hp_pancakes_eggs', 'time' => '08:00', 'servings' => 1],
                ['slot' => 'Lunch', 'recipe_id' => 'hp_beef_rice_veg', 'time' => '13:00', 'servings' => 1],
                ['slot' => 'Snack', 'recipe_id' => 'hp_cottage_whey_berries', 'time' => '16:30', 'servings' => 1],
                ['slot' => 'Dinner', 'recipe_id' => 'hp_salmon_salad', 'time' => '19:00', 'servings' => 1],
            ],
            'saturday' => [
                ['slot' => 'Breakfast', 'recipe_id' => 'hp_eggs_whites_yogurt', 'time' => '08:00', 'servings' => 1],
                ['slot' => 'Lunch', 'recipe_id' => 'hp_steak_potatoes_veg', 'time' => '13:00', 'servings' => 1],
                ['slot' => 'Snack', 'recipe_id' => 'hp_shake_cottage', 'time' => '16:30', 'servings' => 1],
                ['slot' => 'Dinner', 'recipe_id' => 'hp_chicken_vegetables', 'time' => '19:00', 'servings' => 1],
            ],
            'sunday' => [
                ['slot' => 'Breakfast', 'recipe_id' => 'hp_protein_oatmeal_eggs', 'time' => '08:00', 'servings' => 1],
                ['slot' => 'Lunch', 'recipe_id' => 'hp_chicken_rice_vegetables', 'time' => '13:00', 'servings' => 1],
                ['slot' => 'Snack', 'recipe_id' => 'hp_yogurt_whey_fruit', 'time' => '16:30', 'servings' => 1],
                ['slot' => 'Dinner', 'recipe_id' => 'hp_shrimp_vegetables', 'time' => '19:00', 'servings' => 1],
            ],
        ];
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
