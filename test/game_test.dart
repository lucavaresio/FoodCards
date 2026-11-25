import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/local/storage_service.dart';
import 'package:food_cards/data/models/card_element.dart';
import 'package:food_cards/data/models/food_card.dart';
import 'package:food_cards/data/providers.dart';
import 'package:food_cards/data/repositories/game_stats_repository.dart';
import 'package:food_cards/data/session_providers.dart';
import 'package:food_cards/data/models/rarity.dart';
import 'package:food_cards/features/game/engine/game_state.dart';
import 'package:food_cards/features/game/game_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'le statistiche di vittorie e sconfitte persistono per profilo',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final repository = GameStatsRepository(
        StorageService(preferences, uid: 'stats-user'),
      );

      final empty = repository.load();
      expect(empty.matchesPlayed, 0);
      expect(empty.wins, 0);
      expect(empty.losses, 0);
      await repository.recordResult(won: true);
      await repository.recordResult(won: false);

      final reloaded = GameStatsRepository(
        StorageService(preferences, uid: 'stats-user'),
      ).load();
      expect(reloaded.matchesPlayed, 2);
      expect(reloaded.wins, 1);
      expect(reloaded.losses, 1);
      expect(reloaded.winRate, 0.5);
      final otherUserStats = GameStatsRepository(
        StorageService(preferences, uid: 'other-user'),
      ).load();
      expect(otherUserStats.matchesPlayed, 0);
    },
  );

  test(
    'il controller salva una sola volta l’esito di una partita completa',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          currentUidProvider.overrideWithValue('match-user'),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(gameControllerProvider.notifier)
          .startMatch(
            playerDeck: _deck('player', health: 5, attack: 10, speed: 5),
            opponentDeck: _deck('opponent', health: 1, attack: 0, speed: 1),
          );
      for (var index = 0; index < GameConstants.matchSize; index++) {
        await container.read(gameControllerProvider.notifier).playRound();
      }

      expect(
        container.read(gameControllerProvider)?.status,
        BattleStatus.playerWon,
      );
      final stats = await container.read(
        playerGameStatsProvider('match-user').future,
      );
      expect(stats.matchesPlayed, 1);
      expect(stats.wins, 1);
      expect(stats.losses, 0);
    },
  );

  test('senza sessione il risultato non viene salvato né consumato', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);
    controller.startMatch(
      playerDeck: _deck('player', health: 5, attack: 10, speed: 5),
      opponentDeck: _deck('opponent', health: 1, attack: 0, speed: 1),
    );
    for (var index = 0; index < GameConstants.matchSize - 1; index++) {
      await controller.playRound();
    }

    await expectLater(controller.playRound(), throwsStateError);
    expect(
      container.read(gameControllerProvider)?.round,
      GameConstants.matchSize - 1,
    );
  });
}

List<FoodCard> _deck(
  String prefix, {
  required int health,
  required int attack,
  required int speed,
}) => List.generate(
  GameConstants.matchSize,
  (index) => FoodCard(
    id: '$prefix-$index',
    name: '$prefix $index',
    rarity: Rarity.common,
    element: CardElement.terra,
    health: health,
    attack: attack,
    defense: 0,
    speed: speed,
    abilityName: '',
    description: '',
    cardSet: 'Test',
    image: '',
  ),
);
