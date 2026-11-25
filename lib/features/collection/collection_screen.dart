import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/food_card.dart';
import '../../data/providers.dart';
import '../../data/session_providers.dart';
import '../../router/app_routes.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../theme/app_tokens.dart';
import 'collection_controller.dart';
import 'widgets/card_detail_sheet.dart';
import 'widgets/collection_card_grid.dart';
import 'widgets/collection_filter_bar.dart';
import '../dev/dev_tools_sheet.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  final _controller = CollectionController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(cardRepositoryProvider);
    final collection = ref.watch(playerCollectionProvider);
    return AppScaffold(
      title: 'Collezione',
      currentIndex: 1,
      coins: ref.watch(coinsProvider),
      onDestinationSelected: (index) => context.go(AppRoutes.tabAt(index)),
      actions: [
        if (kDebugMode)
          IconButton(
            tooltip: 'Strumenti di sviluppo',
            icon: const Icon(Icons.build_outlined),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const DevToolsSheet(),
            ),
          ),
      ],
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Impossibile caricare il catalogo.'),
              TextButton(
                onPressed: () => ref.invalidate(cardRepositoryProvider),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
        data: (repository) => collection.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Impossibile caricare la collezione.'),
                TextButton(
                  onPressed: () => ref.invalidate(playerCollectionProvider),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          ),
          data: (player) => _buildCollection(context, repository.all, player),
        ),
      ),
    );
  }

  Widget _buildCollection(
    BuildContext context,
    List<FoodCard> cards,
    PlayerCollectionState player,
  ) {
    final filtered = _controller.filter(cards, player.owned);
    final sets = cards.map((card) => card.cardSet).toSet().toList()..sort();
    final owned = _controller.ownedCount(cards, player.owned);
    final setCounts = _controller.setCounts(cards, player.owned);
    if (owned == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Non hai ancora carte: apri un pacchetto nello shop'),
            const SizedBox(height: AppSpace.md),
            StickerButton(
              label: 'VAI ALLO SHOP',
              icon: Icons.shopping_bag_outlined,
              onPressed: () => context.go(AppRoutes.shop),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: '$owned su ${cards.length} carte possedute',
                  child: Text(
                    '$owned/${cards.length} carte',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                LinearProgressIndicator(value: owned / cards.length),
                const SizedBox(height: AppSpace.xs),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.xxs,
                  children: [
                    for (final entry in setCounts.entries)
                      Semantics(
                        label:
                            '${entry.key}: ${entry.value.$1} carte su ${entry.value.$2}',
                        child: Text(
                          '${entry.key}: ${entry.value.$1}/${entry.value.$2}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                CollectionFilterBar(
                  searchController: _searchController,
                  state: _controller.state,
                  sets: sets,
                  onChanged: (next) => setState(() => _controller.update(next)),
                  onReset: () {
                    _searchController.clear();
                    setState(_controller.reset);
                  },
                ),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('Nessuna carta trovata')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: AppSpace.lg),
            sliver: CollectionCardGrid(
              cards: filtered,
              quantities: player.owned,
              onCardTap: (card) {
                final quantity = player.quantityOf(card.id);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) =>
                      CardDetailSheet(card: card, quantity: quantity),
                );
              },
            ),
          ),
      ],
    );
  }
}
