<?php

namespace Database\Seeders;

use App\Models\Ingredient;
use App\Models\Recipe;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class RecipeSeeder extends Seeder
{
    public function run(): void
    {
        foreach ($this->items() as $sort => $item) {
            $ingredients = $item['ingredients'];
            unset($item['ingredients']);
            $recipe = Recipe::updateOrCreate(
                ['source_id' => $item['source_id']],
                $item + ['sort_order' => $sort]
            );
            $sync = [];
            foreach ($ingredients as $index => $row) {
                [$name, $quantity, $unit, $category] = $row;
                $ingredient = Ingredient::firstOrCreate(
                    ['name' => $name],
                    [
                        'slug' => Str::slug($name),
                        'category' => $category,
                        'default_unit' => $unit,
                        'is_active' => true,
                    ]
                );
                $sync[$ingredient->id] = [
                    'quantity' => $quantity,
                    'unit' => $unit,
                    'sort_order' => $index,
                ];
            }
            $recipe->ingredients()->sync($sync);
        }
    }

    private function items(): array
    {
        $common = [
            'nutrition_provenance' => 'FitWithSaju sample data · estimated nutrition',
            'review_status' => 'unreviewed',
            'reviewed_by' => null,
            'reviewed_at' => null,
            'status' => 'published',
        ];

        return [
            $common + [
                'source_id' => 'berry_oats', 'name' => 'Berry overnight oats', 'slug' => 'berry-overnight-oats', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 10, 'yield_servings' => 1, 'serving_label' => '1 bowl', 'calories' => 420, 'protein' => 25, 'carbs' => 53, 'fat' => 12, 'artwork' => '🥣', 'dietary_tags' => ['Vegetarian'], 'allergens' => ['Dairy','Gluten'],
                'ingredients' => [['Rolled oats',60,'g','Pantry'],['Greek yogurt',120,'g','Dairy'],['Mixed berries',100,'g','Produce'],['Chia seeds',12,'g','Pantry']],
                'instructions' => ['Mix oats, yogurt, chia seeds, and a splash of water in a jar.','Cover and refrigerate for at least 4 hours or overnight.','Top with berries immediately before eating.'],
            ],
            $common + [
                'source_id' => 'avocado_eggs', 'name' => 'Avocado eggs & toast', 'slug' => 'avocado-eggs-toast', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 12, 'yield_servings' => 1, 'serving_label' => '1 plate', 'calories' => 445, 'protein' => 24, 'carbs' => 38, 'fat' => 23, 'artwork' => '🥑', 'dietary_tags' => ['Vegetarian'], 'allergens' => ['Eggs','Gluten'],
                'ingredients' => [['Eggs',2,'pcs','Protein'],['Whole-grain bread',2,'slices','Bakery'],['Avocado',0.5,'pcs','Produce'],['Tomato',80,'g','Produce']],
                'instructions' => ['Toast the bread and mash avocado over the slices.','Cook eggs to your preferred doneness.','Serve with sliced tomato and season to taste.'],
            ],
            $common + [
                'source_id' => 'banana_chia', 'name' => 'Banana chia breakfast pot', 'slug' => 'banana-chia-breakfast-pot', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 8, 'yield_servings' => 1, 'serving_label' => '1 pot', 'calories' => 380, 'protein' => 17, 'carbs' => 52, 'fat' => 13, 'artwork' => '🍌', 'dietary_tags' => ['Vegetarian','Gluten-free'], 'allergens' => ['Dairy'],
                'ingredients' => [['Banana',1,'pcs','Produce'],['Greek yogurt',150,'g','Dairy'],['Chia seeds',18,'g','Pantry'],['Honey',8,'g','Pantry']],
                'instructions' => ['Slice half the banana and mash the rest.','Mix mashed banana with yogurt and chia seeds.','Top with banana slices and a small drizzle of honey.'],
            ],
            $common + [
                'source_id' => 'chicken_rice', 'name' => 'Grilled chicken rice bowl', 'slug' => 'grilled-chicken-rice-bowl', 'slot' => 'Lunch', 'cuisine' => 'Mediterranean', 'prep_minutes' => 25, 'yield_servings' => 2, 'serving_label' => '1 bowl', 'calories' => 560, 'protein' => 46, 'carbs' => 64, 'fat' => 13, 'artwork' => '🍗', 'dietary_tags' => ['Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [['Chicken breast',300,'g','Protein'],['Basmati rice',160,'g','Pantry'],['Cucumber',140,'g','Produce'],['Tomato',140,'g','Produce'],['Olive oil',16,'ml','Pantry']],
                'instructions' => ['Season and grill chicken until fully cooked, then rest and slice.','Cook rice according to package instructions.','Divide rice, chicken, cucumber, and tomato into bowls.','Finish with olive oil, lemon, and herbs.'],
            ],
            $common + [
                'source_id' => 'lentil_bowl', 'name' => 'Lentil tahini power bowl', 'slug' => 'lentil-tahini-power-bowl', 'slot' => 'Lunch', 'cuisine' => 'Middle Eastern', 'prep_minutes' => 20, 'yield_servings' => 2, 'serving_label' => '1 bowl', 'calories' => 510, 'protein' => 24, 'carbs' => 66, 'fat' => 18, 'artwork' => '🥗', 'dietary_tags' => ['Vegetarian','Vegan','Gluten-free'], 'allergens' => ['Sesame'],
                'ingredients' => [['Cooked lentils',320,'g','Pantry'],['Quinoa',120,'g','Pantry'],['Spinach',120,'g','Produce'],['Tahini',32,'g','Pantry'],['Carrot',140,'g','Produce']],
                'instructions' => ['Cook quinoa and allow it to cool slightly.','Warm lentils and prepare the vegetables.','Assemble bowls and drizzle with lemon-tahini dressing.'],
            ],
            $common + [
                'source_id' => 'tuna_wrap', 'name' => 'Tuna crunch wrap', 'slug' => 'tuna-crunch-wrap', 'slot' => 'Lunch', 'cuisine' => 'International', 'prep_minutes' => 12, 'yield_servings' => 1, 'serving_label' => '1 wrap', 'calories' => 495, 'protein' => 39, 'carbs' => 49, 'fat' => 16, 'artwork' => '🌯', 'dietary_tags' => ['Halal'], 'allergens' => ['Fish','Gluten','Dairy'],
                'ingredients' => [['Tuna',120,'g','Protein'],['Whole-grain wrap',1,'pcs','Bakery'],['Greek yogurt',35,'g','Dairy'],['Lettuce',50,'g','Produce'],['Cucumber',60,'g','Produce']],
                'instructions' => ['Mix tuna with yogurt and seasoning.','Layer lettuce, cucumber, and tuna onto the wrap.','Fold tightly and serve immediately.'],
            ],
            $common + [
                'source_id' => 'salmon_greens', 'name' => 'Herb salmon & greens', 'slug' => 'herb-salmon-greens', 'slot' => 'Dinner', 'cuisine' => 'Mediterranean', 'prep_minutes' => 28, 'yield_servings' => 2, 'serving_label' => '1 plate', 'calories' => 585, 'protein' => 43, 'carbs' => 42, 'fat' => 27, 'artwork' => '🐟', 'dietary_tags' => ['Gluten-free'], 'allergens' => ['Fish'],
                'ingredients' => [['Salmon fillet',300,'g','Protein'],['Baby potatoes',360,'g','Produce'],['Green beans',240,'g','Produce'],['Olive oil',18,'ml','Pantry']],
                'instructions' => ['Roast potatoes until golden and tender.','Season salmon with herbs and bake until cooked through.','Steam green beans and plate with salmon and potatoes.'],
            ],
            $common + [
                'source_id' => 'beef_quinoa', 'name' => 'Lean beef quinoa plate', 'slug' => 'lean-beef-quinoa-plate', 'slot' => 'Dinner', 'cuisine' => 'International', 'prep_minutes' => 30, 'yield_servings' => 2, 'serving_label' => '1 plate', 'calories' => 610, 'protein' => 48, 'carbs' => 55, 'fat' => 22, 'artwork' => '🥩', 'dietary_tags' => ['Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [['Lean beef',300,'g','Protein'],['Quinoa',150,'g','Pantry'],['Bell pepper',180,'g','Produce'],['Broccoli',220,'g','Produce']],
                'instructions' => ['Cook quinoa according to package instructions.','Sear seasoned beef and rest before slicing.','Sauté vegetables until tender-crisp and serve together.'],
            ],
            $common + [
                'source_id' => 'tofu_stirfry', 'name' => 'Ginger tofu stir-fry', 'slug' => 'ginger-tofu-stir-fry', 'slot' => 'Dinner', 'cuisine' => 'Asian', 'prep_minutes' => 24, 'yield_servings' => 2, 'serving_label' => '1 bowl', 'calories' => 520, 'protein' => 29, 'carbs' => 62, 'fat' => 19, 'artwork' => '🍲', 'dietary_tags' => ['Vegetarian','Vegan'], 'allergens' => ['Soy'],
                'ingredients' => [['Firm tofu',320,'g','Protein'],['Jasmine rice',150,'g','Pantry'],['Broccoli',220,'g','Produce'],['Bell pepper',160,'g','Produce'],['Soy sauce',24,'ml','Pantry']],
                'instructions' => ['Press and cube tofu, then sear until golden.','Cook rice and stir-fry the vegetables.','Add tofu, ginger, and sauce; toss briefly and serve.'],
            ],
            $common + [
                'source_id' => 'yogurt_berries', 'name' => 'Greek yogurt & berries', 'slug' => 'greek-yogurt-berries', 'slot' => 'Snack', 'cuisine' => 'International', 'prep_minutes' => 3, 'yield_servings' => 1, 'serving_label' => '1 bowl', 'calories' => 215, 'protein' => 20, 'carbs' => 27, 'fat' => 4, 'artwork' => '🫐', 'dietary_tags' => ['Vegetarian','Gluten-free'], 'allergens' => ['Dairy'],
                'ingredients' => [['Greek yogurt',180,'g','Dairy'],['Mixed berries',100,'g','Produce'],['Honey',8,'g','Pantry']],
                'instructions' => ['Add yogurt to a bowl, top with berries, and drizzle with honey.'],
            ],
            $common + [
                'source_id' => 'apple_peanut', 'name' => 'Apple & peanut snack', 'slug' => 'apple-peanut-snack', 'slot' => 'Snack', 'cuisine' => 'International', 'prep_minutes' => 3, 'yield_servings' => 1, 'serving_label' => '1 snack', 'calories' => 235, 'protein' => 7, 'carbs' => 31, 'fat' => 11, 'artwork' => '🍎', 'dietary_tags' => ['Vegetarian','Vegan','Gluten-free'], 'allergens' => ['Peanuts'],
                'ingredients' => [['Apple',1,'pcs','Produce'],['Peanut butter',24,'g','Pantry']],
                'instructions' => ['Slice the apple and serve with measured peanut butter.'],
            ],
            $common + [
                'source_id' => 'hummus_veg', 'name' => 'Hummus veggie snack box', 'slug' => 'hummus-veggie-snack-box', 'slot' => 'Snack', 'cuisine' => 'Middle Eastern', 'prep_minutes' => 5, 'yield_servings' => 1, 'serving_label' => '1 box', 'calories' => 225, 'protein' => 8, 'carbs' => 28, 'fat' => 10, 'artwork' => '🥕', 'dietary_tags' => ['Vegetarian','Vegan','Gluten-free'], 'allergens' => ['Sesame'],
                'ingredients' => [['Hummus',65,'g','Pantry'],['Carrot',100,'g','Produce'],['Cucumber',100,'g','Produce']],
                'instructions' => ['Cut vegetables into sticks and serve with hummus.'],
            ],
        ];
    }
}
