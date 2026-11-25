import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/app.dart';
import 'package:food_cards/data/providers.dart';
import 'package:food_cards/data/repositories/fake_auth_repository.dart';
import 'package:food_cards/data/session_providers.dart';
import 'package:food_cards/router/app_router.dart';
import 'package:food_cards/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('la Home apre il pacchetto giornaliero gratuito', (tester) async {
    final (auth, preferences) = await _dependencies();
    addTearDown(auth.dispose);
    await _pumpApp(tester, preferences, auth, AppRoutes.home);
    await tester.pumpAndSettle();

    expect(find.text('Ciao, Chef Luca!'), findsOneWidget);
    await tester.tap(find.text('Ritira il regalo'));
    await tester.pumpAndSettle();

    expect(find.text('Carta 1 di 3'), findsOneWidget);
  });

  testWidgets('le impostazioni aggiornano nome profilo e tema', (tester) async {
    final (auth, preferences) = await _dependencies();
    addTearDown(auth.dispose);
    await _pumpApp(tester, preferences, auth, AppRoutes.settings);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Chef Nuovo');
    await tester.tap(find.text('Salva profilo'));
    await tester.pumpAndSettle();
    expect(auth.currentUser?.displayName, 'Chef Nuovo');

    await tester.tap(find.text('Scuro').last);
    await tester.pumpAndSettle();
    expect(preferences.getString('theme_mode'), 'dark');
  });
}

Future<(FakeAuthRepository, SharedPreferences)> _dependencies() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();
  final auth = FakeAuthRepository();
  await auth.register('luca@example.com', 'Password123', 'Chef Luca');
  return (auth, preferences);
}

Future<void> _pumpApp(
  WidgetTester tester,
  SharedPreferences preferences,
  FakeAuthRepository auth,
  String location,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        authRepositoryProvider.overrideWithValue(auth),
        appRouterProvider.overrideWith((ref) {
          final router = createAppRouter(initialLocation: location);
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: const App(),
    ),
  );
  await tester.pump();
}
