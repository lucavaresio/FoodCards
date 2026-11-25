# Avanzamento FoodCards

## Fasi

| Fase | Stato |
|---|---|
| 6 · Autenticazione e sessione | Fatta |
| 7 · Collezione | Fatta |
| 8 · Shop e apertura pacchetti | Fatta |
| 9 · Crea il tuo deck | Fatta |
| 10 · Motore di gioco | Fatta |
| 11 · Gioco: lobby, partita, esito | Da fare |
| 12 · Home, pacchetto gratuito, profilo e impostazioni | Da fare |
| 13 · Ricettario TheMealDB | Da fare |
| 14 · Rifinitura e preparazione al rilascio | Da fare |

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

## Fase 7 · Collezione

- Stato: fatta; `flutter analyze` pulito e tutti i test verdi.
- File creati: `lib/features/collection/widgets/collection_filter_bar.dart`,
  `lib/features/collection/widgets/card_detail_sheet.dart`,
  `lib/features/dev/dev_tools_sheet.dart`, `test/collection_test.dart`.
- File modificati: `lib/features/collection/collection_controller.dart`,
  `lib/features/collection/collection_screen.dart`,
  `lib/shared/widgets/food_card_widget.dart`,
  `lib/shared/widgets/rarity_chip.dart`,
  `lib/data/repositories/collection_repository.dart`,
  `lib/data/session_providers.dart`, `lib/theme/app_tokens.dart`.
- Scelte: la ricerca accent-insensitive considera solo carte possedute; il
  contatore conta carte uniche e il reset degli strumenti debug rimuove le
  carte senza alterare le monete. Gli strumenti sono disponibili solo in debug.
- Valori provvisori: nessuno aggiunto in questa fase.
- Da fare a mano: nessuno per questa fase.

## Fase 10 · Motore di gioco

- Stato: fatta; analyzer pulito e test deterministici del motore passati.
- File creati: nessuno.
- File modificati: `lib/constants/game_constants.dart`,
  `lib/features/game/engine/battle_engine.dart`,
  `lib/features/game/engine/bot_player.dart`,
  `lib/features/game/engine/game_state.dart`, `test/battle_engine_test.dart`.
- Scelte: lo scontro automatico usa una carta attiva per lato; attacca per
  primo chi ha più velocità (parità al giocatore), infligge almeno 1 danno
  (`attacco - difesa`) e interrompe il round al knockout. Il bot seleziona le
  10 carte col totale statistiche più alto, con ID come spareggio.
- Valori provvisori: le abilità restano descrittive perché il catalogo non
  contiene effetti strutturati; le regole di danno e selezione del bot sono
  baseline da bilanciare.
- Da fare a mano: nessuno per questa fase.

## Fase 9 · Crea il tuo deck

- Stato: fatta; `flutter analyze` pulito e tutti i 53 test passano.
- File creati: `lib/features/deck_builder/deck_edit_screen.dart`,
  `lib/features/deck_builder/widgets/available_cards_list.dart`,
  `lib/features/deck_builder/widgets/dashed_border.dart`,
  `lib/features/deck_builder/widgets/deck_list_tile.dart`,
  `lib/features/deck_builder/widgets/deck_slot.dart`, `test/deck_test.dart`.
- File modificati: `lib/constants/game_constants.dart`,
  `lib/data/repositories/deck_repository.dart`,
  `lib/features/deck_builder/deck_builder_screen.dart`,
  `lib/features/deck_builder/deck_controller.dart`,
  `lib/router/app_router.dart`, `test/data_layer_test.dart`,
  `test/router_test.dart`.
- Scelte: i deck hanno al massimo 10 carte e 10 deck per giocatore; nomi
  univoci senza differenze di maiuscole o spazi esterni. Soltanto deck completi
  possono essere attivati; se il deck attivo diventa incompleto viene
  disattivato. La bozza è mantenuta nell'editor e salvata esplicitamente.
- Valori provvisori: nessuno aggiunto in questa fase.
- Da fare a mano: nessuno per questa fase.

## Fase 8 · Shop e apertura pacchetti

- Stato: fatta; analyzer pulito e tutti i 49 test passano.
- File creati: `lib/features/shop/shop_controller.dart`,
  `lib/features/shop/widgets/pack_tile.dart`,
  `lib/features/shop/widgets/drop_rates_sheet.dart`,
  `lib/features/shop/widgets/pack_wrapper.dart`,
  `lib/features/shop/widgets/card_back.dart`,
  `lib/features/shop/widgets/reveal_stage.dart`,
  `lib/features/shop/widgets/pack_summary_grid.dart`,
  `test/pack_service_test.dart`, `test/shop_test.dart`.
- File modificati: `lib/features/shop/pack_service.dart`,
  `lib/features/shop/shop_screen.dart`,
  `lib/features/shop/pack_opening_screen.dart`,
  `lib/data/repositories/collection_repository.dart`,
  `lib/data/session_providers.dart`, `lib/data/local/storage_service.dart`,
  `lib/shared/widgets/app_scaffold.dart`,
  `lib/shared/widgets/coin_badge.dart`, `lib/theme/app_tokens.dart`,
  `test/router_test.dart`.
- Scelte: i tassi vengono normalizzati sul peso totale; l'acquisto persiste
  saldo e collezione in un singolo record per garantire l'atomicità, leggendo
  anche il vecchio formato per compatibilità. L'apertura senza risultato torna
  allo shop; i tocchi ripetuti sono bloccati dal controller.
- Valori provvisori: drop rates e costi dei pacchetti in `GameConstants`.
- Da fare a mano: nessuno per questa fase.
