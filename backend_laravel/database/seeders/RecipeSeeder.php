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

        $highProtein = array_replace($common, [
            'nutrition_provenance' => 'User-supplied 7-day high-protein reference: protein values follow the reference; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
        ]);

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
            $highProtein + [
                'source_id' => 'hp_eggs_whites_berries', 'name' => 'Eggs, egg whites & berries', 'slug' => 'hp-eggs-whites-berries', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 12, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 430, 'protein' => 40, 'carbs' => 32, 'fat' => 15, 'artwork' => '🍳', 'dietary_tags' => ['High-protein','Gluten-free'], 'allergens' => ['Eggs'],
                'ingredients' => [
                    ['Eggs',3,'pcs','Protein'],
                    ['Egg whites',240,'ml','Protein'],
                    ['Mixed berries',120,'g','Produce'],
                ],
                'instructions' => [
                    'Scramble the eggs and egg whites until fully cooked.',
                    'Serve with fresh berries.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_chicken_rice_broccoli', 'name' => 'Chicken, rice & broccoli', 'slug' => 'hp-chicken-rice-broccoli', 'slot' => 'Lunch', 'cuisine' => 'International', 'prep_minutes' => 25, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 620, 'protein' => 55, 'carbs' => 72, 'fat' => 12, 'artwork' => '🍗', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [
                    ['Chicken breast',170,'g','Protein'],
                    ['Basmati rice',180,'g','Pantry'],
                    ['Broccoli',180,'g','Produce'],
                    ['Olive oil',8,'ml','Pantry'],
                ],
                'instructions' => [
                    'Season and cook the chicken thoroughly.',
                    'Cook rice and steam broccoli.',
                    'Serve together with measured olive oil.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_yogurt_whey_berries', 'name' => 'Greek yogurt, whey & berries', 'slug' => 'hp-yogurt-whey-berries', 'slot' => 'Snack', 'cuisine' => 'International', 'prep_minutes' => 4, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 330, 'protein' => 45, 'carbs' => 30, 'fat' => 5, 'artwork' => '🫐', 'dietary_tags' => ['High-protein','Vegetarian','Gluten-free'], 'allergens' => ['Dairy'],
                'ingredients' => [
                    ['Greek yogurt',250,'g','Dairy'],
                    ['Whey protein',30,'g','Protein'],
                    ['Mixed berries',100,'g','Produce'],
                ],
                'instructions' => [
                    'Stir whey into yogurt until smooth.',
                    'Top with berries.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_salmon_vegetables', 'name' => 'Salmon & vegetables', 'slug' => 'hp-salmon-vegetables', 'slot' => 'Dinner', 'cuisine' => 'International', 'prep_minutes' => 25, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 560, 'protein' => 50, 'carbs' => 22, 'fat' => 28, 'artwork' => '🐟', 'dietary_tags' => ['High-protein','Gluten-free'], 'allergens' => ['Fish'],
                'ingredients' => [
                    ['Salmon fillet',200,'g','Protein'],
                    ['Mixed vegetables',250,'g','Produce'],
                    ['Olive oil',8,'ml','Pantry'],
                ],
                'instructions' => [
                    'Season salmon and bake or pan-sear until cooked.',
                    'Cook vegetables until tender-crisp.',
                    'Serve together.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_protein_oatmeal_yogurt', 'name' => 'Protein oatmeal & Greek yogurt', 'slug' => 'hp-protein-oatmeal-yogurt', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 8, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 520, 'protein' => 50, 'carbs' => 60, 'fat' => 10, 'artwork' => '🥣', 'dietary_tags' => ['High-protein','Vegetarian'], 'allergens' => ['Dairy','Gluten'],
                'ingredients' => [
                    ['Rolled oats',70,'g','Pantry'],
                    ['Whey protein',45,'g','Protein'],
                    ['Greek yogurt',180,'g','Dairy'],
                    ['Banana',0.5,'pcs','Produce'],
                ],
                'instructions' => [
                    'Cook oats with water or milk.',
                    'Stir in whey after removing from heat.',
                    'Serve with Greek yogurt and banana.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_beef_potatoes_veg', 'name' => 'Lean beef, potatoes & vegetables', 'slug' => 'hp-beef-potatoes-veg', 'slot' => 'Lunch', 'cuisine' => 'International', 'prep_minutes' => 30, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 610, 'protein' => 45, 'carbs' => 55, 'fat' => 22, 'artwork' => '🥩', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [
                    ['Lean ground beef',170,'g','Protein'],
                    ['Potatoes',280,'g','Produce'],
                    ['Mixed vegetables',180,'g','Produce'],
                ],
                'instructions' => [
                    'Cook lean beef thoroughly.',
                    'Roast or boil potatoes.',
                    'Cook vegetables and serve together.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_cottage_berries_eggs', 'name' => 'Cottage cheese, berries & eggs', 'slug' => 'hp-cottage-berries-eggs', 'slot' => 'Snack', 'cuisine' => 'International', 'prep_minutes' => 10, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 380, 'protein' => 40, 'carbs' => 25, 'fat' => 14, 'artwork' => '🧀', 'dietary_tags' => ['High-protein','Vegetarian','Gluten-free'], 'allergens' => ['Dairy','Eggs'],
                'ingredients' => [
                    ['Cottage cheese',220,'g','Dairy'],
                    ['Mixed berries',100,'g','Produce'],
                    ['Eggs',2,'pcs','Protein'],
                ],
                'instructions' => [
                    'Cook eggs to preference.',
                    'Serve with cottage cheese and berries.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_chicken_salad', 'name' => 'Chicken breast & salad', 'slug' => 'hp-chicken-salad', 'slot' => 'Dinner', 'cuisine' => 'International', 'prep_minutes' => 20, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 520, 'protein' => 60, 'carbs' => 18, 'fat' => 18, 'artwork' => '🥗', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [
                    ['Chicken breast',200,'g','Protein'],
                    ['Mixed salad greens',180,'g','Produce'],
                    ['Tomato',100,'g','Produce'],
                    ['Olive oil',10,'ml','Pantry'],
                ],
                'instructions' => [
                    'Grill chicken until fully cooked.',
                    'Toss salad vegetables with olive oil and seasoning.',
                    'Slice chicken and serve over salad.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_eggs_turkey_toast', 'name' => 'Eggs, egg whites, turkey & toast', 'slug' => 'hp-eggs-turkey-toast', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 15, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 540, 'protein' => 50, 'carbs' => 38, 'fat' => 22, 'artwork' => '🍳', 'dietary_tags' => ['High-protein','Halal'], 'allergens' => ['Eggs','Gluten'],
                'ingredients' => [
                    ['Eggs',3,'pcs','Protein'],
                    ['Egg whites',240,'ml','Protein'],
                    ['Turkey breast slices',100,'g','Protein'],
                    ['Whole-grain bread',2,'slices','Bakery'],
                ],
                'instructions' => [
                    'Cook eggs and egg whites.',
                    'Warm turkey slices.',
                    'Serve with toasted bread.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_shrimp_rice_veg', 'name' => 'Shrimp, rice & vegetables', 'slug' => 'hp-shrimp-rice-veg', 'slot' => 'Lunch', 'cuisine' => 'International', 'prep_minutes' => 22, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 560, 'protein' => 45, 'carbs' => 65, 'fat' => 10, 'artwork' => '🍤', 'dietary_tags' => ['High-protein','Gluten-free'], 'allergens' => ['Shellfish'],
                'ingredients' => [
                    ['Shrimp',200,'g','Protein'],
                    ['Basmati rice',180,'g','Pantry'],
                    ['Mixed vegetables',180,'g','Produce'],
                ],
                'instructions' => [
                    'Cook rice.',
                    'Sauté shrimp until opaque and fully cooked.',
                    'Add vegetables and serve with rice.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_steak_vegetables', 'name' => 'Lean steak & vegetables', 'slug' => 'hp-steak-vegetables', 'slot' => 'Dinner', 'cuisine' => 'International', 'prep_minutes' => 25, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 570, 'protein' => 55, 'carbs' => 20, 'fat' => 25, 'artwork' => '🥩', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [
                    ['Lean steak',200,'g','Protein'],
                    ['Mixed vegetables',250,'g','Produce'],
                    ['Olive oil',8,'ml','Pantry'],
                ],
                'instructions' => [
                    'Season and cook steak to a safe internal temperature.',
                    'Cook vegetables until tender.',
                    'Rest steak before slicing.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_eggwhite_omelet_turkey', 'name' => 'Egg-white omelet, eggs & turkey', 'slug' => 'hp-eggwhite-omelet-turkey', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 15, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 500, 'protein' => 50, 'carbs' => 15, 'fat' => 25, 'artwork' => '🥚', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => ['Eggs'],
                'ingredients' => [
                    ['Egg whites',250,'ml','Protein'],
                    ['Eggs',3,'pcs','Protein'],
                    ['Turkey breast slices',100,'g','Protein'],
                    ['Spinach',80,'g','Produce'],
                ],
                'instructions' => [
                    'Cook spinach briefly.',
                    'Add egg whites and eggs to form an omelet.',
                    'Fill with warmed turkey and fold.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_chicken_sweetpotato_broccoli', 'name' => 'Chicken, sweet potato & broccoli', 'slug' => 'hp-chicken-sweetpotato-broccoli', 'slot' => 'Lunch', 'cuisine' => 'International', 'prep_minutes' => 28, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 620, 'protein' => 60, 'carbs' => 60, 'fat' => 15, 'artwork' => '🍗', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [
                    ['Chicken breast',200,'g','Protein'],
                    ['Sweet potato',300,'g','Produce'],
                    ['Broccoli',180,'g','Produce'],
                    ['Olive oil',8,'ml','Pantry'],
                ],
                'instructions' => [
                    'Roast sweet potato.',
                    'Cook chicken thoroughly.',
                    'Steam broccoli and serve together.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_shake_yogurt', 'name' => 'Protein shake & Greek yogurt', 'slug' => 'hp-shake-yogurt', 'slot' => 'Snack', 'cuisine' => 'International', 'prep_minutes' => 3, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 300, 'protein' => 45, 'carbs' => 20, 'fat' => 5, 'artwork' => '🥤', 'dietary_tags' => ['High-protein','Vegetarian','Gluten-free'], 'allergens' => ['Dairy'],
                'ingredients' => [
                    ['Whey protein',40,'g','Protein'],
                    ['Greek yogurt',200,'g','Dairy'],
                    ['Water',300,'ml','Beverages'],
                ],
                'instructions' => [
                    'Shake whey with cold water.',
                    'Serve with Greek yogurt.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_whitefish_vegetables', 'name' => 'White fish & vegetables', 'slug' => 'hp-whitefish-vegetables', 'slot' => 'Dinner', 'cuisine' => 'International', 'prep_minutes' => 22, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 470, 'protein' => 45, 'carbs' => 25, 'fat' => 18, 'artwork' => '🐟', 'dietary_tags' => ['High-protein','Gluten-free'], 'allergens' => ['Fish'],
                'ingredients' => [
                    ['White fish fillet',210,'g','Protein'],
                    ['Mixed vegetables',250,'g','Produce'],
                    ['Olive oil',10,'ml','Pantry'],
                ],
                'instructions' => [
                    'Season and bake fish until opaque and flaky.',
                    'Cook vegetables and serve alongside.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_pancakes_eggs', 'name' => 'Protein pancakes & eggs', 'slug' => 'hp-pancakes-eggs', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 18, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 520, 'protein' => 45, 'carbs' => 55, 'fat' => 15, 'artwork' => '🥞', 'dietary_tags' => ['High-protein','Vegetarian'], 'allergens' => ['Eggs','Dairy','Gluten'],
                'ingredients' => [
                    ['Protein pancake mix',90,'g','Pantry'],
                    ['Whey protein',25,'g','Protein'],
                    ['Eggs',2,'pcs','Protein'],
                    ['Mixed berries',80,'g','Produce'],
                ],
                'instructions' => [
                    'Prepare pancake batter with protein powder.',
                    'Cook pancakes on a non-stick pan.',
                    'Serve with cooked eggs and berries.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_beef_rice_veg', 'name' => 'Lean beef, rice & vegetables', 'slug' => 'hp-beef-rice-veg', 'slot' => 'Lunch', 'cuisine' => 'International', 'prep_minutes' => 28, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 640, 'protein' => 50, 'carbs' => 65, 'fat' => 20, 'artwork' => '🥩', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [
                    ['Lean ground beef',190,'g','Protein'],
                    ['Basmati rice',180,'g','Pantry'],
                    ['Mixed vegetables',180,'g','Produce'],
                ],
                'instructions' => [
                    'Cook rice.',
                    'Cook beef thoroughly and drain excess fat.',
                    'Serve with vegetables and rice.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_cottage_whey_berries', 'name' => 'Cottage cheese, whey & berries', 'slug' => 'hp-cottage-whey-berries', 'slot' => 'Snack', 'cuisine' => 'International', 'prep_minutes' => 4, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 390, 'protein' => 45, 'carbs' => 28, 'fat' => 12, 'artwork' => '🧀', 'dietary_tags' => ['High-protein','Vegetarian','Gluten-free'], 'allergens' => ['Dairy'],
                'ingredients' => [
                    ['Cottage cheese',220,'g','Dairy'],
                    ['Whey protein',25,'g','Protein'],
                    ['Mixed berries',100,'g','Produce'],
                ],
                'instructions' => [
                    'Stir whey into cottage cheese.',
                    'Top with berries.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_salmon_salad', 'name' => 'Salmon & salad', 'slug' => 'hp-salmon-salad', 'slot' => 'Dinner', 'cuisine' => 'International', 'prep_minutes' => 22, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 550, 'protein' => 50, 'carbs' => 20, 'fat' => 28, 'artwork' => '🐟', 'dietary_tags' => ['High-protein','Gluten-free'], 'allergens' => ['Fish'],
                'ingredients' => [
                    ['Salmon fillet',200,'g','Protein'],
                    ['Mixed salad greens',180,'g','Produce'],
                    ['Cucumber',100,'g','Produce'],
                    ['Olive oil',8,'ml','Pantry'],
                ],
                'instructions' => [
                    'Cook salmon until done.',
                    'Toss salad with vegetables and olive oil.',
                    'Serve salmon over salad.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_eggs_whites_yogurt', 'name' => 'Eggs, egg whites & Greek yogurt', 'slug' => 'hp-eggs-whites-yogurt', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 12, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 470, 'protein' => 45, 'carbs' => 20, 'fat' => 22, 'artwork' => '🍳', 'dietary_tags' => ['High-protein','Vegetarian','Gluten-free'], 'allergens' => ['Eggs','Dairy'],
                'ingredients' => [
                    ['Eggs',3,'pcs','Protein'],
                    ['Egg whites',240,'ml','Protein'],
                    ['Greek yogurt',180,'g','Dairy'],
                ],
                'instructions' => [
                    'Cook eggs and egg whites.',
                    'Serve with Greek yogurt.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_steak_potatoes_veg', 'name' => 'Steak, potatoes & vegetables', 'slug' => 'hp-steak-potatoes-veg', 'slot' => 'Lunch', 'cuisine' => 'International', 'prep_minutes' => 30, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 630, 'protein' => 55, 'carbs' => 50, 'fat' => 22, 'artwork' => '🥩', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [
                    ['Lean steak',200,'g','Protein'],
                    ['Potatoes',260,'g','Produce'],
                    ['Mixed vegetables',180,'g','Produce'],
                ],
                'instructions' => [
                    'Cook steak to a safe internal temperature.',
                    'Roast potatoes and vegetables.',
                    'Rest and slice steak before serving.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_shake_cottage', 'name' => 'Protein shake & cottage cheese', 'slug' => 'hp-shake-cottage', 'slot' => 'Snack', 'cuisine' => 'International', 'prep_minutes' => 3, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 320, 'protein' => 45, 'carbs' => 18, 'fat' => 8, 'artwork' => '🥤', 'dietary_tags' => ['High-protein','Vegetarian','Gluten-free'], 'allergens' => ['Dairy'],
                'ingredients' => [
                    ['Whey protein',35,'g','Protein'],
                    ['Cottage cheese',200,'g','Dairy'],
                    ['Water',300,'ml','Beverages'],
                ],
                'instructions' => [
                    'Shake whey with water.',
                    'Serve with cottage cheese.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_chicken_vegetables', 'name' => 'Chicken breast & vegetables', 'slug' => 'hp-chicken-vegetables', 'slot' => 'Dinner', 'cuisine' => 'International', 'prep_minutes' => 22, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 530, 'protein' => 60, 'carbs' => 20, 'fat' => 17, 'artwork' => '🍗', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [
                    ['Chicken breast',210,'g','Protein'],
                    ['Mixed vegetables',280,'g','Produce'],
                    ['Olive oil',8,'ml','Pantry'],
                ],
                'instructions' => [
                    'Cook chicken thoroughly.',
                    'Cook vegetables and serve alongside.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_protein_oatmeal_eggs', 'name' => 'Protein oatmeal & eggs', 'slug' => 'hp-protein-oatmeal-eggs', 'slot' => 'Breakfast', 'cuisine' => 'International', 'prep_minutes' => 12, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 500, 'protein' => 50, 'carbs' => 50, 'fat' => 12, 'artwork' => '🥣', 'dietary_tags' => ['High-protein'], 'allergens' => ['Eggs','Dairy','Gluten'],
                'ingredients' => [
                    ['Rolled oats',65,'g','Pantry'],
                    ['Whey protein',40,'g','Protein'],
                    ['Eggs',2,'pcs','Protein'],
                ],
                'instructions' => [
                    'Cook oats.',
                    'Stir in whey after removing from heat.',
                    'Serve with cooked eggs.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_chicken_rice_vegetables', 'name' => 'Chicken, rice & vegetables', 'slug' => 'hp-chicken-rice-vegetables', 'slot' => 'Lunch', 'cuisine' => 'International', 'prep_minutes' => 25, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 650, 'protein' => 60, 'carbs' => 70, 'fat' => 12, 'artwork' => '🍗', 'dietary_tags' => ['High-protein','Halal','Gluten-free'], 'allergens' => [],
                'ingredients' => [
                    ['Chicken breast',210,'g','Protein'],
                    ['Basmati rice',190,'g','Pantry'],
                    ['Mixed vegetables',180,'g','Produce'],
                ],
                'instructions' => [
                    'Cook rice.',
                    'Cook chicken thoroughly.',
                    'Cook vegetables and serve together.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_yogurt_whey_fruit', 'name' => 'Greek yogurt, whey & fruit', 'slug' => 'hp-yogurt-whey-fruit', 'slot' => 'Snack', 'cuisine' => 'International', 'prep_minutes' => 4, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 320, 'protein' => 45, 'carbs' => 30, 'fat' => 4, 'artwork' => '🫐', 'dietary_tags' => ['High-protein','Vegetarian','Gluten-free'], 'allergens' => ['Dairy'],
                'ingredients' => [
                    ['Greek yogurt',250,'g','Dairy'],
                    ['Whey protein',30,'g','Protein'],
                    ['Fresh fruit',120,'g','Produce'],
                ],
                'instructions' => [
                    'Stir whey into yogurt.',
                    'Top with chopped fruit.',
                ],
            ],
            $highProtein + [
                'source_id' => 'hp_shrimp_vegetables', 'name' => 'Shrimp & vegetables', 'slug' => 'hp-shrimp-vegetables', 'slot' => 'Dinner', 'cuisine' => 'International', 'prep_minutes' => 20, 'yield_servings' => 1, 'serving_label' => '1 serving', 'calories' => 480, 'protein' => 45, 'carbs' => 22, 'fat' => 16, 'artwork' => '🍤', 'dietary_tags' => ['High-protein','Gluten-free'], 'allergens' => ['Shellfish'],
                'ingredients' => [
                    ['Shrimp',210,'g','Protein'],
                    ['Mixed vegetables',280,'g','Produce'],
                    ['Olive oil',8,'ml','Pantry'],
                ],
                'instructions' => [
                    'Sauté shrimp until opaque and fully cooked.',
                    'Cook vegetables and serve together.',
                ],
            ],
        ];
    }
}
