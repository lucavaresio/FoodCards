// ignore_for_file: deprecated_member_use
import 'package:flutter_test/flutter_test.dart';

import 'package:food_cards/app.dart';

void main() {
  testWidgets('Theme preview smoke test', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('FoodCards — Theme Preview'), findsOneWidget);
  });
}
