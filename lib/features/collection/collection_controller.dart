import '../../data/models/card_element.dart';
import '../../data/models/food_card.dart';
import '../../data/models/rarity.dart';

enum CollectionOwnershipFilter { all, owned, missing }

enum CollectionSort { catalog, rarity, name }

class CollectionFilterState {
  const CollectionFilterState({
    this.query = '',
    this.rarity,
    this.element,
    this.cardSet,
    this.ownership = CollectionOwnershipFilter.all,
    this.sort = CollectionSort.catalog,
  });

  final String query;
  final Rarity? rarity;
  final CardElement? element;
  final String? cardSet;
  final CollectionOwnershipFilter ownership;
  final CollectionSort sort;

  CollectionFilterState copyWith({
    String? query,
    Rarity? rarity,
    bool clearRarity = false,
    CardElement? element,
    bool clearElement = false,
    String? cardSet,
    bool clearSet = false,
    CollectionOwnershipFilter? ownership,
    CollectionSort? sort,
  }) => CollectionFilterState(
    query: query ?? this.query,
    rarity: clearRarity ? null : rarity ?? this.rarity,
    element: clearElement ? null : element ?? this.element,
    cardSet: clearSet ? null : cardSet ?? this.cardSet,
    ownership: ownership ?? this.ownership,
    sort: sort ?? this.sort,
  );
}

class CollectionController {
  CollectionFilterState state = const CollectionFilterState();

  void update(CollectionFilterState next) => state = next;
  void reset() => state = const CollectionFilterState();

  List<FoodCard> filter(List<FoodCard> cards, Map<String, int> owned) {
    final normalizedQuery = _normalize(state.query.trim());
    final result = cards.where((card) {
      final quantity = owned[card.id] ?? 0;
      if (state.ownership == CollectionOwnershipFilter.owned && quantity == 0) {
        return false;
      }
      if (state.ownership == CollectionOwnershipFilter.missing &&
          quantity > 0) {
        return false;
      }
      if (state.rarity != null && card.rarity != state.rarity) return false;
      if (state.element != null && card.element != state.element) return false;
      if (state.cardSet != null && card.cardSet != state.cardSet) return false;
      return normalizedQuery.isEmpty ||
          (quantity > 0 && _normalize(card.name).contains(normalizedQuery));
    }).toList();

    switch (state.sort) {
      case CollectionSort.catalog:
        result.sort((a, b) => cards.indexOf(a).compareTo(cards.indexOf(b)));
      case CollectionSort.rarity:
        result.sort((a, b) {
          final rarityOrder = b.rarity.order.compareTo(a.rarity.order);
          return rarityOrder != 0 ? rarityOrder : a.name.compareTo(b.name);
        });
      case CollectionSort.name:
        result.sort((a, b) => a.name.compareTo(b.name));
    }
    return result;
  }

  int ownedCount(List<FoodCard> cards, Map<String, int> owned) =>
      cards.where((card) => (owned[card.id] ?? 0) > 0).length;

  Map<String, (int, int)> setCounts(
    List<FoodCard> cards,
    Map<String, int> owned,
  ) {
    final counts = <String, (int, int)>{};
    for (final card in cards) {
      final current = counts[card.cardSet] ?? (0, 0);
      counts[card.cardSet] = (
        current.$1 + ((owned[card.id] ?? 0) > 0 ? 1 : 0),
        current.$2 + 1,
      );
    }
    return counts;
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp('[àáâäãå]'), 'a')
      .replaceAll(RegExp('[èéêë]'), 'e')
      .replaceAll(RegExp('[ìíîï]'), 'i')
      .replaceAll(RegExp('[òóôöõ]'), 'o')
      .replaceAll(RegExp('[ùúûü]'), 'u');
}
