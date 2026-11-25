import 'dart:math' as math;

import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/models/food_card.dart';

import 'game_state.dart';

class BattleEngine {
  BattleEngine._();

  static BattleState startMatch({
    required List<FoodCard> playerDeck,
    required List<FoodCard> opponentDeck,
  }) {
    _validateDeck(playerDeck, 'playerDeck');
    _validateDeck(opponentDeck, 'opponentDeck');

    return BattleState(
      playerDeck: playerDeck,
      opponentDeck: opponentDeck,
      playerCardIndex: 0,
      opponentCardIndex: 0,
      playerHealth: playerDeck.first.health,
      opponentHealth: opponentDeck.first.health,
      round: 0,
      status: BattleStatus.inProgress,
      events: const [],
    );
  }

  static BattleState playRound(BattleState state) {
    if (state.isComplete) {
      throw StateError('La partita è già terminata');
    }

    var playerIndex = state.playerCardIndex;
    var opponentIndex = state.opponentCardIndex;
    var playerHealth = state.playerHealth;
    var opponentHealth = state.opponentHealth;
    final events = List<BattleEvent>.of(state.events);

    bool attack(BattleSide side) {
      final isPlayer = side == BattleSide.player;
      final attacker = isPlayer
          ? state.playerDeck[playerIndex]
          : state.opponentDeck[opponentIndex];
      final target = isPlayer
          ? state.opponentDeck[opponentIndex]
          : state.playerDeck[playerIndex];
      final targetHealth = isPlayer ? opponentHealth : playerHealth;
      final damage = math.max(
        GameConstants.battleMinimumDamage,
        attacker.attack - target.defense,
      );
      final remainingHealth = math.max(0, targetHealth - damage);
      final knockedOut = remainingHealth == 0;

      events.add(
        BattleEvent(
          attacker: side,
          attackerCardId: attacker.id,
          targetCardId: target.id,
          damage: damage,
          remainingHealth: remainingHealth,
          knockedOut: knockedOut,
        ),
      );

      if (isPlayer) {
        opponentHealth = remainingHealth;
        if (knockedOut) {
          opponentIndex++;
          opponentHealth = opponentIndex < state.opponentDeck.length
              ? state.opponentDeck[opponentIndex].health
              : 0;
        }
      } else {
        playerHealth = remainingHealth;
        if (knockedOut) {
          playerIndex++;
          playerHealth = playerIndex < state.playerDeck.length
              ? state.playerDeck[playerIndex].health
              : 0;
        }
      }

      return knockedOut;
    }

    final playerCard = state.playerDeck[playerIndex];
    final opponentCard = state.opponentDeck[opponentIndex];
    final firstAttacker = playerCard.speed >= opponentCard.speed
        ? BattleSide.player
        : BattleSide.opponent;
    final firstAttackKnockedOut = attack(firstAttacker);
    if (!firstAttackKnockedOut) {
      attack(
        firstAttacker == BattleSide.player
            ? BattleSide.opponent
            : BattleSide.player,
      );
    }

    final status = playerIndex == state.playerDeck.length
        ? BattleStatus.opponentWon
        : opponentIndex == state.opponentDeck.length
        ? BattleStatus.playerWon
        : BattleStatus.inProgress;

    return BattleState(
      playerDeck: state.playerDeck,
      opponentDeck: state.opponentDeck,
      playerCardIndex: playerIndex,
      opponentCardIndex: opponentIndex,
      playerHealth: playerHealth,
      opponentHealth: opponentHealth,
      round: state.round + 1,
      status: status,
      events: events,
    );
  }

  static void _validateDeck(List<FoodCard> deck, String name) {
    if (deck.length != GameConstants.matchSize) {
      throw ArgumentError.value(
        deck.length,
        name,
        'Il mazzo deve contenere ${GameConstants.matchSize} carte',
      );
    }
    if (deck.any((card) => card.health <= 0)) {
      throw ArgumentError.value(
        deck,
        name,
        'Le carte devono avere vita positiva',
      );
    }
  }
}
