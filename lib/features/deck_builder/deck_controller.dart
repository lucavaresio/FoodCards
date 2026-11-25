import '../../constants/game_constants.dart';
import '../../data/models/deck.dart';
import '../../data/models/food_card.dart';
import '../../data/repositories/deck_repository.dart';

String? validateDeckName(
  String value,
  Iterable<Deck> decks, {
  String? editingId,
}) {
  final name = value.trim();
  if (name.isEmpty) return 'Inserisci un nome';
  if (name.length > GameConstants.maxDeckNameLength) {
    return 'Massimo ${GameConstants.maxDeckNameLength} caratteri';
  }
  final normalized = _normalizeDeckName(name);
  if (decks.any(
    (deck) =>
        deck.id != editingId && _normalizeDeckName(deck.name) == normalized,
  )) {
    return 'Nome già usato';
  }
  return null;
}

class DeckDraft {
  DeckDraft({
    required this.id,
    required this.name,
    required List<String> cardIds,
  }) : cardIds = List.of(cardIds);

  final String id;
  String name;
  final List<String> cardIds;

  bool get isComplete => cardIds.length == GameConstants.deckSize;
  int get remainingSlots => GameConstants.deckSize - cardIds.length;

  bool addCard(String cardId, Map<String, int> owned) {
    if (cardIds.length >= GameConstants.deckSize) return false;
    final copiesInDraft = cardIds.where((id) => id == cardId).length;
    if (copiesInDraft >= (owned[cardId] ?? 0)) return false;
    cardIds.add(cardId);
    return true;
  }

  bool removeCard(String cardId) => cardIds.remove(cardId);

  void clear() => cardIds.clear();

  List<String> reconcile(Map<String, int> owned) {
    final removed = <String>[];
    final keptCounts = <String, int>{};
    cardIds.removeWhere((id) {
      final nextCount = (keptCounts[id] ?? 0) + 1;
      if (nextCount > (owned[id] ?? 0)) {
        removed.add(id);
        return true;
      }
      keptCounts[id] = nextCount;
      return false;
    });
    return removed;
  }

  void autocomplete(List<FoodCard> cards, Map<String, int> owned) {
    final sorted = List<FoodCard>.of(cards)
      ..sort((a, b) => _cardStrength(b).compareTo(_cardStrength(a)));
    for (final card in sorted) {
      while (remainingSlots > 0 &&
          cardIds.where((id) => id == card.id).length < (owned[card.id] ?? 0)) {
        cardIds.add(card.id);
      }
      if (remainingSlots == 0) break;
    }
  }

  Future<void> save(DeckRepository repository) async {
    final currentDeck = repository.byId(id);
    final error = validateDeckName(
      name,
      repository.decks,
      editingId: currentDeck?.id,
    );
    if (error != null) throw ArgumentError(error);
    await repository.save(Deck(id: id, name: name.trim(), cardIds: cardIds));
  }
}

String _normalizeDeckName(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

int _cardStrength(FoodCard card) =>
    card.health + card.attack + card.defense + card.speed;
