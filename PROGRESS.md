# Avanzamento FoodCards

## Fasi

| Fase | Stato |
|---|---|
| 6 · Autenticazione e sessione | Fatta |
| 7 · Collezione | Da fare |
| 8 · Shop e apertura pacchetti | Da fare |
| 9 · Crea il tuo deck | Da fare |
| 10 · Motore di gioco | Da fare |
| 11 · Gioco: lobby, partita, esito | Da fare |
| 12 · Home, pacchetto gratuito, profilo e impostazioni | Da fare |
| 13 · Rifinitura e preparazione al rilascio | Da fare |

## Fase 6 · Autenticazione e sessione

- Stato: fatta; analyzer, suite test e avvio debug su emulatore verificati.
- File creati: `lib/data/session_providers.dart`,
  `lib/data/repositories/fake_auth_repository.dart`,
  `lib/features/auth/auth_validators.dart`,
  `lib/features/auth/auth_error_messages.dart`,
  `lib/features/auth/widgets/auth_header.dart`,
  `lib/features/auth/widgets/auth_error_banner.dart`,
  `lib/firebase_options.dart`, `test/auth_test.dart`.
- File modificati: `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`,
  `lib/app.dart`, `lib/router/app_router.dart`,
  `lib/data/repositories/auth_repository.dart`,
  `lib/features/auth/auth_controller.dart`,
  `lib/features/auth/login_screen.dart`,
  `lib/features/auth/register_screen.dart`,
  `lib/features/auth/forgot_password_screen.dart`,
  `lib/features/home/home_screen.dart`, `lib/features/splash_screen.dart`,
  `lib/shared/widgets/app_scaffold.dart`,
  `lib/shared/widgets/placeholder_content.dart`,
  `lib/shared/widgets/sticker_button.dart`,
  `lib/shared/widgets/sticker_text_field.dart`, `lib/theme/app_tokens.dart`,
  `test/router_test.dart`.
- Scelte: `FakeAuthRepository` usa memoria volatile; in debug Firebase non
  configurato seleziona il fake, mentre in release mostra una schermata
  esplicita. `firebase_options.dart` è uno stub che richiede
  `flutterfire configure`. Lo stato collezione è legato all'uid e viene
  inizializzato idempotentemente dopo login e registrazione.
- Valori provvisori: account del fake persi al riavvio; nessuna chiave Firebase
  è inclusa.
- Da fare a mano: creare/configurare Firebase, abilitare Email/Password,
  eseguire `flutterfire configure` e sostituire lo stub; cambiare gli
  identificativi Android/iOS attualmente `com.example...`.

## Da fare a mano

- Configurazione Firebase e provider Email/Password.
- Identificativi Android/iOS: rimuovere `com.example...` prima del rilascio.
- Eseguire `flutterfire configure` e generare opzioni reali senza committare
  credenziali segrete.
- Per il fake in modo esplicito: `--dart-define=USE_FAKE_AUTH=true`.
