class NutritionMacros {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  const NutritionMacros.zero()
      : calories = 0,
        protein = 0,
        carbs = 0,
        fat = 0;

  NutritionMacros operator +(NutritionMacros other) => NutritionMacros(
        calories: calories + other.calories,
        protein: protein + other.protein,
        carbs: carbs + other.carbs,
        fat: fat + other.fat,
      );

  NutritionMacros scale(double factor) => NutritionMacros(
        calories: calories * factor,
        protein: protein * factor,
        carbs: carbs * factor,
        fat: fat * factor,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory NutritionMacros.fromJson(dynamic value) {
    if (value is! Map) {
      return const NutritionMacros.zero();
    }
    return NutritionMacros(
      calories: (value['calories'] as num?)?.toDouble() ?? 0,
      protein: (value['protein'] as num?)?.toDouble() ?? 0,
      carbs: (value['carbs'] as num?)?.toDouble() ?? 0,
      fat: (value['fat'] as num?)?.toDouble() ?? 0,
    );
  }
}

class NutritionIngredient {
  final String name;
  final double quantity;
  final String unit;
  final String category;

  const NutritionIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'category': category,
      };

  factory NutritionIngredient.fromJson(dynamic value) {
    final map = value is Map ? value : const <String, dynamic>{};
    return NutritionIngredient(
      name: map['name']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Other',
    );
  }
}

class NutritionRecipe {
  final String id;
  final String name;
  final String slot;
  final String artwork;
  final String? artworkAsset;
  final String? imageUrl;
  final String cuisine;
  final int prepMinutes;
  final int yieldServings;
  final String servingLabel;
  final NutritionMacros macros;
  final List<String> dietaryTags;
  final List<String> allergens;
  final List<NutritionIngredient> ingredients;
  final List<String> instructions;
  final String nutritionProvenance;
  final String reviewStatus;

  const NutritionRecipe({
    required this.id,
    required this.name,
    required this.slot,
    required this.artwork,
    this.artworkAsset,
    this.imageUrl,
    required this.cuisine,
    required this.prepMinutes,
    required this.yieldServings,
    required this.servingLabel,
    required this.macros,
    required this.dietaryTags,
    required this.allergens,
    required this.ingredients,
    required this.instructions,
    this.nutritionProvenance = 'Estimated sample nutrition',
    this.reviewStatus = 'unreviewed',
  });

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'slot': slot,
        'artwork': artwork,
        'image_url': imageUrl,
        'cuisine': cuisine,
        'prep_minutes': prepMinutes,
        'yield_servings': yieldServings,
        'serving_label': servingLabel,
        'nutrition': macros.toJson(),
        'dietary_tags': dietaryTags,
        'allergens': allergens,
        'ingredients': ingredients.map((item) => item.toJson()).toList(),
        'instructions': instructions,
        'nutrition_provenance': nutritionProvenance,
        'review_status': reviewStatus,
      };

  factory NutritionRecipe.fromApi(Map<String, dynamic> map) {
    List<String> strings(dynamic value) => value is List
        ? value
            .map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .toList()
        : <String>[];

    final nutrition = map['nutrition'] is Map
        ? NutritionMacros.fromJson(map['nutrition'])
        : NutritionMacros(
            calories: (map['calories'] as num?)?.toDouble() ?? 0,
            protein: (map['protein'] as num?)?.toDouble() ?? 0,
            carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
            fat: (map['fat'] as num?)?.toDouble() ?? 0,
          );
    final ingredientList = map['ingredients'];

    return NutritionRecipe(
      id: map['id']?.toString() ?? map['source_id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Recipe',
      slot: map['slot']?.toString() ?? 'Snack',
      artwork: map['artwork']?.toString() ?? '🍽️',
      imageUrl: map['image_url']?.toString(),
      cuisine: map['cuisine']?.toString() ?? 'International',
      prepMinutes: (map['prep_minutes'] as num?)?.toInt() ?? 0,
      yieldServings: (map['yield_servings'] as num?)?.toInt() ?? 1,
      servingLabel: map['serving_label']?.toString() ?? '1 serving',
      macros: nutrition,
      dietaryTags: strings(map['dietary_tags']),
      allergens: strings(map['allergens']),
      ingredients: ingredientList is List
          ? ingredientList.map(NutritionIngredient.fromJson).toList()
          : const <NutritionIngredient>[],
      instructions: strings(map['instructions']),
      nutritionProvenance: map['nutrition_provenance']?.toString() ??
          'Estimated nutrition supplied by content manager',
      reviewStatus: map['review_status']?.toString() ?? 'unreviewed',
    );
  }
}

class PlannedNutritionMeal {
  final String slot;
  final String recipeId;
  final String time;
  final double servings;

  const PlannedNutritionMeal({
    required this.slot,
    required this.recipeId,
    required this.time,
    this.servings = 1,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'slot': slot,
        'recipeId': recipeId,
        'time': time,
        'servings': servings,
      };

  factory PlannedNutritionMeal.fromJson(dynamic value) {
    final map = value is Map ? value : const <String, dynamic>{};
    return PlannedNutritionMeal(
      slot: map['slot']?.toString() ?? 'Snack',
      recipeId: map['recipeId']?.toString() ?? '',
      time: map['time']?.toString() ?? '',
      servings: (map['servings'] as num?)?.toDouble() ?? 1,
    );
  }
}

class NutritionPreferences {
  final String goal;
  final List<String> dietary;
  final List<String> allergies;
  final List<String> cuisines;
  final String budget;
  final int prepMinutes;
  final String units;
  final double calorieTarget;
  final double proteinTarget;
  final double carbsTarget;
  final double fatTarget;
  final int waterTargetMl;

  const NutritionPreferences({
    required this.goal,
    required this.dietary,
    required this.allergies,
    required this.cuisines,
    required this.budget,
    required this.prepMinutes,
    required this.units,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.waterTargetMl,
  });

  NutritionMacros get targetMacros => NutritionMacros(
        calories: calorieTarget,
        protein: proteinTarget,
        carbs: carbsTarget,
        fat: fatTarget,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'goal': goal,
        'dietary': dietary,
        'allergies': allergies,
        'cuisines': cuisines,
        'budget': budget,
        'prepMinutes': prepMinutes,
        'units': units,
        'calorieTarget': calorieTarget,
        'proteinTarget': proteinTarget,
        'carbsTarget': carbsTarget,
        'fatTarget': fatTarget,
        'waterTargetMl': waterTargetMl,
      };

  factory NutritionPreferences.fromJson(dynamic value) {
    final map = value is Map ? value : const <String, dynamic>{};
    List<String> strings(String key) {
      final raw = map[key];
      return raw is List
          ? raw.map((item) => item.toString()).toList()
          : <String>[];
    }

    return NutritionPreferences(
      goal: map['goal']?.toString() ?? 'Balanced eating',
      dietary: strings('dietary'),
      allergies: strings('allergies'),
      cuisines: strings('cuisines'),
      budget: map['budget']?.toString() ?? 'Moderate',
      prepMinutes: (map['prepMinutes'] as num?)?.toInt() ?? 30,
      units: map['units']?.toString() ?? 'Metric',
      calorieTarget: (map['calorieTarget'] as num?)?.toDouble() ?? 2100,
      proteinTarget: (map['proteinTarget'] as num?)?.toDouble() ?? 140,
      carbsTarget: (map['carbsTarget'] as num?)?.toDouble() ?? 240,
      fatTarget: (map['fatTarget'] as num?)?.toDouble() ?? 65,
      waterTargetMl: (map['waterTargetMl'] as num?)?.toInt() ?? 2500,
    );
  }
}
