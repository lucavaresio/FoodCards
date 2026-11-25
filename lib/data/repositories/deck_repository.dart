import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/local/storage_service.dart';
import 'package:food_cards/data/models/deck.dart';

class DeckRepository {
  DeckRepository(this._storage);

  final StorageService _storage;
  List<Deck> _decks = <Deck>[];
  String? _activeDeckId;

  List<Deck> get decks => List<Deck>.unmodifiable(_decks);
  String? get activeDeckId => _activeDeckId;

  Deck? byId(String id) {
    for (final deck in _decks) {
      if (deck.id == id) return deck;
    }
    return null;
  }

  Future<void> load() async {
    final loaded = <Deck>[];
    final values = _storage.readJsonList('decks');
    if (values != null) {
      for (final value in values) {
        if (value is! Map) continue;
        try {
          final json = value.map((key, item) => MapEntry(key.toString(), item));
          loaded.add(Deck.fromJson(json));
        } on FormatException {
          continue;
        } catch (_) {
          continue;
        }
      }
    }
    _decks = loaded;

    final active = _storage.readString('active_deck_id');
    final activeDeck = active == null ? null : byId(active);
    _activeDeckId = activeDeck?.isComplete == true ? active : null;
    if (active != null && _activeDeckId == null) {
      await _storage.remove('active_deck_id');
    }
  }

  Future<void> save(Deck deck) async {
    final name = deck.name.trim();
    if (name.isEmpty || name.length > GameConstants.maxDeckNameLength) {
      throw ArgumentError(
        'Nome deck obbligatorio, massimo ${GameConstants.maxDeckNameLength} caratteri',
      );
    }

    final index = _decks.indexWhere((item) => item.id == deck.id);
    if (index < 0 && _decks.length >= GameConstants.maxDecks) {
      throw StateError('Hai raggiunto il limite di mazzi');
    }
    final normalizedName = _normalizeName(name);
    if (_decks.any(
      (item) =>
          item.id != deck.id && _normalizeName(item.name) == normalizedName,
    )) {
      throw ArgumentError('Nome deck già utilizzato');
    }
    if (deck.cardIds.length > GameConstants.deckSize) {
      throw ArgumentError('Il deck supera ${GameConstants.deckSize} carte');
    }
    final normalizedDeck = deck.copyWith(name: name);
    if (index >= 0) {
      _decks[index] = normalizedDeck;
    } else {
      _decks = <Deck>[..._decks, normalizedDeck];
    }
    if (_activeDeckId == deck.id && !normalizedDeck.isComplete) {
      _activeDeckId = null;
    }
    await _persist();
  }

  Future<void> delete(String id) async {
    _decks = _decks.where((deck) => deck.id != id).toList();
    if (_activeDeckId == id) _activeDeckId = null;
    await _persist();
  }

  Future<void> setActiveDeck(String? id) async {
    if (id != null) {
      final deck = byId(id);
      if (deck == null) throw ArgumentError('Deck inesistente: $id');
      if (!deck.isComplete) throw ArgumentError('Il deck non è completo');
    }

    _activeDeckId = id;
    if (id == null) {
      await _storage.remove('active_deck_id');
    } else {
      await _storage.writeString('active_deck_id', id);
    }
  }

  Future<void> _persist() async {
    await _storage.writeJsonList(
      'decks',
      _decks.map((deck) => deck.toJson()).toList(),
    );
    if (_activeDeckId == null) {
      await _storage.remove('active_deck_id');
    } else {
      await _storage.writeString('active_deck_id', _activeDeckId!);
    }
  }
}

String _normalizeName(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
