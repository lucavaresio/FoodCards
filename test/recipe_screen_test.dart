import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/data/remote/meal_db_client.dart';
import 'package:food_cards/features/recipes/recipe_providers.dart';
import 'package:food_cards/features/recipes/recipe_screen.dart';
import 'package:food_cards/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sfoglia categorie, ricette e ingredienti', (tester) async {
    final client = _client((request) async {
      return switch (request.url.pathSegments.last) {
        'categories.php' => _jsonResponse({
          'categories': [
            {
              'idCategory': '1',
              'strCategory': 'Breakfast',
              'strCategoryThumb': '',
              'strCategoryDescription': '',
            },
          ],
        }),
        'filter.php' => _jsonResponse({
          'meals': [
            {'idMeal': '123', 'strMeal': 'Avo Toast', 'strMealThumb': ''},
          ],
        }),
        'lookup.php' => _jsonResponse({
          'meals': [
            {
              'idMeal': '123',
              'strMeal': 'Avo Toast',
              'strMealThumb': '',
              'strCategory': 'Breakfast',
              'strArea': 'British',
              'strInstructions': 'Toast the bread.',
              'strIngredient1': 'Bread',
              'strMeasure1': '2 slices',
            },
          ],
        }),
        _ => http.Response('{}', 404),
      };
    });
    addTearDown(client.close);
    await _pumpRecipeScreen(tester, client);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avo Toast'));
    await tester.pumpAndSettle();

    expect(find.text('Ingredienti'), findsOneWidget);
    expect(find.text('• 2 slices Bread'), findsOneWidget);
    expect(find.text('Toast the bread.'), findsOneWidget);
  });

  testWidgets('la ricetta casuale usa l’endpoint dedicato', (tester) async {
    var randomRequests = 0;
    final client = _client((request) async {
      if (request.url.pathSegments.last == 'categories.php') {
        return _jsonResponse({
          'categories': [
            {
              'idCategory': '1',
              'strCategory': 'Dessert',
              'strCategoryThumb': '',
              'strCategoryDescription': '',
            },
          ],
        });
      }
      if (request.url.pathSegments.last == 'random.php') {
        randomRequests++;
        return _jsonResponse({
          'meals': [
            {
              'idMeal': '456',
              'strMeal': 'Lemon Tart',
              'strMealThumb': '',
              'strCategory': 'Dessert',
              'strArea': 'French',
              'strInstructions': 'Bake the tart.',
              'strIngredient1': 'Lemon',
              'strMeasure1': '1',
            },
          ],
        });
      }
      return http.Response('{}', 404);
    });
    addTearDown(client.close);
    await _pumpRecipeScreen(tester, client);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scegli una ricetta casuale'));
    await tester.pumpAndSettle();
    expect(find.text('Lemon Tart'), findsOneWidget);
    expect(randomRequests, 1);
  });

  testWidgets('mostra l’errore di rete e consente di riprovare', (
    tester,
  ) async {
    var categoryRequests = 0;
    final client = _client((request) async {
      categoryRequests++;
      if (categoryRequests == 1) return http.Response('{}', 503);
      return _jsonResponse({
        'categories': [
          {
            'idCategory': '1',
            'strCategory': 'Seafood',
            'strCategoryThumb': '',
            'strCategoryDescription': '',
          },
        ],
      });
    });
    addTearDown(client.close);
    await _pumpRecipeScreen(tester, client);
    await tester.pumpAndSettle();

    expect(
      find.text('Ricette non disponibili'),
      findsOneWidget,
      reason:
          'richieste: $categoryRequests; testi visibili: '
          '${tester.widgetList<Text>(find.byType(Text)).map((item) => item.data).join(', ')}',
    );
    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();
    expect(find.text('Seafood'), findsOneWidget);
    expect(categoryRequests, 2);
  });
}

MealDbClient _client(Future<http.Response> Function(http.Request) handler) =>
    MealDbClient(
      baseUri: Uri.parse('https://api.example.test/v1/1/'),
      client: MockClient(handler),
    );

http.Response _jsonResponse(Object body) =>
    http.Response(jsonEncode(body), 200);

Future<void> _pumpRecipeScreen(WidgetTester tester, MealDbClient client) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [mealDbClientProvider.overrideWithValue(client)],
      child: MaterialApp(theme: lightTheme(), home: const RecipeScreen()),
    ),
  );
  await tester.pump();
}
