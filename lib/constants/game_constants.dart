import 'package:food_cards/data/models/card_pack.dart';
import 'package:food_cards/data/models/rarity.dart';

class GameConstants {
  GameConstants._();

  static const int deckSize = 10;
  static const int startingHandSize = 3;
  static const int matchSize = 10;
  static const int battleMinimumDamage = 1;
  // TODO: bilanciare
  static const int startingCoins = 500;
  static const int maxDeckNameLength = 20;
  // TODO: bilanciare
  static const int maxDecks = 10;
  static const int dailyFreeCardCount = 3;

  static const List<CardPack> packs = <CardPack>[
    CardPack(
      id: 'snack',
      name: 'Snack Pack',
      level: 'Base',
      cardCount: 5,
      cost: 100,
      dropRates: <Rarity, double>{
        Rarity.common: 60,
        Rarity.uncommon: 25,
        Rarity.rare: 12,
        Rarity.epic: 2.5,
        Rarity.legendary: 0.5,
      },
      image: 'snack_pack.png',
    ),
    CardPack(
      id: 'tasty',
      name: 'Tasty Pack',
      level: 'Intermedio',
      cardCount: 5,
      cost: 250,
      dropRates: <Rarity, double>{
        Rarity.common: 48,
        Rarity.uncommon: 30,
        Rarity.rare: 16,
        Rarity.epic: 5,
        Rarity.legendary: 1,
      },
      image: 'tasty_pack.png',
    ),
    CardPack(
      id: 'gourmet',
      name: 'Gourmet Pack',
      level: 'Avanzato',
      cardCount: 6,
      cost: 450,
      dropRates: <Rarity, double>{
        Rarity.common: 35,
        Rarity.uncommon: 30,
        Rarity.rare: 22,
        Rarity.epic: 10,
        Rarity.legendary: 3,
      },
      image: 'gourmet_pack.png',
    ),
    CardPack(
      id: 'chefs',
      name: "Chef's Selection",
      level: 'Premium',
      cardCount: 7,
      cost: 750,
      dropRates: <Rarity, double>{
        Rarity.common: 25,
        Rarity.uncommon: 28,
        Rarity.rare: 27,
        Rarity.epic: 15,
        Rarity.legendary: 5,
      },
      image: 'chefs_selection.png',
    ),
    CardPack(
      id: 'legendary',
      name: 'Legendary Feast',
      level: 'Leggendario',
      cardCount: 8,
      cost: 1200,
      dropRates: <Rarity, double>{
        Rarity.common: 15,
        Rarity.uncommon: 25,
        Rarity.rare: 30,
        Rarity.epic: 20,
        Rarity.legendary: 10,
      },
      image: 'legendary_feast.png',
    ),
  ];

  static const CardPack dailyFreePack = CardPack(
    id: 'daily-free',
    name: 'Regalo giornaliero',
    level: 'Gratis',
    cardCount: dailyFreeCardCount,
    cost: 0,
    dropRates: <Rarity, double>{
      Rarity.common: 60,
      Rarity.uncommon: 25,
      Rarity.rare: 12,
      Rarity.epic: 2.5,
      Rarity.legendary: 0.5,
    },
    image: 'snack_pack.png',
  );

  static CardPack packById(String id) {
    for (final pack in packs) {
      if (pack.id == id) return pack;
    }
    throw ArgumentError('Pacchetto sconosciuto: $id');
  }
}
