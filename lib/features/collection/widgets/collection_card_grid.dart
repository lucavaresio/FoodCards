import 'package:flutter/material.dart';

import '../../../data/models/food_card.dart';
import '../../../shared/widgets/food_card_widget.dart';
import '../../../theme/app_tokens.dart';

class CollectionCardGrid extends StatelessWidget {
  const CollectionCardGrid({
    required this.cards,
    required this.quantities,
    required this.onCardTap,
    super.key,
  });

  final List<FoodCard> cards;
  final Map<String, int> quantities;
  final ValueChanged<FoodCard> onCardTap;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      const spacing = AppSpace.xs;
      final calculatedColumns =
          ((constraints.crossAxisExtent + spacing) /
                  (AppLayout.collectionCardWidth + spacing))
              .floor();
      final columns = calculatedColumns < 1 ? 1 : calculatedColumns;

      return SliverGrid.builder(
        itemCount: cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: AppLayout.collectionCardHeight,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemBuilder: (context, index) {
          final card = cards[index];
          final quantity = quantities[card.id] ?? 0;
          return Center(
            child: SizedBox(
              width: AppLayout.collectionCardWidth,
              height: AppLayout.collectionCardHeight,
              child: FoodCardWidget(
                card: card,
                owned: quantity > 0,
                quantity: quantity,
                onTap: () => onCardTap(card),
              ),
            ),
          );
        },
      );
    },
  );
}
