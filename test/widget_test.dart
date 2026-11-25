// ignore_for_file: deprecated_member_use
import 'package:flutter_test/flutter_test.dart';

import 'package:food_cards/app.dart';
import 'package:food_cards/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App opens the home route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWith((ref) {
            final router = createAppRouter(initialLocation: '/home');
            ref.onDispose(router.dispose);
            return router;
          }),
        ],
        child: const App(),
      ),
    );

    expect(find.text('Home'), findsWidgets);
    expect(find.text('In arrivo'), findsOneWidget);
  });
}
