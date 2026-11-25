import 'package:flutter/material.dart';

import '../../../data/models/food_card.dart';
import '../../../shared/widgets/food_card_widget.dart';
import '../../../theme/app_tokens.dart';
import 'dashed_border.dart';

class DeckSlot extends StatelessWidget {
  const DeckSlot({
    this.card,
    this.owned = true,
    this.quantity = 0,
    this.onTap,
    super.key,
  });

  final FoodCard? card;
  final bool owned;
  final int quantity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (card == null) {
      return Semantics(
        label: 'Slot mazzo vuoto',
        child: DashedBorder(
          child: Icon(
            Icons.add,
            size: AppSpace.xl,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: AppLayout.collectionCardAspectRatio,
        child: FoodCardWidget(
          card: card!,
          owned: owned,
          quantity: quantity,
          onTap: onTap,
        ),
      ),
    );
  }
}
