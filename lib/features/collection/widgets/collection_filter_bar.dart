import 'package:flutter/material.dart';

import '../../../data/models/card_element.dart';
import '../../../data/models/rarity.dart';
import '../../../shared/widgets/rarity_chip.dart';
import '../../../shared/widgets/sticker_text_field.dart';
import '../../../theme/app_tokens.dart';
import '../collection_controller.dart';

class CollectionFilterBar extends StatelessWidget {
  const CollectionFilterBar({
    required this.searchController,
    required this.state,
    required this.sets,
    required this.onChanged,
    required this.onReset,
    super.key,
  });

  final TextEditingController searchController;
  final CollectionFilterState state;
  final List<String> sets;
  final ValueChanged<CollectionFilterState> onChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StickerTextField(
        controller: searchController,
        labelText: 'Cerca tra le carte possedute',
        prefixIcon: const Icon(Icons.search),
        onChanged: (value) => onChanged(state.copyWith(query: value)),
      ),
      const SizedBox(height: AppSpace.sm),
      Text('Rarità', style: Theme.of(context).textTheme.labelLarge),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            RarityChip(
              label: 'Tutte',
              selected: state.rarity == null,
              onSelected: (_) => onChanged(state.copyWith(clearRarity: true)),
            ),
            for (final rarity in Rarity.values)
              RarityChip(
                label: rarity.label,
                rarity: rarity,
                selected: state.rarity == rarity,
                onSelected: (_) => onChanged(state.copyWith(rarity: rarity)),
              ),
          ],
        ),
      ),
      Wrap(
        spacing: AppSpace.xs,
        children: [
          for (final filter in CollectionOwnershipFilter.values)
            ChoiceChip(
              label: Text(switch (filter) {
                CollectionOwnershipFilter.all => 'Tutte',
                CollectionOwnershipFilter.owned => 'Possedute',
                CollectionOwnershipFilter.missing => 'Mancanti',
              }),
              selected: state.ownership == filter,
              onSelected: (_) => onChanged(state.copyWith(ownership: filter)),
            ),
        ],
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('Tutti i set'),
              selected: state.cardSet == null,
              onSelected: (_) => onChanged(state.copyWith(clearSet: true)),
            ),
            for (final cardSet in sets)
              ChoiceChip(
                label: Text(cardSet),
                selected: state.cardSet == cardSet,
                onSelected: (_) => onChanged(state.copyWith(cardSet: cardSet)),
              ),
          ],
        ),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('Tutti gli elementi'),
              selected: state.element == null,
              onSelected: (_) => onChanged(state.copyWith(clearElement: true)),
            ),
            for (final element in CardElement.values)
              ChoiceChip(
                label: Text(element.label),
                selected: state.element == element,
                onSelected: (_) => onChanged(state.copyWith(element: element)),
              ),
          ],
        ),
      ),
      Row(
        children: [
          const Text('Ordina:'),
          const SizedBox(width: AppSpace.xs),
          DropdownButton<CollectionSort>(
            value: state.sort,
            items: const [
              DropdownMenuItem(
                value: CollectionSort.catalog,
                child: Text('Numero catalogo'),
              ),
              DropdownMenuItem(
                value: CollectionSort.rarity,
                child: Text('Rarità'),
              ),
              DropdownMenuItem(value: CollectionSort.name, child: Text('Nome')),
            ],
            onChanged: (value) {
              if (value != null) onChanged(state.copyWith(sort: value));
            },
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Azzera'),
          ),
        ],
      ),
    ],
  );
}
