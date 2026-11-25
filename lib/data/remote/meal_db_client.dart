import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';

class MealDbClient {
  MealDbClient({
    http.Client? client,
    Uri? baseUri,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _baseUri =
           baseUri ?? Uri.parse('https://www.themealdb.com/api/json/v1/1/');

  final http.Client _client;
  final Uri _baseUri;
  final Duration timeout;

  Future<List<MealCategory>> fetchCategories() =>
      _fetchList('categories.php', 'categories', MealCategory.fromJson);

  Future<List<MealSummary>> fetchMealsByCategory(String category) => _fetchList(
    'filter.php',
    'meals',
    MealSummary.fromJson,
    query: {'c': category},
  );

  Future<MealDetail?> fetchMealDetails(String id) =>
      _fetchOne('lookup.php', query: {'i': id});

  Future<MealDetail?> fetchRandomMeal() => _fetchOne('random.php');

  void close() => _client.close();

  Future<List<T>> _fetchList<T>(
    String endpoint,
    String key,
    T Function(Map<String, dynamic>) parse, {
    Map<String, String> query = const {},
  }) async {
    final response = await _get(endpoint, query: query);
    final data = _decodeObject(response.body);
    if (!data.containsKey(key)) {
      throw FormatException('Campo mancante: $key');
    }
    final values = data[key];
    if (values == null) return const [];
    if (values is! List) {
      throw FormatException('Risposta non valida: $key');
    }
    return List<T>.unmodifiable(
      values.map((value) => parse(_decodeMap(value))),
    );
  }

  Future<MealDetail?> _fetchOne(
    String endpoint, {
    Map<String, String> query = const {},
  }) async {
    final response = await _get(endpoint, query: query);
    final data = _decodeObject(response.body);
    if (!data.containsKey('meals')) {
      throw const FormatException('Campo mancante: meals');
    }
    final values = data['meals'];
    if (values == null) return null;
    if (values is! List) {
      throw const FormatException('Lista ricette non valida');
    }
    if (values.isEmpty) return null;
    return MealDetail.fromJson(_decodeMap(values.first));
  }

  Future<http.Response> _get(
    String endpoint, {
    Map<String, String> query = const {},
  }) async {
    try {
      final response = await _client
          .get(_baseUri.resolve(endpoint).replace(queryParameters: query))
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw MealDbException(
          'Il servizio ricette ha risposto con HTTP ${response.statusCode}',
        );
      }
      return response;
    } on TimeoutException {
      throw const MealDbException('La richiesta è scaduta');
    } on http.ClientException {
      throw const MealDbException('Connessione non disponibile');
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    final value = jsonDecode(body);
    if (value is! Map) throw const FormatException('Risposta JSON non valida');
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  Map<String, dynamic> _decodeMap(Object? value) {
    if (value is! Map) throw const FormatException('Ricetta non valida');
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}

class MealDbException implements Exception {
  const MealDbException(this.message);

  final String message;

  @override
  String toString() => message;
}
