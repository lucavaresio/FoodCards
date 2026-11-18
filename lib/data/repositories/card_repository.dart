import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:food_cards/data/models/food_card.dart';
import 'package:food_cards/data/models/rarity.dart';

class CardRepository {
  CardRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<FoodCard> _cards = const [];

  List<FoodCard> get all => List<FoodCard>.unmodifiable(_cards);

  Future<void> load() async {
    final source = await _bundle.loadString('assets/cards.json');
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('cards.json deve contenere una lista');
    }

    final cards = <FoodCard>[];
    final ids = <String>{};
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Oggetto carta non valido');
      }
      final id = item['id'];
      final label = id is String ? id : '<sconosciuto>';
      try {
        final card = FoodCard.fromJson(item);
        if (ids.contains(card.id)) {
          throw FormatException('ID carta duplicato: ${card.id}');
        }
        ids.add(card.id);
        cards.add(card);
      } on FormatException {
        rethrow;
      } catch (_) {
        throw FormatException('Carta non valida: $label');
      }
    }
    _cards = cards;
  }

  FoodCard? byId(String id) {
    for (final card in _cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  FoodCard requireById(String id) {
    final card = byId(id);
    if (card == null) throw StateError('Carta inesistente: $id');
    return card;
  }

  List<FoodCard> byRarity(Rarity rarity) =>
      List<FoodCard>.unmodifiable(_cards.where((card) => card.rarity == rarity));

  List<FoodCard> bySet(String set) =>
      List<FoodCard>.unmodifiable(_cards.where((card) => card.cardSet == set));
}
