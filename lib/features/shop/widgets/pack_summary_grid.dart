import 'package:flutter/material.dart';

import '../../../data/models/food_card.dart';
import '../../../shared/widgets/food_card_widget.dart';
import '../../../theme/app_tokens.dart';

class PackSummaryGrid extends StatelessWidget {
  const PackSummaryGrid({
    required this.cards,
    required this.newCardIds,
    super.key,
  });

  final List<FoodCard> cards;
  final Set<String> newCardIds;

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width >= AppBreakpoint.tablet
        ? AppLayout.packSummaryTabletColumns
        : AppLayout.packSummaryPhoneColumns;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: AppLayout.collectionCardAspectRatio,
        crossAxisSpacing: AppSpace.xs,
        mainAxisSpacing: AppSpace.xs,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return Column(
          children: [
            Expanded(
              child: FoodCardWidget(card: card, owned: true, quantity: 1),
            ),
            if (newCardIds.contains(card.id))
              const Text('NUOVA', semanticsLabel: 'Carta nuova'),
          ],
        );
      },
    );
  }
}
