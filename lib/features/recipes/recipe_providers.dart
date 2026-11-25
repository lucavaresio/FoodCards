import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/meal.dart';
import '../../data/remote/meal_db_client.dart';

final mealDbClientProvider = Provider<MealDbClient>((ref) {
  final client = MealDbClient();
  ref.onDispose(client.close);
  return client;
});

final mealCategoriesProvider = FutureProvider<List<MealCategory>>((ref) {
  return ref.watch(mealDbClientProvider).fetchCategories();
});

final categoryMealsProvider = FutureProvider.family<List<MealSummary>, String>((
  ref,
  category,
) {
  return ref.watch(mealDbClientProvider).fetchMealsByCategory(category);
});

final mealDetailsProvider = FutureProvider.family<MealDetail?, String>((
  ref,
  id,
) {
  return ref.watch(mealDbClientProvider).fetchMealDetails(id);
});

final randomMealProvider = FutureProvider<MealDetail?>((ref) {
  return ref.watch(mealDbClientProvider).fetchRandomMeal();
});
