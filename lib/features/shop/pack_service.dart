import 'dart:math';

import '../../data/models/card_pack.dart';
import '../../data/models/food_card.dart';
import '../../data/models/rarity.dart';

class PackDrawResult {
  PackDrawResult({
    required this.pack,
    required List<FoodCard> cards,
    required Set<String> newCardIds,
  }) : cards = List.unmodifiable(cards),
       newCardIds = Set.unmodifiable(newCardIds);

  final CardPack pack;
  final List<FoodCard> cards;
  final Set<String> newCardIds;
}

class PackService {
  PackService(List<FoodCard> cards, {Random? random})
    : _cards = List.unmodifiable(cards),
      _random = random ?? Random() {
    _byRarity = {
      for (final rarity in Rarity.values)
        rarity: List.unmodifiable(
          _cards.where((card) => card.rarity == rarity),
        ),
    };
  }

  final List<FoodCard> _cards;
  final Random _random;
  late final Map<Rarity, List<FoodCard>> _byRarity;

  List<FoodCard> draw(CardPack pack) =>
      List.unmodifiable(List.generate(pack.cardCount, (_) => _drawOne(pack)));

  PackDrawResult drawResult(
    CardPack pack, {
    Map<String, int> owned = const {},
  }) {
    final cards = draw(pack);
    final newIds = <String>{};
    for (final card in cards) {
      if ((owned[card.id] ?? 0) == 0) newIds.add(card.id);
    }
    return PackDrawResult(pack: pack, cards: cards, newCardIds: newIds);
  }

  PackDrawResult openFree(CardPack pack, {Map<String, int> owned = const {}}) =>
      drawResult(pack, owned: owned);

  FoodCard _drawOne(CardPack pack) {
    if (_cards.isEmpty) throw StateError('Il catalogo delle carte è vuoto');
    final totalWeight = pack.dropRates.values.fold<double>(0, (total, weight) {
      if (weight < 0 || !weight.isFinite) {
        throw ArgumentError.value(weight, 'dropRates', 'Peso non valido');
      }
      return total + weight;
    });
    if (totalWeight <= 0) {
      throw ArgumentError.value(pack.dropRates, 'dropRates', 'Pesi non validi');
    }

    var roll = _random.nextDouble() * totalWeight;
    var selected = Rarity.common;
    for (final rarity in Rarity.values) {
      final weight = pack.dropRates[rarity] ?? 0;
      if (roll < weight) {
        selected = rarity;
        break;
      }
      roll -= weight;
    }

    final pool = _fallbackPool(selected);
    return pool[_random.nextInt(pool.length)];
  }

  List<FoodCard> _fallbackPool(Rarity rarity) {
    for (var index = rarity.index; index >= 0; index--) {
      final available = _byRarity[Rarity.values[index]]!;
      if (available.isNotEmpty) return available;
    }
    for (var index = rarity.index + 1; index < Rarity.values.length; index++) {
      final available = _byRarity[Rarity.values[index]]!;
      if (available.isNotEmpty) return available;
    }
    throw StateError('Il catalogo delle carte è vuoto');
  }
}
