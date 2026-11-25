import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/providers.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/fake_auth_repository.dart';
import 'data/session_providers.dart';
import 'firebase_options.dart';

const _useFakeAuth = bool.fromEnvironment('USE_FAKE_AUTH');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final preferences = await SharedPreferences.getInstance();

  late final AuthRepository authRepository;
  if (_useFakeAuth) {
    authRepository = FakeAuthRepository();
  } else {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      authRepository = FirebaseAuthRepository();
    } on Object catch (error) {
      if (!kDebugMode) {
        runApp(const FirebaseSetupErrorApp());
        return;
      }
      debugPrint(
        'Configurazione Firebase non disponibile (${error.runtimeType}); '
        'uso l’autenticazione finta in debug.',
      );
      authRepository = FakeAuthRepository();
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: const App(),
    ),
  );
}
