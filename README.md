# FoodCards

FoodCards è un gioco Flutter di carte collezionabili a tema cibo. L’app
include autenticazione, collezione, mazzi, partite automatiche, pacchetti e un
ricettario basato su TheMealDB. L’interfaccia è in italiano e supporta tema
chiaro/scuro.

## Requisiti e avvio

Servono Flutter e Dart compatibili con i vincoli in `pubspec.yaml`.

```shell
flutter pub get
flutter run
```

Controlli locali:

```shell
flutter analyze
flutter test
```

Per provare l’autenticazione finta in memoria in debug:

```shell
flutter run --dart-define=USE_FAKE_AUTH=true
```

Gli account del repository fake vengono persi quando l’app viene riavviata.

## Firebase

La configurazione inclusa in `lib/firebase_options.dart` è uno stub: per usare
Firebase Auth occorre configurare un progetto Firebase, abilitare il provider
Email/Password ed eseguire `flutterfire configure`. Non inserire chiavi di
account di servizio o altri segreti nel repository. Le regole e la
configurazione Firebase effettive dipendono dal progetto scelto.

## Dati e servizi esterni

- Firebase Auth gestisce l’account, l’indirizzo email e il nome profilo.
- Collezione, mazzi, statistiche e saldo di gioco sono memorizzati localmente
  sul dispositivo, con chiavi separate per utente. La preferenza del tema è
  locale al dispositivo.
- Le schermate del ricettario fanno richieste HTTPS a TheMealDB; le immagini e
  i dati delle ricette provengono dal servizio. Le richieste dell’app non
  includono intenzionalmente email o credenziali.
- Nelle impostazioni, l’utente può richiedere l’eliminazione dell’account
  confermando la password. L’app elimina l’account Firebase e i dati locali
  associati all’UID. La cancellazione Firebase può richiedere un accesso
  recente.

TheMealDB viene usato tramite la chiave pubblica `1` per sviluppo. Prima di
distribuire l’app, verificare i termini correnti del servizio e configurare
un’eventuale chiave commerciale richiesta. Attribuzione e condizioni:
[TheMealDB API](https://www.themealdb.com/api.php).

## Build e pubblicazione

Per generare un APK Android:

```shell
flutter build apk --release
```

Il repository non contiene una chiave di firma Android: il comando genera un
APK non firmato, da configurare con una firma release privata prima di poterlo
installare o distribuire. Anche i bundle ID, la firma Apple, la configurazione
Firebase, le icone e una privacy policy pubblica devono essere verificati e
completati per la distribuzione.

L’identificativo `com.lucavaresio.foodcards` è stato impostato per le
piattaforme native, ma va considerato provvisorio finché non viene confermata
la titolarità e la disponibilità per la pubblicazione.
