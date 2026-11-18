import 'package:food_cards/constants/game_constants.dart';

class Deck {
  Deck({
    required this.id,
    required this.name,
    required List<String> cardIds,
  }) : cardIds = List<String>.unmodifiable(cardIds);

  final String id;
  final String name;
  final List<String> cardIds;

  bool get isComplete => cardIds.length == GameConstants.deckSize;

  int get missingCards =>
      cardIds.length >= GameConstants.deckSize ? 0 : GameConstants.deckSize - cardIds.length;

  Deck copyWith({String? id, String? name, List<String>? cardIds}) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      cardIds: cardIds ?? this.cardIds,
    );
  }

  factory Deck.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id')) {
      throw const FormatException('Chiave obbligatoria mancante: id');
    }
    if (!json.containsKey('name')) {
      throw const FormatException('Chiave obbligatoria mancante: name');
    }
    if (!json.containsKey('cardIds')) {
      throw const FormatException('Chiave obbligatoria mancante: cardIds');
    }

    return Deck(
      id: json['id'] as String,
      name: json['name'] as String,
      cardIds: (json['cardIds'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cardIds': List<String>.from(cardIds),
      };

  @override
  bool operator ==(Object other) =>
      other is Deck && other.id == id && other.name == name && _listEquals(other.cardIds, cardIds);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(cardIds));

  bool _listEquals(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'Deck(id: $id, name: $name, cardIds: ${cardIds.length})';
}
