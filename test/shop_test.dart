import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/data/providers.dart';
import 'package:food_cards/data/repositories/fake_auth_repository.dart';
import 'package:food_cards/data/session_providers.dart';
import 'package:food_cards/features/shop/pack_opening_screen.dart';
import 'package:food_cards/features/shop/shop_screen.dart';
import 'package:food_cards/router/app_routes.dart';
import 'package:food_cards/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('lo shop mostra i cinque pacchetti disponibili', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final auth = FakeAuthRepository();
    await auth.register('shop@example.com', 'password123', 'Shop');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(theme: lightTheme(), home: const ShopScreen()),
      ),
    );
    await tester.pumpAndSettle();
    for (final name in [
      'Snack Pack',
      'Tasty Pack',
      'Gourmet Pack',
      "Chef's Selection",
      'Legendary Feast',
    ]) {
      await tester.scrollUntilVisible(
        find.text(name),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(name), findsOneWidget);
    }
    auth.dispose();
  });

  testWidgets('apertura senza risultato torna allo shop', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.packOpening,
      routes: [
        GoRoute(
          path: AppRoutes.packOpening,
          builder: (_, _) => const PackOpeningScreen(),
        ),
        GoRoute(
          path: AppRoutes.shop,
          builder: (_, _) => const Scaffold(body: Text('Shop test')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Shop test'), findsOneWidget);
    router.dispose();
  });
}
