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
  Widget build(BuildContext context) {
    final activeFilters = <String>[
      if (state.rarity != null) state.rarity!.label,
      if (state.cardSet != null) state.cardSet!,
      if (state.element != null) state.element!.label,
      if (state.ownership != CollectionOwnershipFilter.all)
        switch (state.ownership) {
          CollectionOwnershipFilter.owned => 'Possedute',
          CollectionOwnershipFilter.missing => 'Mancanti',
          CollectionOwnershipFilter.all => '',
        },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StickerTextField(
          controller: searchController,
          labelText: 'Cerca tra le carte possedute',
          prefixIcon: const Icon(Icons.search),
          onChanged: (value) => onChanged(state.copyWith(query: value)),
        ),
        const SizedBox(height: AppSpace.xs),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: AppSpace.sm),
          leading: const Icon(Icons.tune),
          title: const Text('Filtri e ordinamento'),
          subtitle: Text(
            activeFilters.isEmpty
                ? 'Tutte le carte'
                : activeFilters.join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FilterLabel(label: 'Rarità'),
                Wrap(
                  spacing: AppSpace.xs,
                  runSpacing: AppSpace.xxs,
                  children: [
                    RarityChip(
                      label: 'Tutte',
                      selected: state.rarity == null,
                      onSelected: (_) =>
                          onChanged(state.copyWith(clearRarity: true)),
                    ),
                    for (final rarity in Rarity.values)
                      RarityChip(
                        label: rarity.label,
                        rarity: rarity,
                        selected: state.rarity == rarity,
                        onSelected: (_) =>
                            onChanged(state.copyWith(rarity: rarity)),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                _FilterLabel(label: 'Possesso'),
                Wrap(
                  spacing: AppSpace.xs,
                  runSpacing: AppSpace.xxs,
                  children: [
                    for (final filter in CollectionOwnershipFilter.values)
                      ChoiceChip(
                        label: Text(switch (filter) {
                          CollectionOwnershipFilter.all => 'Tutte',
                          CollectionOwnershipFilter.owned => 'Possedute',
                          CollectionOwnershipFilter.missing => 'Mancanti',
                        }),
                        selected: state.ownership == filter,
                        onSelected: (_) =>
                            onChanged(state.copyWith(ownership: filter)),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                _FilterLabel(label: 'Set'),
                Wrap(
                  spacing: AppSpace.xs,
                  runSpacing: AppSpace.xxs,
                  children: [
                    ChoiceChip(
                      label: const Text('Tutti i set'),
                      selected: state.cardSet == null,
                      onSelected: (_) =>
                          onChanged(state.copyWith(clearSet: true)),
                    ),
                    for (final cardSet in sets)
                      ChoiceChip(
                        label: Text(cardSet),
                        selected: state.cardSet == cardSet,
                        onSelected: (_) =>
                            onChanged(state.copyWith(cardSet: cardSet)),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                _FilterLabel(label: 'Elemento'),
                Wrap(
                  spacing: AppSpace.xs,
                  runSpacing: AppSpace.xxs,
                  children: [
                    ChoiceChip(
                      label: const Text('Tutti'),
                      selected: state.element == null,
                      onSelected: (_) =>
                          onChanged(state.copyWith(clearElement: true)),
                    ),
                    for (final element in CardElement.values)
                      ChoiceChip(
                        label: Text(element.label),
                        selected: state.element == element,
                        onSelected: (_) =>
                            onChanged(state.copyWith(element: element)),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.sm),
                Row(
                  children: [
                    const Text('Ordina:'),
                    const SizedBox(width: AppSpace.xs),
                    Expanded(
                      child: DropdownButton<CollectionSort>(
                        isExpanded: true,
                        value: state.sort,
                        items: const [
                          DropdownMenuItem(
                            value: CollectionSort.catalog,
                            child: Text('Catalogo'),
                          ),
                          DropdownMenuItem(
                            value: CollectionSort.rarity,
                            child: Text('Rarità'),
                          ),
                          DropdownMenuItem(
                            value: CollectionSort.name,
                            child: Text('Nome'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            onChanged(state.copyWith(sort: value));
                          }
                        },
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onReset,
                      icon: const Icon(Icons.filter_alt_off),
                      label: const Text('Azzera'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.xxs),
    child: Text(label, style: Theme.of(context).textTheme.labelLarge),
  );
}
