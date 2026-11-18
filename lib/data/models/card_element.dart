import 'dart:ui';

import 'package:food_cards/theme/app_colors.dart';

enum CardElement {
  terra,
  fuoco,
  aria,
  acqua,
  dolce,
  erba;

  String get label => switch (this) {
        CardElement.terra => 'Terra',
        CardElement.fuoco => 'Fuoco',
        CardElement.aria => 'Aria',
        CardElement.acqua => 'Acqua',
        CardElement.dolce => 'Dolce',
        CardElement.erba => 'Erba',
      };

  Color get color => switch (this) {
        CardElement.terra => AppColors.terra,
        CardElement.fuoco => AppColors.fuoco,
        CardElement.aria => AppColors.aria,
        CardElement.acqua => AppColors.acqua,
        CardElement.dolce => AppColors.dolce,
        CardElement.erba => AppColors.erba,
      };

  static CardElement fromName(String name) {
    for (final element in CardElement.values) {
      if (element.name == name) return element;
    }
    throw ArgumentError('Elemento sconosciuto: $name');
  }
}
