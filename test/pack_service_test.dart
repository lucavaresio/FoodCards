import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/local/storage_service.dart';
import 'package:food_cards/data/models/card_pack.dart';
import 'package:food_cards/data/models/card_element.dart';
import 'package:food_cards/data/models/food_card.dart';
import 'package:food_cards/data/models/rarity.dart';
import 'package:food_cards/data/repositories/card_repository.dart';
import 'package:food_cards/data/repositories/collection_repository.dart';
import 'package:food_cards/features/shop/pack_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'drop rate di ogni pacchetto segue le probabilità entro 5 sigma',
    () async {
      final catalog = CardRepository();
      await catalog.load();
      for (final pack in GameConstants.packs) {
        final service = PackService(catalog.all, random: Random(42));
        final counts = {for (final rarity in Rarity.values) rarity: 0};
        const sampleCount = 10000;
        for (var index = 0; index < sampleCount; index++) {
          for (final card in service.draw(pack)) {
            counts.update(card.rarity, (count) => count + 1);
          }
        }
        final total = sampleCount * pack.cardCount;
        final rateTotal = pack.dropRates.values.reduce((a, b) => a + b);
        for (final rarity in Rarity.values) {
          final probability = (pack.dropRates[rarity] ?? 0) / rateTotal;
          final expected = total * probability;
          final deviation = sqrt(total * probability * (1 - probability));
          expect(
            (counts[rarity]! - expected).abs(),
            lessThanOrEqualTo(5 * deviation + 1),
            reason: '${pack.name}, ${rarity.label}',
          );
        }
      }
    },
  );

  test('fallback, stesso seed e nuove carte uniche', () {
    final card = _card('only-common', Rarity.common);
    final pack = CardPack(
      id: 'test',
      name: 'Test',
      level: 'Test',
      cardCount: 5,
      cost: 1,
      dropRates: const {Rarity.legendary: 100},
      image: '',
    );
    final first = PackService([card], random: Random(9));
    final second = PackService([card], random: Random(9));
    final result = first.drawResult(pack);
    expect(result.cards, second.draw(pack));
    expect(result.cards, hasLength(5));
    expect(result.newCardIds, {'only-common'});
    expect(first.openFree(pack, owned: {'only-common': 1}).newCardIds, isEmpty);
  });

  test('acquisto aggiunge le carte e monete insieme; fondi insufficienti invariati', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = CollectionRepository(
      StorageService(preferences, uid: 'pack-test'),
    );
    await repository.initializeForNewUser();
    final before = repository.coins;
    await repository.purchasePack(100, ['a', 'a', 'b']);
    expect(repository.coins, before - 100);
    expect(repository.owned, {'a': 2, 'b': 1});

    final snapshot = repository.owned;
    final balance = repository.coins;
    await expectLater(
      repository.purchasePack(balance + 1, ['c']),
      throwsA(isA<InsufficientCoins>()),
    );
    expect(repository.coins, balance);
    expect(repository.owned, snapshot);

    final reloaded = CollectionRepository(
      StorageService(preferences, uid: 'pack-test'),
    );
    await reloaded.load();
    expect(reloaded.coins, balance);
    expect(reloaded.owned, snapshot);
  });
}

FoodCard _card(String id, Rarity rarity) => FoodCard(
  id: id,
  name: id,
  rarity: rarity,
  element: CardElement.terra,
  health: 1,
  attack: 1,
  defense: 1,
  speed: 1,
  abilityName: '',
  description: '',
  cardSet: 'test',
  image: '',
);
