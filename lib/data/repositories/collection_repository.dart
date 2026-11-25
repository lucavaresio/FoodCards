import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/local/storage_service.dart';

class CollectionRepository {
  CollectionRepository(this._storage);

  final StorageService _storage;
  int _coins = 0;
  Map<String, int> _owned = <String, int>{};
  String? _dailyRewardDate;

  int get coins => _coins;
  Map<String, int> get owned => Map<String, int>.unmodifiable(_owned);
  bool get hasClaimedDailyRewardToday =>
      hasClaimedDailyRewardAt(DateTime.now());

  int quantityOf(String cardId) => _owned[cardId] ?? 0;
  bool owns(String cardId) => quantityOf(cardId) > 0;
  bool hasClaimedDailyRewardAt(DateTime date) =>
      _dailyRewardDate == _dateKey(date);

  Future<void> load() async {
    final state = _storage.readJson('collection_state');
    final dailyRewardDate = state?['dailyRewardDate'];
    _dailyRewardDate = dailyRewardDate is String ? dailyRewardDate : null;
    final coins = state?['coins'] is int
        ? state!['coins'] as int
        : _storage.readInt('coins');
    final ownedValue = state?['owned'];
    final ownedJson = ownedValue is Map<String, dynamic>
        ? ownedValue
        : _storage.readJson('owned_cards');

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
    if (_storage.readJson('collection_state') == null &&
        _storage.readInt('coins') == null &&
        _storage.readJson('owned_cards') == null) {
      _coins = GameConstants.startingCoins;
      _owned = <String, int>{};
      await _persist();
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

  Future<void> clearOwnedCards() async {
    _owned = <String, int>{};
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

  Future<void> purchasePack(int cost, List<String> cardIds) async {
    if (cost <= 0) throw ArgumentError.value(cost, 'cost');
    if (_coins < cost) throw const InsufficientCoins();

    final previousCoins = _coins;
    final previousOwned = Map<String, int>.from(_owned);
    _coins -= cost;
    for (final cardId in cardIds) {
      _owned[cardId] = (_owned[cardId] ?? 0) + 1;
    }

    try {
      await _persist();
    } catch (_) {
      _coins = previousCoins;
      _owned = previousOwned;
      rethrow;
    }
  }

  Future<void> claimDailyReward(List<String> cardIds, {DateTime? at}) async {
    if (cardIds.isEmpty) {
      throw ArgumentError.value(cardIds, 'cardIds', 'Il premio è vuoto');
    }
    final date = at ?? DateTime.now();
    if (hasClaimedDailyRewardAt(date)) {
      throw StateError('Il premio giornaliero è già stato ritirato');
    }

    final previousOwned = Map<String, int>.from(_owned);
    final previousDate = _dailyRewardDate;
    for (final cardId in cardIds) {
      _owned[cardId] = (_owned[cardId] ?? 0) + 1;
    }
    _dailyRewardDate = _dateKey(date);

    try {
      await _persist();
    } catch (_) {
      _owned = previousOwned;
      _dailyRewardDate = previousDate;
      rethrow;
    }
  }

  Future<void> _persist() async {
    await _storage.writeJson('collection_state', {
      'coins': _coins,
      'owned': Map<String, dynamic>.from(_owned),
      'dailyRewardDate': _dailyRewardDate,
    });
  }

  String _dateKey(DateTime date) {
    final utc = date.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }
}

class InsufficientCoins implements Exception {
  const InsufficientCoins();
}
