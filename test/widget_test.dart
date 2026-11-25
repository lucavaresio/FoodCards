// ignore_for_file: deprecated_member_use
import 'package:flutter_test/flutter_test.dart';

import 'package:food_cards/app.dart';
import 'package:food_cards/data/providers.dart';
import 'package:food_cards/data/repositories/fake_auth_repository.dart';
import 'package:food_cards/data/session_providers.dart';
import 'package:food_cards/router/app_router.dart';
import 'package:food_cards/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App opens the home route', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final auth = FakeAuthRepository();
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(auth),
          appRouterProvider.overrideWith((ref) {
            final router = createAppRouter(initialLocation: AppRoutes.home);
            ref.onDispose(router.dispose);
            return router;
          }),
        ],
        child: const App(),
      ),
    );

    expect(find.text('Home'), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Accedi per continuare'), findsOneWidget);
  });
}
