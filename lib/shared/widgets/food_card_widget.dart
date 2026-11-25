import 'package:flutter/material.dart';

import '../../data/models/food_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

class FoodCardWidget extends StatelessWidget {
  const FoodCardWidget({
    required this.card,
    this.owned = true,
    this.quantity = 0,
    this.onTap,
    super.key,
  });

  final FoodCard card;
  final bool owned;
  final int quantity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: owned
        ? '${card.name}, ${card.rarity.label}, quantità $quantity'
        : 'Carta non ancora trovata, ${card.rarity.label}',
    child: GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (owned)
            Image.asset(card.imageAsset, fit: BoxFit.contain)
          else
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.espresso,
                BlendMode.saturation,
              ),
              child: Image.asset(card.imageAsset, fit: BoxFit.contain),
            ),
          if (!owned)
            const Center(
              child: Icon(Icons.lock_outline, color: AppColors.cream),
            ),
          if (owned && quantity > 1)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(AppSpace.xxs),
                decoration: const BoxDecoration(
                  color: AppColors.cheese,
                  shape: BoxShape.circle,
                ),
                child: Text('x$quantity'),
              ),
            ),
        ],
      ),
    ),
  );
}
