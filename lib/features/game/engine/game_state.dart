import 'package:food_cards/data/models/food_card.dart';

enum BattleSide { player, opponent }

enum BattleStatus { inProgress, playerWon, opponentWon }

class BattleEvent {
  const BattleEvent({
    required this.attacker,
    required this.attackerCardId,
    required this.targetCardId,
    required this.damage,
    required this.remainingHealth,
    required this.knockedOut,
  });

  final BattleSide attacker;
  final String attackerCardId;
  final String targetCardId;
  final int damage;
  final int remainingHealth;
  final bool knockedOut;
}

class BattleState {
  BattleState({
    required List<FoodCard> playerDeck,
    required List<FoodCard> opponentDeck,
    required this.playerCardIndex,
    required this.opponentCardIndex,
    required this.playerHealth,
    required this.opponentHealth,
    required this.round,
    required this.status,
    required List<BattleEvent> events,
  }) : playerDeck = List<FoodCard>.unmodifiable(playerDeck),
       opponentDeck = List<FoodCard>.unmodifiable(opponentDeck),
       events = List<BattleEvent>.unmodifiable(events);

  final List<FoodCard> playerDeck;
  final List<FoodCard> opponentDeck;
  final int playerCardIndex;
  final int opponentCardIndex;
  final int playerHealth;
  final int opponentHealth;
  final int round;
  final BattleStatus status;
  final List<BattleEvent> events;

  bool get isComplete => status != BattleStatus.inProgress;

  FoodCard? get activePlayerCard =>
      playerCardIndex < playerDeck.length ? playerDeck[playerCardIndex] : null;

  FoodCard? get activeOpponentCard => opponentCardIndex < opponentDeck.length
      ? opponentDeck[opponentCardIndex]
      : null;
}
