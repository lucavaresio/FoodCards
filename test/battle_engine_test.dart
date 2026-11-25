import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/models/card_element.dart';
import 'package:food_cards/data/models/food_card.dart';
import 'package:food_cards/data/models/rarity.dart';
import 'package:food_cards/features/game/engine/battle_engine.dart';
import 'package:food_cards/features/game/engine/bot_player.dart';
import 'package:food_cards/features/game/engine/game_state.dart';

void main() {
  group('BattleEngine', () {
    test('risolve gli attacchi in ordine di velocità e applica la difesa', () {
      final playerDeck = _deck(
        'player',
        health: 8,
        attack: 5,
        defense: 1,
        speed: 5,
      );
      final opponentDeck = _deck(
        'opponent',
        health: 8,
        attack: 2,
        defense: 3,
        speed: 2,
      );
      final started = BattleEngine.startMatch(
        playerDeck: playerDeck,
        opponentDeck: opponentDeck,
      );

      final next = BattleEngine.playRound(started);

      expect(next.round, 1);
      expect(next.events, hasLength(2));
      expect(next.events.first.attacker, BattleSide.player);
      expect(next.events.first.damage, 2);
      expect(next.events.first.remainingHealth, 6);
      expect(next.events.last.attacker, BattleSide.opponent);
      expect(next.events.last.damage, 1);
      expect(next.playerHealth, 7);
      expect(next.opponentHealth, 6);
      expect(started.round, 0);
      expect(started.events, isEmpty);
    });

    test(
      'il knockout interrompe il contrattacco e attiva la carta successiva',
      () {
        final state = BattleEngine.startMatch(
          playerDeck: _deck('player', health: 5, attack: 6, speed: 3),
          opponentDeck: _deck('opponent', health: 4, attack: 1, speed: 1),
        );

        final next = BattleEngine.playRound(state);

        expect(next.events, hasLength(1));
        expect(next.events.single.knockedOut, isTrue);
        expect(next.opponentCardIndex, 1);
        expect(next.opponentHealth, 4);
        expect(next.playerHealth, 5);
      },
    );

    test(
      'il danno minimo è uno e la partita termina dopo l’ultimo knockout',
      () {
        var state = BattleEngine.startMatch(
          playerDeck: _deck('player', health: 5, attack: 1, speed: 5),
          opponentDeck: _deck(
            'opponent',
            health: 1,
            attack: 0,
            defense: 20,
            speed: 1,
          ),
        );

        state = BattleEngine.playRound(state);
        expect(state.events.first.damage, GameConstants.battleMinimumDamage);

        for (var index = 1; index < GameConstants.matchSize; index++) {
          state = BattleEngine.playRound(state);
        }

        expect(state.status, BattleStatus.playerWon);
        expect(state.isComplete, isTrue);
        expect(state.opponentCardIndex, GameConstants.matchSize);
        expect(state.round, GameConstants.matchSize);
        expect(() => BattleEngine.playRound(state), throwsStateError);
      },
    );

    test('richiede mazzi completi con carte dotate di vita positiva', () {
      expect(
        () => BattleEngine.startMatch(
          playerDeck: _deck('player')
              .take(GameConstants.matchSize - 1)
              .toList(),
          opponentDeck: _deck('opponent'),
        ),
        throwsArgumentError,
      );
      expect(
        () => BattleEngine.startMatch(
          playerDeck: _deck('player', health: 0),
          opponentDeck: _deck('opponent'),
        ),
        throwsArgumentError,
      );
    });
  });

  test('BotPlayer sceglie in modo stabile le carte con punteggio più alto', () {
    final catalog = List.generate(
      GameConstants.matchSize + 2,
      (index) => _card('card-$index', health: index + 1),
    );
    final deck = BotPlayer.chooseDeck(catalog.reversed);

    expect(deck, hasLength(GameConstants.matchSize));
    expect(deck.first.id, 'card-11');
    expect(deck.last.id, 'card-2');
    expect(
      () => BotPlayer.chooseDeck(catalog.take(GameConstants.matchSize - 1)),
      throwsStateError,
    );
  });
}

List<FoodCard> _deck(
  String prefix, {
  int health = 5,
  int attack = 1,
  int defense = 0,
  int speed = 0,
}) => List.generate(
  GameConstants.matchSize,
  (index) => _card(
    '$prefix-$index',
    health: health,
    attack: attack,
    defense: defense,
    speed: speed,
  ),
);

FoodCard _card(
  String id, {
  int health = 5,
  int attack = 1,
  int defense = 0,
  int speed = 0,
}) => FoodCard(
  id: id,
  name: id,
  rarity: Rarity.common,
  element: CardElement.terra,
  health: health,
  attack: attack,
  defense: defense,
  speed: speed,
  abilityName: '',
  description: '',
  cardSet: 'Test',
  image: '',
);
