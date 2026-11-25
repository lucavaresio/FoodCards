import 'package:flutter/material.dart';

import '../../../data/models/food_card.dart';
import '../../../shared/widgets/food_card_widget.dart';
import '../../../shared/widgets/rarity_chip.dart';
import '../../../theme/app_tokens.dart';

class CardDetailSheet extends StatelessWidget {
  const CardDetailSheet({
    required this.card,
    required this.quantity,
    super.key,
  });

  final FoodCard card;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final owned = quantity > 0;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Semantics(
          explicitChildNodes: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width:
                      MediaQuery.sizeOf(context).width *
                      AppLayout.collectionDetailImageWidthFactor,
                  child: AspectRatio(
                    aspectRatio: AppLayout.collectionCardAspectRatio,
                    child: FoodCardWidget(
                      card: card,
                      owned: owned,
                      quantity: quantity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              if (owned)
                Text(card.name, style: Theme.of(context).textTheme.titleLarge)
              else
                Text('???', style: Theme.of(context).textTheme.titleLarge),
              Wrap(
                spacing: AppSpace.xs,
                children: [
                  RarityChip(label: card.rarity.label, rarity: card.rarity),
                  Chip(label: Text(card.element.label)),
                ],
              ),
              Text('Set: ${card.cardSet}'),
              if (owned) ...[
                const SizedBox(height: AppSpace.sm),
                Wrap(
                  spacing: AppSpace.md,
                  runSpacing: AppSpace.xs,
                  children: [
                    _stat('Vita', card.health),
                    _stat('Forza', card.attack),
                    _stat('Difesa', card.defense),
                    _stat('Velocità', card.speed),
                  ],
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  card.abilityName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(card.description),
                Text('Quantità: $quantity'),
              ] else
                const Text('Non ancora trovata'),
              const SizedBox(height: AppSpace.md),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: const Text('CHIUDI'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, int value) => Semantics(
    label: '$label: $value',
    child: Chip(label: Text('$label $value')),
  );
}
