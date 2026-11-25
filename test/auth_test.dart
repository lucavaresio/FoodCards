import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/app.dart';
import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/local/storage_service.dart';
import 'package:food_cards/data/providers.dart';
import 'package:food_cards/data/repositories/auth_repository.dart';
import 'package:food_cards/data/repositories/collection_repository.dart';
import 'package:food_cards/data/repositories/fake_auth_repository.dart';
import 'package:food_cards/data/session_providers.dart';
import 'package:food_cards/features/auth/auth_controller.dart';
import 'package:food_cards/features/auth/auth_error_messages.dart';
import 'package:food_cards/features/auth/auth_validators.dart';
import 'package:food_cards/features/auth/login_screen.dart';
import 'package:food_cards/shared/widgets/sticker_text_field.dart';
import 'package:food_cards/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('validatori di autenticazione', () {
    test('email trim, formato, password e conferma', () {
      expect(validateEmail('  mario@example.com  '), isNull);
      expect(validateEmail('mario@'), isNotNull);
      expect(validatePassword('a' * 8), isNull);
      expect(validatePassword('a' * 7), isNotNull);
      expect(validatePassword('a' * 65), isNotNull);
      expect(validatePasswordConfirmation('secret', 'secret'), isNull);
      expect(validatePasswordConfirmation('wrong', 'secret'), isNotNull);
    });

    test('nome utente rifiuta spazi e applica i limiti', () {
      expect(validateDisplayName('   '), isNotNull);
      expect(validateDisplayName('Al'), isNotNull);
      expect(validateDisplayName('Mario'), isNull);
      expect(validateDisplayName('a' * 21), isNotNull);
    });

    test('messaggi non rivelano se l’email esiste', () {
      expect(
        authErrorMessage(const AuthFailure(AuthFailureCode.wrongCredentials)),
        'Email o password non corretti.',
      );
      expect(
        passwordResetConfirmation,
        'Se l’email è registrata, riceverai un link.',
      );
    });
  });

  group('FakeAuthRepository', () {
    late FakeAuthRepository auth;

    setUp(() {
      auth = FakeAuthRepository(clock: () => DateTime.utc(2026, 1, 2));
    });

    tearDown(() => auth.dispose());

    test('registra, esce e rientra con identità persistente', () async {
      await auth.register('mario@example.com', 'password123', 'Mario');
      final registered = auth.currentUser!;
      expect(registered.displayName, 'Mario');

      await auth.signOut();
      expect(auth.currentUser, isNull);

      await auth.signIn('mario@example.com', 'password123');
      expect(auth.currentUser, registered);
      expect(auth.currentUser!.createdAt, DateTime.utc(2026, 1, 2));
    });

    test('credenziali errate usano un errore generico', () async {
      await expectLater(
        auth.signIn('inesistente@example.com', 'password123'),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            AuthFailureCode.wrongCredentials,
          ),
        ),
      );
    });
  });

  test('registrazione inizializza i dati e due account sono isolati', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final auth = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(auth.dispose);

    final controller = container.read(authControllerProvider.notifier);
    await controller.register('primo@example.com', 'password123', 'Primo');
    final firstUid = auth.currentUser!.uid;
    final firstCollection = container.read(
      collectionRepositoryProvider(firstUid),
    );
    expect(firstCollection.coins, GameConstants.startingCoins);

    await firstCollection.addCoins(37);
    await controller.signOut();
    await controller.register('secondo@example.com', 'password123', 'Secondo');
    final secondUid = auth.currentUser!.uid;
    final secondCollection = container.read(
      collectionRepositoryProvider(secondUid),
    );
    expect(secondUid, isNot(firstUid));
    expect(secondCollection.coins, GameConstants.startingCoins);

    await controller.signOut();
    await controller.signIn('primo@example.com', 'password123');
    await firstCollection.load();
    expect(firstCollection.coins, GameConstants.startingCoins + 37);
  });

  test('initializeForNewUser non sovrascrive i dati esistenti', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = CollectionRepository(
      StorageService(preferences, uid: 'existing'),
    );
    await repository.initializeForNewUser();
    await repository.addCoins(20);

    await repository.initializeForNewUser();
    expect(repository.coins, GameConstants.startingCoins + 20);
  });

  testWidgets('login valida i campi e mostra errori generici', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final auth = FakeAuthRepository();

    await tester.pumpWidget(_loginApp(auth, preferences));
    await tester.tap(find.text('ACCEDI'));
    await tester.pumpAndSettle();
    expect(find.text('Inserisci un indirizzo email valido'), findsOneWidget);

    await tester.enterText(
      find.byType(StickerTextField).first,
      'inesistente@example.com',
    );
    await tester.enterText(find.byType(StickerTextField).last, 'password123');
    await tester.tap(find.text('ACCEDI'));
    await tester.pumpAndSettle();
    expect(find.text('Email o password non corretti.'), findsOneWidget);
    auth.dispose();
  });

  testWidgets('login espone lo stato di caricamento', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final auth = _DelayedAuthRepository();
    await auth.register('mario@example.com', 'password123', 'Mario');
    await auth.signOut();

    await tester.pumpWidget(_loginApp(auth, preferences));
    await tester.enterText(
      find.byType(StickerTextField).first,
      'mario@example.com',
    );
    await tester.enterText(find.byType(StickerTextField).last, 'password123');
    await tester.tap(find.text('ACCEDI'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    auth.signInGate.complete();
    await tester.pumpAndSettle();
    auth.dispose();
  });

  testWidgets(
    'il router porta alla login senza sessione e alla home dopo login',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final auth = FakeAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            authRepositoryProvider.overrideWithValue(auth),
          ],
          child: const App(),
        ),
      );

      for (var attempt = 0; attempt < 8; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Accedi'), findsOneWidget);

      await auth.register('mario@example.com', 'password123', 'Mario');
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsWidgets);

      auth.dispose();
    },
  );
}

Widget _loginApp(FakeAuthRepository auth, SharedPreferences preferences) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      sharedPreferencesProvider.overrideWithValue(preferences),
    ],
    child: MaterialApp(
      theme: lightTheme(),
      darkTheme: darkTheme(),
      home: const LoginScreen(),
    ),
  );
}

class _DelayedAuthRepository extends FakeAuthRepository {
  final Completer<void> signInGate = Completer<void>();

  @override
  Future<void> signIn(String email, String password) async {
    await signInGate.future;
    await super.signIn(email, password);
  }
}
