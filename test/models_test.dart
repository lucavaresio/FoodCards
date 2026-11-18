import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/constants/auth_constants.dart';
import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/models/app_user.dart';
import 'package:food_cards/data/models/card_element.dart';
import 'package:food_cards/data/models/deck.dart';
import 'package:food_cards/data/models/food_card.dart';
import 'package:food_cards/data/models/rarity.dart';

void main() {
  group('FoodCard', () {
    const card = FoodCard(
      id: 'pizza',
      name: 'Pizza Margherita',
      rarity: Rarity.rare,
      element: CardElement.fuoco,
      health: 80,
      attack: 65,
      defense: 50,
      speed: 45,
      abilityName: 'Forno bollente',
      description: 'Una pizza dal cuore focoso.',
      cardSet: 'Piccante',
      image: 'pizza_margherita.png',
    );

    test('JSON round-trip', () {
      expect(FoodCard.fromJson(card.toJson()), card);
    });

    test('chiave mancante', () {
      final json = card.toJson()..remove('abilityName');
      expect(() => FoodCard.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('imageAsset', () {
      expect(card.imageAsset, 'assets/images/cards/pizza_margherita.png');
    });
  });

  test('Rarity.fromName', () {
    expect(Rarity.fromName('epic'), Rarity.epic);
    expect(() => Rarity.fromName('unknown'), throwsArgumentError);
  });

  test('CardElement.fromName', () {
    expect(CardElement.fromName('acqua'), CardElement.acqua);
    expect(() => CardElement.fromName('unknown'), throwsArgumentError);
  });

  test('GameConstants.packs', () {
    expect(GameConstants.packs.length, 5);

    final ids = GameConstants.packs.map((pack) => pack.id).toSet();
    expect(ids.length, 5);

    for (final pack in GameConstants.packs) {
      expect(pack.dropRates.keys.length, Rarity.values.length);
      expect(pack.dropRates.keys.toSet(), Rarity.values.toSet());

      final sum = pack.dropRates.values.fold<double>(0, (value, rate) => value + rate);
      expect((sum - 100).abs() <= 0.001, isTrue);
    }

    final costs = GameConstants.packs.map((pack) => pack.cost).toList();
    for (var i = 1; i < costs.length; i++) {
      expect(costs[i] > costs[i - 1], isTrue);
    }

    for (final pack in GameConstants.packs) {
      final file = File('assets/images/packets/${pack.image}');
      expect(file.existsSync(), isTrue, reason: 'Manca ${pack.image}');
    }
  });

  group('Deck', () {
    test('0 carte', () {
      final deck = Deck(id: 'd', name: 'Inizio', cardIds: []);
      expect(deck.isComplete, isFalse);
      expect(deck.missingCards, 10);
    });

    test('9 carte', () {
      final deck = Deck(id: 'd', name: 'Quasi', cardIds: List.generate(9, (i) => '$i'));
      expect(deck.isComplete, isFalse);
      expect(deck.missingCards, 1);
    });

    test('10 carte', () {
      final deck = Deck(id: 'd', name: 'Completo', cardIds: List.generate(10, (i) => '$i'));
      expect(deck.isComplete, isTrue);
      expect(deck.missingCards, 0);
    });
  });

  group('AppUser', () {
    final user = AppUser(
      uid: 'uid-123',
      email: 'mario.rossi@example.com',
      displayName: 'Mario',
      createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
    );

    test('JSON round-trip', () {
      final restored = AppUser.fromJson(user.toJson());
      expect(restored, user);
      expect(restored.createdAt, user.createdAt);
    });

    test('chiave mancante', () {
      final json = user.toJson()..remove('createdAt');
      expect(() => AppUser.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('uguaglianza basata su uid', () {
      final other = AppUser(
        uid: 'uid-123',
        email: 'altro@example.com',
        displayName: 'Altro',
        createdAt: DateTime.utc(1970, 1, 1),
      );
      expect(other, user);
    });
  });

  test('AuthConstants', () {
    expect(AuthConstants.minPasswordLength <= AuthConstants.maxPasswordLength, isTrue);
    expect(AuthConstants.minDisplayNameLength <= AuthConstants.maxDisplayNameLength, isTrue);

    final emailRegex = RegExp(AuthConstants.emailPattern);
    expect(emailRegex.hasMatch('mario.rossi@example.com'), isTrue);
    expect(emailRegex.hasMatch('mario@'), isFalse);
    expect(emailRegex.hasMatch('@example.com'), isFalse);
    expect(emailRegex.hasMatch('mario rossi@example.com'), isFalse);
  });
}
