import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/local/storage_service.dart';

class CollectionRepository {
  CollectionRepository(this._storage);

  final StorageService _storage;
  int _coins = 0;
  Map<String, int> _owned = <String, int>{};

  int get coins => _coins;
  Map<String, int> get owned => Map<String, int>.unmodifiable(_owned);

  int quantityOf(String cardId) => _owned[cardId] ?? 0;
  bool owns(String cardId) => quantityOf(cardId) > 0;

  Future<void> load() async {
    final coins = _storage.readInt('coins');
    final ownedJson = _storage.readJson('owned_cards');

    if (coins == null || coins < 0) {
      _coins = 0;
    } else {
      _coins = coins;
    }

    final owned = <String, int>{};
    if (ownedJson != null) {
      for (final entry in ownedJson.entries) {
        final quantity = entry.value;
        if (quantity is int && quantity > 0) owned[entry.key] = quantity;
      }
    }
    _owned = owned;
  }

  Future<void> initializeForNewUser() async {
    if (_storage.readInt('coins') == null && _storage.readJson('owned_cards') == null) {
      _coins = GameConstants.startingCoins;
      _owned = <String, int>{};
      await _storage.writeInt('coins', _coins);
      await _storage.writeJson('owned_cards', <String, dynamic>{});
    } else {
      await load();
    }
  }

  Future<void> addCards(List<String> cardIds) async {
    final updated = Map<String, int>.from(_owned);
    for (final cardId in cardIds) {
      updated[cardId] = (updated[cardId] ?? 0) + 1;
    }
    _owned = updated;
    await _persist();
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) {
      throw ArgumentError("L'importo deve essere positivo");
    }
    _coins += amount;
    await _persist();
  }

  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) {
      throw ArgumentError("L'importo deve essere positivo");
    }
    if (_coins < amount) return false;
    _coins -= amount;
    await _persist();
    return true;
  }

  Future<void> _persist() async {
    await _storage.writeInt('coins', _coins);
    await _storage.writeJson('owned_cards', Map<String, dynamic>.from(_owned));
  }
}
