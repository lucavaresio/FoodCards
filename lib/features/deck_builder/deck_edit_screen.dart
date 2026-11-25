import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/game_constants.dart';
import '../../data/models/deck.dart';
import '../../data/models/food_card.dart';
import '../../data/providers.dart';
import '../../data/session_providers.dart';
import '../../router/app_routes.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../shared/widgets/sticker_text_field.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../collection/collection_controller.dart';
import '../collection/widgets/collection_filter_bar.dart';
import 'deck_controller.dart';
import 'widgets/available_cards_list.dart';
import 'widgets/deck_slot.dart';

class DeckEditScreen extends ConsumerStatefulWidget {
  const DeckEditScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<DeckEditScreen> createState() => _DeckEditScreenState();
}

class _DeckEditScreenState extends ConsumerState<DeckEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _filters = CollectionController();
  DeckDraft? _draft;
  String? _draftId;
  bool _saved = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);
    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final decks = ref.watch(playerDecksProvider(uid));
    final catalog = ref.watch(cardRepositoryProvider);
    final collection = ref.watch(playerCollectionProvider);

    if (decks.isLoading || catalog.isLoading || collection.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (decks.hasError || catalog.hasError || collection.hasError) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              ref.invalidate(playerDecksProvider(uid));
              ref.invalidate(cardRepositoryProvider);
              ref.invalidate(playerCollectionProvider);
            },
            child: const Text('Errore di caricamento · Riprova'),
          ),
        ),
      );
    }

    final deckList = decks.requireValue;
    final cards = catalog.requireValue.all;
    final owned = collection.requireValue.owned;
    Deck? existing;
    for (final deck in deckList) {
      if (deck.id == widget.deckId) {
        existing = deck;
        break;
      }
    }
    if (widget.deckId != 'new' && existing == null) {
      return const Scaffold(body: Center(child: Text('Mazzo non trovato')));
    }
    if (_draftId != widget.deckId) {
      _draftId = widget.deckId;
      final id = widget.deckId == 'new'
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : widget.deckId;
      _draft = DeckDraft(
        id: id,
        name: existing?.name ?? '',
        cardIds: existing?.cardIds ?? const [],
      );
      _nameController.text = _draft!.name;
    }
    final draft = _draft!;
    final ownedCards = cards
        .where((card) => (owned[card.id] ?? 0) > 0)
        .toList();
    final visibleCards = _filters.filter(ownedCards, owned);

    return PopScope(
      canPop: _saved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context, AppRoutes.deck);
      },
      child: AppScaffold(
        title: widget.deckId == 'new' ? 'Nuovo mazzo' : 'Modifica mazzo',
        currentIndex: 2,
        coins: ref.watch(coinsProvider),
        onDestinationSelected: (index) =>
            _confirmExit(context, AppRoutes.tabAt(index)),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              StickerTextField(
                controller: _nameController,
                labelText: 'Nome del mazzo',
                maxLength: GameConstants.maxDeckNameLength,
                textCapitalization: TextCapitalization.words,
                validator: (value) => validateDeckName(
                  value ?? '',
                  deckList,
                  editingId: existing?.id,
                ),
                onChanged: (value) => draft.name = value,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                child: Text(
                  '${draft.cardIds.length}/${GameConstants.deckSize} carte',
                ),
              ),
              if (!draft.isComplete)
                const ListTile(
                  leading: Icon(Icons.warning_amber, color: AppColors.warning),
                  title: Text('Deck incompleto'),
                ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: GameConstants.deckSize,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: AppLayout.collectionCardAspectRatio,
                  crossAxisSpacing: AppSpace.xxs,
                  mainAxisSpacing: AppSpace.xxs,
                ),
                itemBuilder: (context, index) {
                  final card = index < draft.cardIds.length
                      ? _byId(cards, draft.cardIds[index])
                      : null;
                  return DeckSlot(
                    card: card,
                    owned: card != null && (owned[card.id] ?? 0) > 0,
                    quantity: card == null ? 0 : owned[card.id] ?? 0,
                    onTap: card == null
                        ? null
                        : () => setState(() => draft.removeCard(card.id)),
                  );
                },
              ),
              const SizedBox(height: AppSpace.md),
              CollectionFilterBar(
                searchController: _searchController,
                state: _filters.state,
                sets: ownedCards.map((card) => card.cardSet).toSet().toList(),
                onChanged: (state) => setState(() => _filters.update(state)),
                onReset: () {
                  _searchController.clear();
                  setState(_filters.reset);
                },
              ),
              AvailableCardsList(
                cards: visibleCards,
                owned: owned,
                deckCards: draft.cardIds,
                deckFull: draft.cardIds.length >= GameConstants.deckSize,
                onAdd: (card) => setState(() => draft.addCard(card.id, owned)),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _confirmClear(draft),
                    child: const Text('SVUOTA'),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => draft.autocomplete(cards, owned)),
                    child: const Text('AUTOCOMPLETA'),
                  ),
                ],
              ),
              StickerButton(
                label: 'SALVA',
                onPressed: () => _save(context, uid, draft, cards, owned),
              ),
              const SizedBox(height: AppSpace.md),
            ],
          ),
        ),
      ),
    );
  }

  FoodCard? _byId(List<FoodCard> cards, String id) {
    for (final card in cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  Future<void> _save(
    BuildContext context,
    String uid,
    DeckDraft draft,
    List<FoodCard> cards,
    Map<String, int> owned,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    draft.name = _nameController.text;
    final catalogIds = cards.map((card) => card.id).toSet();
    final validOwned = Map<String, int>.fromEntries(
      owned.entries.where((entry) => catalogIds.contains(entry.key)),
    );
    final removed = draft.reconcile(validOwned);
    try {
      await draft.save(ref.read(deckRepositoryProvider(uid)));
      if (!context.mounted) return;
      _saved = true;
      ref.invalidate(playerDecksProvider(uid));
      if (removed.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carte non più possedute rimosse dal mazzo'),
          ),
        );
      }
      context.go(AppRoutes.deck);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile salvare il mazzo: $error')),
      );
    }
  }

  Future<void> _confirmExit(BuildContext context, String destination) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Uscire senza salvare?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ESCI'),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted) context.go(destination);
  }

  Future<void> _confirmClear(DeckDraft draft) async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Svuotare il mazzo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('SVUOTA'),
          ),
        ],
      ),
    );
    if (clear == true && context.mounted) {
      setState(draft.clear);
    }
  }
}
