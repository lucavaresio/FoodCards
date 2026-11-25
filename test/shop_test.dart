import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/repositories/card_repository.dart';
import 'package:food_cards/data/providers.dart';
import 'package:food_cards/data/repositories/fake_auth_repository.dart';
import 'package:food_cards/data/session_providers.dart';
import 'package:food_cards/features/shop/pack_opening_screen.dart';
import 'package:food_cards/features/shop/pack_service.dart';
import 'package:food_cards/features/shop/shop_controller.dart';
import 'package:food_cards/features/shop/shop_screen.dart';
import 'package:food_cards/features/shop/widgets/pack_summary_grid.dart';
import 'package:food_cards/features/shop/widgets/pack_wrapper.dart';
import 'package:food_cards/features/shop/widgets/reveal_stage.dart';
import 'package:food_cards/router/app_routes.dart';
import 'package:food_cards/theme/app_theme.dart';
import 'package:food_cards/theme/app_tokens.dart';
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
    expect(tester.takeException(), isNull);
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

  testWidgets('apre il pacco una volta e mostra una carta per tocco', (
    tester,
  ) async {
    final catalog = CardRepository();
    await catalog.load();
    final cards = catalog.all.take(3).toList();
    final result = PackDrawResult(
      pack: GameConstants.packs.first,
      cards: cards,
      newCardIds: {for (final card in cards) card.id},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pendingPackOpeningProvider.overrideWith(
            () => _PendingPackOpeningNotifier(result),
          ),
          coinsProvider.overrideWithValue(0),
        ],
        child: MaterialApp(
          theme: lightTheme(),
          home: const PackOpeningScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PackWrapper), findsOneWidget);

    await tester.tap(find.byType(PackWrapper));
    await tester.pump();
    await tester.pump(AppDuration.splash);
    await tester.pumpAndSettle();

    expect(find.byType(PackWrapper), findsNothing);
    expect(find.text('Carta 1 di 3'), findsOneWidget);
    for (var index = 2; index <= cards.length; index++) {
      await tester.tap(find.byType(RevealStage));
      await tester.pumpAndSettle();
      expect(find.byType(PackWrapper), findsNothing);
      expect(find.text('Carta $index di ${cards.length}'), findsOneWidget);
    }

    await tester.tap(find.byType(RevealStage));
    await tester.pumpAndSettle();
    expect(find.byType(PackWrapper), findsNothing);
    expect(find.byType(PackSummaryGrid), findsOneWidget);
    expect(find.text('Ecco le tue carte!'), findsOneWidget);
  });
}

class _PendingPackOpeningNotifier extends PendingPackOpening {
  _PendingPackOpeningNotifier(this.result);

  final PackDrawResult result;

  @override
  PackDrawResult? build() => result;
}
