import 'package:food_cards/data/models/card_element.dart';
import 'package:food_cards/data/models/rarity.dart';

class FoodCard {
  const FoodCard({
    required this.id,
    required this.name,
    required this.rarity,
    required this.element,
    required this.health,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.abilityName,
    required this.description,
    required this.cardSet,
    required this.image,
  })  : assert(health >= 0),
        assert(attack >= 0),
        assert(defense >= 0),
        assert(speed >= 0);

  final String id;
  final String name;
  final Rarity rarity;
  final CardElement element;
  final int health;
  final int attack;
  final int defense;
  final int speed;
  final String abilityName;
  final String description;
  final String cardSet;
  final String image;

  String get imageAsset => 'assets/images/cards/$image';

  static dynamic _required(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key)) {
      throw FormatException('Chiave obbligatoria mancante: $key');
    }
    return json[key];
  }

  factory FoodCard.fromJson(Map<String, dynamic> json) {
    return FoodCard(
      id: _required(json, 'id') as String,
      name: _required(json, 'name') as String,
      rarity: Rarity.fromName(_required(json, 'rarity') as String),
      element: CardElement.fromName(_required(json, 'element') as String),
      health: _required(json, 'health') as int,
      attack: _required(json, 'attack') as int,
      defense: _required(json, 'defense') as int,
      speed: _required(json, 'speed') as int,
      abilityName: _required(json, 'abilityName') as String,
      description: _required(json, 'description') as String,
      cardSet: _required(json, 'cardSet') as String,
      image: _required(json, 'image') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rarity': rarity.name,
        'element': element.name,
        'health': health,
        'attack': attack,
        'defense': defense,
        'speed': speed,
        'abilityName': abilityName,
        'description': description,
        'cardSet': cardSet,
        'image': image,
      };

  FoodCard copyWith({
    String? id,
    String? name,
    Rarity? rarity,
    CardElement? element,
    int? health,
    int? attack,
    int? defense,
    int? speed,
    String? abilityName,
    String? description,
    String? cardSet,
    String? image,
  }) {
    return FoodCard(
      id: id ?? this.id,
      name: name ?? this.name,
      rarity: rarity ?? this.rarity,
      element: element ?? this.element,
      health: health ?? this.health,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
      abilityName: abilityName ?? this.abilityName,
      description: description ?? this.description,
      cardSet: cardSet ?? this.cardSet,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) => other is FoodCard && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FoodCard(id: $id, name: $name, rarity: ${rarity.name})';
}
