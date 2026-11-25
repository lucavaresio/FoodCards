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
  testWidgets('ogni rotta viene costruita', (tester) async {
    const locations = [
      AppRoutes.home,
      AppRoutes.collection,
      AppRoutes.deck,
      '/deck/edit/test-deck',
      AppRoutes.game,
      AppRoutes.shop,
      AppRoutes.packOpening,
      AppRoutes.match,
      AppRoutes.settings,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.gallery,
    ];

    for (final location in locations) {
      await _pumpAppAt(tester, location);
      expect(tester.takeException(), isNull, reason: location);
    }
  });

  testWidgets('splash mostra logo e stato di verifica sessione', (
    tester,
  ) async {
    await _pumpAppAt(tester, AppRoutes.splash);
    expect(find.bySemanticsLabel('Logo FoodCards'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('le cinque destinazioni aggiornano la scheda selezionata', (
    tester,
  ) async {
    await _pumpAppAt(tester, AppRoutes.home);
    const labels = ['Home', 'Collezione', 'Mazzi', 'Gioco', 'Negozio'];

    for (var index = 0; index < labels.length; index++) {
      await tester.tap(find.text(labels[index]).last);
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        index,
      );
    }
  });

  testWidgets('sottorotte a schermo intero non mostrano la barra', (
    tester,
  ) async {
    for (final location in [AppRoutes.match, AppRoutes.settings]) {
      await _pumpAppAt(tester, location);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing, reason: location);
    }
  });

  testWidgets('una rotta inesistente mostra la pagina di errore', (
    tester,
  ) async {
    await _pumpAppAt(tester, '/pagina-sconosciuta');
    expect(find.text('Pagina non trovata'), findsOneWidget);

    await tester.tap(find.text('Torna alla Home'));
    await tester.pumpAndSettle();
    expect(find.text('In arrivo'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('indietro da una sottorotta torna alla scheda madre', (
    tester,
  ) async {
    await _pumpAppAt(tester, AppRoutes.packOpening);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      4,
    );
  });
}

Future<void> _pumpAppAt(WidgetTester tester, String location) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        authRepositoryProvider.overrideWith((ref) {
          final auth = FakeAuthRepository();
          ref.onDispose(auth.dispose);
          return auth;
        }),
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
