import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/local/storage_service.dart';
import 'package:food_cards/data/models/card_element.dart';
import 'package:food_cards/data/models/deck.dart';
import 'package:food_cards/data/models/food_card.dart';
import 'package:food_cards/data/models/rarity.dart';
import 'package:food_cards/data/repositories/deck_repository.dart';
import 'package:food_cards/features/deck_builder/deck_controller.dart';
import 'package:food_cards/features/deck_builder/widgets/deck_list_tile.dart';
import 'package:food_cards/features/deck_builder/widgets/deck_slot.dart';
import 'package:food_cards/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('draft rispetta quantità, limite, rimozione e autocomplete', () {
    final draft = DeckDraft(id: 'new', name: 'Test', cardIds: []);
    expect(draft.addCard('small', {'small': 1}), isTrue);
    expect(draft.addCard('small', {'small': 1}), isFalse);
    draft.autocomplete(
      [_food('weak', 4), _food('strong', 25)],
      {'small': 1, 'weak': 4, 'strong': 6},
    );
    expect(draft.cardIds.length, GameConstants.deckSize);
    expect(draft.cardIds.where((id) => id == 'strong').length, 6);
    expect(draft.removeCard('small'), isTrue);
    expect(draft.cardIds.length, GameConstants.deckSize - 1);
    draft.clear();
    expect(draft.cardIds, isEmpty);
  });

  test(
    'nomi sono obbligatori, limitati e unici ignorando spazi e maiuscole',
    () {
      final decks = [Deck(id: 'one', name: 'Pizza Deck', cardIds: const [])];
      expect(validateDeckName(' ', decks), 'Inserisci un nome');
      expect(
        validateDeckName('x' * (GameConstants.maxDeckNameLength + 1), decks),
        isNotNull,
      );
      expect(validateDeckName('PIZZAdeck', decks), 'Nome già usato');
      expect(validateDeckName('Pizza Deck', decks, editingId: 'one'), isNull);
    },
  );

  test(
    'repository applica limite, nome univoco e mazzo attivo completo',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final repository = DeckRepository(
        StorageService(preferences, uid: 'deck-rules'),
      );
      await repository.load();
      final incomplete = Deck(id: 'incomplete', name: 'Bozza', cardIds: ['a']);
      await repository.save(incomplete);
      await expectLater(
        repository.setActiveDeck(incomplete.id),
        throwsA(isA<ArgumentError>()),
      );
      final complete = Deck(
        id: 'complete',
        name: 'Completo',
        cardIds: List.generate(GameConstants.deckSize, (index) => '$index'),
      );
      await repository.save(complete);
      await repository.setActiveDeck(complete.id);
      await repository.save(complete.copyWith(cardIds: const ['a']));
      expect(repository.activeDeckId, isNull);
      await expectLater(
        repository.save(Deck(id: 'duplicate', name: ' BOZZA ', cardIds: [])),
        throwsA(isA<ArgumentError>()),
      );
      for (var index = 2; index < GameConstants.maxDecks; index++) {
        await repository.save(
          Deck(id: 'deck-$index', name: 'Deck $index', cardIds: []),
        );
      }
      await expectLater(
        repository.save(Deck(id: 'overflow', name: 'Overflow', cardIds: [])),
        throwsA(isA<StateError>()),
      );
    },
  );

  testWidgets('slot vuoto e avviso del mazzo incompleto sono visibili', (
    tester,
  ) async {
    final deck = Deck(id: 'draft', name: 'Bozza', cardIds: ['a']);
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme(),
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(width: 64, height: 96, child: DeckSlot()),
              DeckListTile(
                deck: deck,
                active: false,
                onEdit: () {},
                onActivate: () {},
                onDelete: () {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Deck incompleto'), findsOneWidget);
  });
}

FoodCard _food(String id, int strength) => FoodCard(
  id: id,
  name: id,
  rarity: Rarity.common,
  element: CardElement.terra,
  health: strength,
  attack: strength,
  defense: 0,
  speed: 0,
  abilityName: '',
  description: '',
  cardSet: 'Test',
  image: '',
);
