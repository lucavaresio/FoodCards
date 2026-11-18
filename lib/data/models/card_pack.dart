import 'package:food_cards/data/models/rarity.dart';

class CardPack {
  const CardPack({
    required this.id,
    required this.name,
    required this.level,
    required this.cardCount,
    required this.cost,
    required this.dropRates,
    required this.image,
  });

  final String id;
  final String name;
  final String level;
  final int cardCount;
  final int cost;
  final Map<Rarity, double> dropRates;
  final String image;

  String get imageAsset => 'assets/images/packets/$image';

  Rarity get highestLikelyRarity {
    Rarity highest = Rarity.common;
    for (final entry in dropRates.entries) {
      if (entry.value >= 10 && entry.key.order >= highest.order) {
        highest = entry.key;
      }
    }
    return highest;
  }
}
