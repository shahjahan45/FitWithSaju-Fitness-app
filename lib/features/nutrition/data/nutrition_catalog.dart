import 'nutrition_models.dart';

class NutritionCatalog {
  NutritionCatalog._();

  static const List<NutritionRecipe> recipes = [
    NutritionRecipe(
      id: 'berry_oats',
      name: 'Berry overnight oats',
      slot: 'Breakfast',
      artwork: '🥣',
      artworkAsset: 'assets/nutrition/oats.png',
      cuisine: 'International',
      prepMinutes: 10,
      yieldServings: 1,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 420, protein: 25, carbs: 53, fat: 12),
      dietaryTags: ['Vegetarian'],
      allergens: ['Dairy', 'Gluten'],
      ingredients: [
        NutritionIngredient(
            name: 'Rolled oats', quantity: 60, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 120, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Mixed berries',
            quantity: 100,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Chia seeds', quantity: 12, unit: 'g', category: 'Pantry'),
      ],
      instructions: [
        'Mix oats, yogurt, chia seeds, and a splash of water in a jar.',
        'Cover and refrigerate for at least 4 hours or overnight.',
        'Top with berries immediately before eating.',
      ],
    ),
    NutritionRecipe(
      id: 'avocado_eggs',
      name: 'Avocado eggs & toast',
      slot: 'Breakfast',
      artwork: '🥑',
      cuisine: 'International',
      prepMinutes: 12,
      yieldServings: 1,
      servingLabel: '1 plate',
      macros: NutritionMacros(calories: 445, protein: 24, carbs: 38, fat: 23),
      dietaryTags: ['Vegetarian'],
      allergens: ['Eggs', 'Gluten'],
      ingredients: [
        NutritionIngredient(
            name: 'Eggs', quantity: 2, unit: 'pcs', category: 'Protein'),
        NutritionIngredient(
            name: 'Whole-grain bread',
            quantity: 2,
            unit: 'slices',
            category: 'Bakery'),
        NutritionIngredient(
            name: 'Avocado', quantity: 0.5, unit: 'pcs', category: 'Produce'),
        NutritionIngredient(
            name: 'Tomato', quantity: 80, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Toast the bread and mash avocado over the slices.',
        'Cook eggs to your preferred doneness.',
        'Serve with sliced tomato and season to taste.',
      ],
    ),
    NutritionRecipe(
      id: 'banana_chia',
      name: 'Banana chia breakfast pot',
      slot: 'Breakfast',
      artwork: '🍌',
      cuisine: 'International',
      prepMinutes: 8,
      yieldServings: 1,
      servingLabel: '1 pot',
      macros: NutritionMacros(calories: 380, protein: 17, carbs: 52, fat: 13),
      dietaryTags: ['Vegetarian', 'Gluten-free'],
      allergens: ['Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Banana', quantity: 1, unit: 'pcs', category: 'Produce'),
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 150, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Chia seeds', quantity: 18, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Honey', quantity: 8, unit: 'g', category: 'Pantry'),
      ],
      instructions: [
        'Slice half the banana and mash the rest.',
        'Mix mashed banana with yogurt and chia seeds.',
        'Top with banana slices and a small drizzle of honey.',
      ],
    ),
    NutritionRecipe(
      id: 'chicken_rice',
      name: 'Grilled chicken rice bowl',
      slot: 'Lunch',
      artwork: '🍗',
      artworkAsset: 'assets/nutrition/meal.png',
      cuisine: 'Mediterranean',
      prepMinutes: 25,
      yieldServings: 2,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 560, protein: 46, carbs: 64, fat: 13),
      dietaryTags: ['Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Chicken breast',
            quantity: 300,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Basmati rice', quantity: 160, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Cucumber', quantity: 140, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Tomato', quantity: 140, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 16, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Season and grill chicken until fully cooked, then rest and slice.',
        'Cook rice according to package instructions.',
        'Divide rice, chicken, cucumber, and tomato into bowls.',
        'Finish with olive oil, lemon, and herbs.',
      ],
    ),
    NutritionRecipe(
      id: 'lentil_bowl',
      name: 'Lentil tahini power bowl',
      slot: 'Lunch',
      artwork: '🥗',
      cuisine: 'Middle Eastern',
      prepMinutes: 20,
      yieldServings: 2,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 510, protein: 24, carbs: 66, fat: 18),
      dietaryTags: ['Vegetarian', 'Vegan', 'Gluten-free'],
      allergens: ['Sesame'],
      ingredients: [
        NutritionIngredient(
            name: 'Cooked lentils',
            quantity: 320,
            unit: 'g',
            category: 'Pantry'),
        NutritionIngredient(
            name: 'Quinoa', quantity: 120, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Spinach', quantity: 120, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Tahini', quantity: 32, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Carrot', quantity: 140, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Cook quinoa and allow it to cool slightly.',
        'Warm lentils and prepare the vegetables.',
        'Assemble bowls and drizzle with lemon-tahini dressing.',
      ],
    ),
    NutritionRecipe(
      id: 'tuna_wrap',
      name: 'Tuna crunch wrap',
      slot: 'Lunch',
      artwork: '🌯',
      cuisine: 'International',
      prepMinutes: 12,
      yieldServings: 1,
      servingLabel: '1 wrap',
      macros: NutritionMacros(calories: 495, protein: 39, carbs: 49, fat: 16),
      dietaryTags: ['Halal'],
      allergens: ['Fish', 'Gluten', 'Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Tuna', quantity: 120, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Whole-grain wrap',
            quantity: 1,
            unit: 'pcs',
            category: 'Bakery'),
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 35, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Lettuce', quantity: 50, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Cucumber', quantity: 60, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Mix tuna with yogurt and seasoning.',
        'Layer lettuce, cucumber, and tuna onto the wrap.',
        'Fold tightly and serve immediately.',
      ],
    ),
    NutritionRecipe(
      id: 'salmon_greens',
      name: 'Herb salmon & greens',
      slot: 'Dinner',
      artwork: '🐟',
      artworkAsset: 'assets/nutrition/salmon.png',
      cuisine: 'Mediterranean',
      prepMinutes: 28,
      yieldServings: 2,
      servingLabel: '1 plate',
      macros: NutritionMacros(calories: 585, protein: 43, carbs: 42, fat: 27),
      dietaryTags: ['Gluten-free'],
      allergens: ['Fish'],
      ingredients: [
        NutritionIngredient(
            name: 'Salmon fillet',
            quantity: 300,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Baby potatoes',
            quantity: 360,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Green beans', quantity: 240, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 18, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Roast potatoes until golden and tender.',
        'Season salmon with herbs and bake until cooked through.',
        'Steam green beans and plate with salmon and potatoes.',
      ],
    ),
    NutritionRecipe(
      id: 'beef_quinoa',
      name: 'Lean beef quinoa plate',
      slot: 'Dinner',
      artwork: '🥩',
      cuisine: 'International',
      prepMinutes: 30,
      yieldServings: 2,
      servingLabel: '1 plate',
      macros: NutritionMacros(calories: 610, protein: 48, carbs: 55, fat: 22),
      dietaryTags: ['Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Lean beef', quantity: 300, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Quinoa', quantity: 150, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Bell pepper', quantity: 180, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Broccoli', quantity: 220, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Cook quinoa according to package instructions.',
        'Sear seasoned beef and rest before slicing.',
        'Sauté vegetables until tender-crisp and serve together.',
      ],
    ),
    NutritionRecipe(
      id: 'tofu_stirfry',
      name: 'Ginger tofu stir-fry',
      slot: 'Dinner',
      artwork: '🍲',
      cuisine: 'Asian',
      prepMinutes: 24,
      yieldServings: 2,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 520, protein: 29, carbs: 62, fat: 19),
      dietaryTags: ['Vegetarian', 'Vegan'],
      allergens: ['Soy'],
      ingredients: [
        NutritionIngredient(
            name: 'Firm tofu', quantity: 320, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Jasmine rice', quantity: 150, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Broccoli', quantity: 220, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Bell pepper', quantity: 160, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Soy sauce', quantity: 24, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Press and cube tofu, then sear until golden.',
        'Cook rice and stir-fry the vegetables.',
        'Add tofu, ginger, and sauce; toss briefly and serve.',
      ],
    ),
    NutritionRecipe(
      id: 'yogurt_berries',
      name: 'Greek yogurt & berries',
      slot: 'Snack',
      artwork: '🫐',
      artworkAsset: 'assets/nutrition/yogurt.png',
      cuisine: 'International',
      prepMinutes: 3,
      yieldServings: 1,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 215, protein: 20, carbs: 27, fat: 4),
      dietaryTags: ['Vegetarian', 'Gluten-free'],
      allergens: ['Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 180, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Mixed berries',
            quantity: 100,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Honey', quantity: 8, unit: 'g', category: 'Pantry'),
      ],
      instructions: [
        'Add yogurt to a bowl, top with berries, and drizzle with honey.'
      ],
    ),
    NutritionRecipe(
      id: 'apple_peanut',
      name: 'Apple & peanut snack',
      slot: 'Snack',
      artwork: '🍎',
      cuisine: 'International',
      prepMinutes: 3,
      yieldServings: 1,
      servingLabel: '1 snack',
      macros: NutritionMacros(calories: 235, protein: 7, carbs: 31, fat: 11),
      dietaryTags: ['Vegetarian', 'Vegan', 'Gluten-free'],
      allergens: ['Peanuts'],
      ingredients: [
        NutritionIngredient(
            name: 'Apple', quantity: 1, unit: 'pcs', category: 'Produce'),
        NutritionIngredient(
            name: 'Peanut butter', quantity: 24, unit: 'g', category: 'Pantry'),
      ],
      instructions: ['Slice the apple and serve with measured peanut butter.'],
    ),
    NutritionRecipe(
      id: 'hummus_veg',
      name: 'Hummus veggie snack box',
      slot: 'Snack',
      artwork: '🥕',
      cuisine: 'Middle Eastern',
      prepMinutes: 5,
      yieldServings: 1,
      servingLabel: '1 box',
      macros: NutritionMacros(calories: 225, protein: 8, carbs: 28, fat: 10),
      dietaryTags: ['Vegetarian', 'Vegan', 'Gluten-free'],
      allergens: ['Sesame'],
      ingredients: [
        NutritionIngredient(
            name: 'Hummus', quantity: 65, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Carrot', quantity: 100, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Cucumber', quantity: 100, unit: 'g', category: 'Produce'),
      ],
      instructions: ['Cut vegetables into sticks and serve with hummus.'],
    ),
  ];

  static NutritionRecipe? byId(String id) {
    for (final recipe in recipes) {
      if (recipe.id == id) {
        return recipe;
      }
    }
    return null;
  }

  static List<NutritionRecipe> forSlot(String slot) =>
      recipes.where((recipe) => recipe.slot == slot).toList();
}
