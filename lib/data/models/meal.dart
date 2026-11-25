class MealCategory {
  const MealCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String description;

  factory MealCategory.fromJson(Map<String, dynamic> json) => MealCategory(
    id: _requiredString(json, 'idCategory'),
    name: _requiredString(json, 'strCategory'),
    imageUrl: _optionalString(json, 'strCategoryThumb'),
    description: _optionalString(json, 'strCategoryDescription'),
  );
}

class MealSummary {
  const MealSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String imageUrl;

  factory MealSummary.fromJson(Map<String, dynamic> json) => MealSummary(
    id: _requiredString(json, 'idMeal'),
    name: _requiredString(json, 'strMeal'),
    imageUrl: _optionalString(json, 'strMealThumb'),
  );
}

class MealIngredient {
  const MealIngredient({required this.name, required this.measure});

  final String name;
  final String measure;

  String get label => measure.isEmpty ? name : '$measure $name';
}

class MealDetail extends MealSummary {
  MealDetail({
    required super.id,
    required super.name,
    required super.imageUrl,
    required this.category,
    required this.area,
    required this.instructions,
    required List<MealIngredient> ingredients,
    required this.sourceUrl,
    required this.youtubeUrl,
  }) : ingredients = List<MealIngredient>.unmodifiable(ingredients);

  final String category;
  final String area;
  final String instructions;
  final List<MealIngredient> ingredients;
  final String sourceUrl;
  final String youtubeUrl;

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final ingredients = <MealIngredient>[];
    for (var index = 1; index <= 20; index++) {
      final name = _optionalString(json, 'strIngredient$index').trim();
      if (name.isEmpty) continue;
      ingredients.add(
        MealIngredient(
          name: name,
          measure: _optionalString(json, 'strMeasure$index').trim(),
        ),
      );
    }

    return MealDetail(
      id: _requiredString(json, 'idMeal'),
      name: _requiredString(json, 'strMeal'),
      imageUrl: _optionalString(json, 'strMealThumb'),
      category: _optionalString(json, 'strCategory'),
      area: _optionalString(json, 'strArea'),
      instructions: _optionalString(json, 'strInstructions'),
      ingredients: ingredients,
      sourceUrl: _optionalString(json, 'strSource'),
      youtubeUrl: _optionalString(json, 'strYoutube'),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Campo obbligatorio non valido: $key');
  }
  return value.trim();
}

String _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return '';
  if (value is! String) throw FormatException('Campo non valido: $key');
  return value;
}
