import 'dart:ui';

import 'package:food_cards/theme/app_colors.dart';

enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;

  String get label => switch (this) {
        Rarity.common => 'Comune',
        Rarity.uncommon => 'Non comune',
        Rarity.rare => 'Rara',
        Rarity.epic => 'Epica',
        Rarity.legendary => 'Leggendaria',
      };

  Color get color => switch (this) {
        Rarity.common => AppColors.common,
        Rarity.uncommon => AppColors.uncommon,
        Rarity.rare => AppColors.rare,
        Rarity.epic => AppColors.epic,
        Rarity.legendary => AppColors.legendary,
      };

  int get order => index;

  static Rarity fromName(String name) {
    for (final rarity in Rarity.values) {
      if (rarity.name == name) return rarity;
    }
    throw ArgumentError('Rarità sconosciuta: $name');
  }
}
