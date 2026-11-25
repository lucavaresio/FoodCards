import 'package:flutter/material.dart';

import '../../../data/models/food_card.dart';
import '../../../shared/widgets/food_card_widget.dart';
import '../../../theme/app_tokens.dart';

class AvailableCardsList extends StatelessWidget {
  const AvailableCardsList({
    required this.cards,
    required this.owned,
    required this.deckCards,
    required this.onAdd,
    required this.deckFull,
    super.key,
  });

  final List<FoodCard> cards;
  final Map<String, int> owned;
  final List<String> deckCards;
  final ValueChanged<FoodCard> onAdd;
  final bool deckFull;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: cards.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: MediaQuery.sizeOf(context).width >= AppBreakpoint.tablet
          ? AppLayout.collectionTabletColumns
          : AppLayout.collectionPhoneColumns,
      childAspectRatio: AppLayout.collectionCardAspectRatio,
      crossAxisSpacing: AppSpace.xs,
      mainAxisSpacing: AppSpace.xs,
    ),
    itemBuilder: (context, index) {
      final card = cards[index];
      final count = deckCards.where((id) => id == card.id).length;
      final available = count < (owned[card.id] ?? 0);
      final disabled = deckFull || !available;
      return Semantics(
        enabled: !disabled,
        label:
            '${card.name}, quantità ${owned[card.id] ?? 0}, nel mazzo $count'
            '${deckFull
                ? ', mazzo pieno'
                : available
                ? ''
                : ', copie esaurite'}',
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: disabled ? 0.5 : 1,
                child: FoodCardWidget(
                  card: card,
                  owned: true,
                  quantity: owned[card.id] ?? 0,
                  onTap: disabled ? null : () => onAdd(card),
                ),
              ),
            ),
            if (count > 0)
              Align(
                alignment: Alignment.topCenter,
                child: Chip(label: Text('Nel mazzo: $count')),
              ),
            if (disabled)
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(deckFull ? 'Mazzo pieno' : 'Copie esaurite'),
              ),
          ],
        ),
      );
    },
  );
}
