import 'package:flutter/material.dart';

import '../../../constants/game_constants.dart';
import '../../../data/models/deck.dart';
import '../../../data/models/food_card.dart';
import '../../../shared/widgets/sticker_cards.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_tokens.dart';

class DeckListTile extends StatelessWidget {
  const DeckListTile({
    required this.deck,
    required this.active,
    required this.onEdit,
    required this.onActivate,
    required this.onDelete,
    this.previewCards = const [],
    super.key,
  });

  final Deck deck;
  final bool active;
  final VoidCallback onEdit;
  final VoidCallback onActivate;
  final VoidCallback onDelete;
  final List<FoodCard> previewCards;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.sm),
    child: StickerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(deck.name, style: Theme.of(context).textTheme.titleMedium),
          Text('${deck.cardIds.length}/${GameConstants.deckSize} carte'),
          if (previewCards.isNotEmpty)
            Row(
              children: [
                for (final card in previewCards.take(3))
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpace.xs),
                    child: SizedBox(
                      width: AppSpace.xl,
                      height: AppSpace.xxl,
                      child: Image.asset(card.imageAsset, fit: BoxFit.contain),
                    ),
                  ),
              ],
            ),
          if (!deck.isComplete)
            const Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning),
                SizedBox(width: AppSpace.xs),
                Text('Deck incompleto'),
              ],
            ),
          if (active) const Text('ATTIVO'),
          Wrap(
            spacing: AppSpace.xs,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Modifica'),
              ),
              if (!active && deck.isComplete)
                TextButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Attiva'),
                ),
              IconButton(
                tooltip: 'Elimina ${deck.name}',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
