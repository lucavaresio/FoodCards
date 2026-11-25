import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/data/models/card_element.dart';
import 'package:food_cards/data/models/food_card.dart';
import 'package:food_cards/data/models/rarity.dart';
import 'package:food_cards/data/repositories/card_repository.dart';
import 'package:food_cards/features/collection/collection_controller.dart';
import 'package:food_cards/features/collection/widgets/card_detail_sheet.dart';
import 'package:food_cards/features/collection/widgets/collection_filter_bar.dart';
import 'package:food_cards/theme/app_theme.dart';

void main() {
  final cards = [
    _card('a', 'Caffè', Rarity.common),
    _card('b', 'Éclair', Rarity.rare),
    _card('c', 'Mela', Rarity.epic),
  ];

  test('ricerca accent-insensitive mostra solo carte possedute', () {
    final controller = CollectionController()
      ..update(const CollectionFilterState(query: 'caffe'));
    expect(controller.filter(cards, {'a': 1}).map((card) => card.id), ['a']);
    expect(controller.filter(cards, {}).map((card) => card.id), isEmpty);
  });

  test('combina rarità, set, elemento e possesso', () {
    final controller = CollectionController()
      ..update(
        const CollectionFilterState(
          rarity: Rarity.rare,
          element: CardElement.dolce,
          cardSet: 'Dolci',
          ownership: CollectionOwnershipFilter.owned,
        ),
      );
    expect(controller.filter(cards, {'b': 1}).single.id, 'b');
    expect(controller.filter(cards, {}).isEmpty, isTrue);
  });

  test('conta carte uniche e ordina per rarità', () {
    final controller = CollectionController()
      ..update(const CollectionFilterState(sort: CollectionSort.rarity));
    expect(controller.ownedCount(cards, {'a': 3, 'b': 1}), 2);
    expect(controller.filter(cards, {'a': 1}).map((card) => card.id), [
      'c',
      'b',
      'a',
    ]);
    expect(controller.setCounts(cards, {'a': 1})['Dolci'], (1, 3));
  });

  testWidgets('il dettaglio non posseduto non rivela il nome', (tester) async {
    final catalog = CardRepository();
    await catalog.load();
    final card = catalog.requireById('carolina_reaper');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CardDetailSheet(card: card, quantity: 0)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('???'), findsOneWidget);
    expect(find.text(card.name), findsNothing);
    expect(find.text('Non ancora trovata'), findsOneWidget);
  });

  testWidgets('i filtri si espandono senza tagliare i chip su mobile', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CollectionFilterBar(
              searchController: searchController,
              state: const CollectionFilterState(),
              sets: const [
                'Dolci',
                'Ortaggi',
                'Frutta',
                'Piccante',
                'Fast food',
              ],
              onChanged: (_) {},
              onReset: () {},
            ),
          ),
        ),
      ),
    );
    expect(find.text('Elemento'), findsNothing);
    await tester.tap(find.text('Filtri e ordinamento'));
    await tester.pumpAndSettle();

    expect(find.text('Elemento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

FoodCard _card(String id, String name, Rarity rarity) => FoodCard(
  id: id,
  name: name,
  rarity: rarity,
  element: CardElement.dolce,
  health: 1,
  attack: 1,
  defense: 1,
  speed: 1,
  abilityName: 'Test',
  description: 'Test',
  cardSet: 'Dolci',
  image: '$id.png',
);
