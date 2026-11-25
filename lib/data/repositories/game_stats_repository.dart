import 'package:food_cards/data/local/storage_service.dart';
import 'package:food_cards/data/models/player_game_stats.dart';

class GameStatsRepository {
  GameStatsRepository(this._storage);

  final StorageService _storage;

  PlayerGameStats load() {
    final json = _storage.readJson('game_stats');
    return json == null
        ? const PlayerGameStats.empty()
        : PlayerGameStats.fromJson(json);
  }

  Future<PlayerGameStats> recordResult({required bool won}) async {
    final updated = load().recordResult(won: won);
    await _storage.writeJson('game_stats', updated.toJson());
    return updated;
  }
}
