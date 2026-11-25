import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/data/remote/meal_db_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const meal = <String, Object>{
    'idMeal': '52772',
    'strMeal': 'Teriyaki Chicken',
    'strMealThumb': '',
    'strCategory': 'Chicken',
    'strArea': 'Japanese',
    'strInstructions': 'Cook the chicken and serve.',
    'strIngredient1': 'Chicken',
    'strMeasure1': '2 cups',
    'strIngredient2': ' ',
    'strMeasure2': '1',
    'strIngredient20': 'Soy sauce',
    'strMeasure20': '1 tbsp',
    'strSource': '',
    'strYoutube': '',
  };

  test('chiama categorie, filtro, dettagli e ricetta casuale', () async {
    final requests = <Uri>[];
    final client = MealDbClient(
      baseUri: Uri.parse('https://api.example.test/v1/1/'),
      client: MockClient((request) async {
        requests.add(request.url);
        return switch (request.url.pathSegments.last) {
          'categories.php' => _jsonResponse({
            'categories': [
              {
                'idCategory': '1',
                'strCategory': 'Chicken',
                'strCategoryThumb': '',
                'strCategoryDescription': 'Poultry dishes',
              },
            ],
          }),
          'filter.php' => _jsonResponse({
            'meals': [
              {
                'idMeal': '52772',
                'strMeal': 'Teriyaki Chicken',
                'strMealThumb': '',
              },
            ],
          }),
          'lookup.php' || 'random.php' => _jsonResponse({
            'meals': [meal],
          }),
          _ => http.Response('{}', 404),
        };
      }),
    );
    addTearDown(client.close);

    final categories = await client.fetchCategories();
    final meals = await client.fetchMealsByCategory('Chicken Curry');
    final detail = await client.fetchMealDetails('52772');
    final randomMeal = await client.fetchRandomMeal();

    expect(categories.single.name, 'Chicken');
    expect(meals.single.id, '52772');
    expect(detail?.ingredients.map((item) => item.label), [
      '2 cups Chicken',
      '1 tbsp Soy sauce',
    ]);
    expect(detail?.area, 'Japanese');
    expect(randomMeal?.id, '52772');
    expect(requests[1].queryParameters, {'c': 'Chicken Curry'});
    expect(requests[2].queryParameters, {'i': '52772'});
    expect(requests[3].path, endsWith('/random.php'));
  });

  test('gestisce elenchi vuoti, risposte HTTP e JSON non validi', () async {
    final empty = MealDbClient(
      baseUri: Uri.parse('https://api.example.test/v1/1/'),
      client: MockClient((_) async => _jsonResponse({'meals': null})),
    );
    addTearDown(empty.close);
    expect(await empty.fetchMealsByCategory('Unknown'), isEmpty);
    expect(await empty.fetchMealDetails('unknown'), isNull);

    final unavailable = MealDbClient(
      baseUri: Uri.parse('https://api.example.test/v1/1/'),
      client: MockClient((_) async => http.Response('{}', 503)),
    );
    addTearDown(unavailable.close);
    await expectLater(
      unavailable.fetchCategories(),
      throwsA(isA<MealDbException>()),
    );

    final malformed = MealDbClient(
      baseUri: Uri.parse('https://api.example.test/v1/1/'),
      client: MockClient(
        (_) async => _jsonResponse({
          'categories': [{}],
        }),
      ),
    );
    addTearDown(malformed.close);
    await expectLater(
      malformed.fetchCategories(),
      throwsA(isA<FormatException>()),
    );
  });

  test('traduce timeout e error di rete in errori espliciti', () async {
    final timedOut = MealDbClient(
      baseUri: Uri.parse('https://api.example.test/v1/1/'),
      client: MockClient((_) async => throw TimeoutException('timeout')),
    );
    addTearDown(timedOut.close);
    await expectLater(
      timedOut.fetchCategories(),
      throwsA(isA<MealDbException>()),
    );

    final disconnected = MealDbClient(
      baseUri: Uri.parse('https://api.example.test/v1/1/'),
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    addTearDown(disconnected.close);
    await expectLater(
      disconnected.fetchCategories(),
      throwsA(isA<MealDbException>()),
    );
  });
}

http.Response _jsonResponse(Object body) =>
    http.Response(jsonEncode(body), 200);
