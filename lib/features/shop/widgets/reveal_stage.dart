import 'package:flutter/material.dart';

import '../../../data/models/food_card.dart';
import '../../../shared/widgets/food_card_widget.dart';
import '../../../theme/app_tokens.dart';
import 'card_back.dart';

class RevealStage extends StatelessWidget {
  const RevealStage({
    required this.card,
    required this.revealed,
    required this.isNew,
    required this.onTap,
    super.key,
  });

  final FoodCard card;
  final bool revealed;
  final bool isNew;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: revealed ? 'Carta ${card.name}' : 'Tocca per rivelare la carta',
    onTap: onTap,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? AppDuration.base
            : AppDuration.slow,
        child: revealed
            ? Stack(
                key: ValueKey(card.id),
                children: [
                  AspectRatio(
                    aspectRatio: AppLayout.collectionCardAspectRatio,
                    child: FoodCardWidget(card: card, owned: true, quantity: 1),
                  ),
                  if (isNew)
                    const Positioned(
                      top: AppSpace.xs,
                      left: AppSpace.xs,
                      child: Chip(label: Text('NUOVA')),
                    ),
                ],
              )
            : const CardBack(key: ValueKey('back')),
      ),
    ),
  );
}
