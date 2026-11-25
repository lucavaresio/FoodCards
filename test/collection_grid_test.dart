import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/data/repositories/card_repository.dart';
import 'package:food_cards/features/collection/widgets/collection_card_grid.dart';
import 'package:food_cards/shared/widgets/food_card_widget.dart';
import 'package:food_cards/theme/app_theme.dart';
import 'package:food_cards/theme/app_tokens.dart';

void main() {
  testWidgets('la griglia mantiene dimensioni fisse su telefono e tablet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final catalog = CardRepository();
    await catalog.load();
    final card = catalog.requireById('carolina_reaper');

    Future<Size> cardSizeAt(double width) async {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme(),
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                CollectionCardGrid(
                  cards: [card],
                  quantities: const {},
                  onCardTap: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      return tester.getSize(find.byType(FoodCardWidget));
    }

    expect(
      await cardSizeAt(390),
      Size(AppLayout.collectionCardWidth, AppLayout.collectionCardHeight),
    );
    expect(
      await cardSizeAt(600),
      Size(AppLayout.collectionCardWidth, AppLayout.collectionCardHeight),
    );
  });
}
