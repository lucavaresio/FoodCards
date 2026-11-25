import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/game_constants.dart';
import '../../data/providers.dart';
import '../../data/models/food_card.dart';
import '../../data/session_providers.dart';
import '../../router/app_routes.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'widgets/deck_list_tile.dart';

class DeckBuilderScreen extends ConsumerWidget {
  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    final coins = ref.watch(coinsProvider);
    return AppScaffold(
      title: 'Mazzi',
      currentIndex: 2,
      coins: coins,
      onDestinationSelected: (index) => context.go(AppRoutes.tabAt(index)),
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : _buildDeckList(context, ref, uid),
    );
  }

  Widget _buildDeckList(BuildContext context, WidgetRef ref, String uid) {
    final decks = ref.watch(playerDecksProvider(uid));
    final collection = ref.watch(playerCollectionProvider).value;
    final catalog = ref.watch(cardRepositoryProvider).value;
    return decks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(playerDecksProvider(uid)),
          child: const Text('Errore nel caricamento · Riprova'),
        ),
      ),
      data: (items) {
        final repository = ref.read(deckRepositoryProvider(uid));
        final canCreate = items.length < GameConstants.maxDecks;
        final hasCards =
            collection?.owned.values.any((count) => count > 0) ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (items.isEmpty && !hasCards)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpace.md),
                child: Text(
                  'Apri un pacchetto per ottenere carte e creare un mazzo.',
                ),
              ),
            if (!canCreate)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpace.xs),
                child: Text(
                  'Hai raggiunto il limite di mazzi. Eliminale per crearne uno nuovo.',
                ),
              ),
            if (items.isEmpty && !hasCards)
              StickerButton(
                label: 'VAI ALLO SHOP',
                onPressed: () => context.go(AppRoutes.shop),
              )
            else
              StickerButton(
                label: items.isEmpty ? 'CREA IL TUO PRIMO DECK' : 'NUOVO DECK',
                onPressed: canCreate
                    ? () => context.go(AppRoutes.editDeck('new'))
                    : null,
              ),
            const SizedBox(height: AppSpace.md),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final deck = items[index];
                  final preview = <FoodCard>[];
                  for (final id in deck.cardIds.take(3)) {
                    for (final card in catalog?.all ?? const <FoodCard>[]) {
                      if (card.id == id) {
                        preview.add(card);
                        break;
                      }
                    }
                  }
                  return DeckListTile(
                    deck: deck,
                    active: repository.activeDeckId == deck.id,
                    previewCards: preview,
                    onEdit: () => context.go(AppRoutes.editDeck(deck.id)),
                    onActivate: () => _activate(context, ref, uid, deck.id),
                    onDelete: () => _delete(context, ref, uid, deck.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _activate(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String deckId,
  ) async {
    try {
      await ref.read(deckRepositoryProvider(uid)).setActiveDeck(deckId);
      if (!context.mounted) return;
      ref.invalidate(playerDecksProvider(uid));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile attivare il mazzo: $error')),
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String deckId,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminare il mazzo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            label: const Text(
              'ELIMINA',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (accepted != true || !context.mounted) return;
    try {
      await ref.read(deckRepositoryProvider(uid)).delete(deckId);
      if (!context.mounted) return;
      ref.invalidate(playerDecksProvider(uid));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile eliminare il mazzo: $error')),
      );
    }
  }
}
