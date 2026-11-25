import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_cards/data/models/food_card.dart';
import 'package:food_cards/data/providers.dart';
import 'package:food_cards/data/session_providers.dart';

import 'engine/battle_engine.dart';
import 'engine/game_state.dart';

final gameControllerProvider = NotifierProvider<GameController, BattleState?>(
  GameController.new,
);

class GameController extends Notifier<BattleState?> {
  @override
  BattleState? build() => null;

  void startMatch({
    required List<FoodCard> playerDeck,
    required List<FoodCard> opponentDeck,
  }) {
    state = BattleEngine.startMatch(
      playerDeck: playerDeck,
      opponentDeck: opponentDeck,
    );
  }

  Future<void> playRound() async {
    final current = state;
    if (current == null) throw StateError('Nessuna partita attiva');

    final next = BattleEngine.playRound(current);
    if (next.isComplete) {
      final uid = ref.read(currentUidProvider);
      if (uid == null) throw StateError('La sessione non è attiva');
      await ref
          .read(gameStatsRepositoryProvider(uid))
          .recordResult(won: next.status == BattleStatus.playerWon);
      if (!ref.mounted) return;
      ref.invalidate(playerGameStatsProvider(uid));
    }

    if (ref.mounted) state = next;
  }

  void abandonMatch() => state = null;
}
