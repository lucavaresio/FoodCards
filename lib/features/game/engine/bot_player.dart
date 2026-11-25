import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/models/food_card.dart';

class BotPlayer {
  BotPlayer._();

  static List<FoodCard> chooseDeck(Iterable<FoodCard> collection) {
    final uniqueCards = <String, FoodCard>{};
    for (final card in collection) {
      uniqueCards.putIfAbsent(card.id, () => card);
    }

    if (uniqueCards.length < GameConstants.matchSize) {
      throw StateError(
        'Il bot richiede almeno ${GameConstants.matchSize} carte diverse',
      );
    }

    final rankedCards = uniqueCards.values.toList()
      ..sort((left, right) {
        final score = _strength(right).compareTo(_strength(left));
        return score != 0 ? score : left.id.compareTo(right.id);
      });

    return List<FoodCard>.unmodifiable(
      rankedCards.take(GameConstants.matchSize),
    );
  }

  static int _strength(FoodCard card) =>
      card.health + card.attack + card.defense + card.speed;
}
