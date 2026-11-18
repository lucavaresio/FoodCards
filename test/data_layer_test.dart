import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/local/storage_service.dart';
import 'package:food_cards/data/models/deck.dart';
import 'package:food_cards/data/models/rarity.dart';
import 'package:food_cards/data/repositories/card_repository.dart';
import 'package:food_cards/data/repositories/collection_repository.dart';
import 'package:food_cards/data/repositories/deck_repository.dart';

class _TestBundle extends CachingAssetBundle {
  _TestBundle(this.source);
  final String source;

  @override
  Future<String> loadString(String key, {bool cache = true}) async => source;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(source));
    return ByteData.view(bytes.buffer);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('cards.json', () {
    late List<dynamic> cards;

    setUp(() {
      cards = jsonDecode(File('assets/cards.json').readAsStringSync()) as List<dynamic>;
    });

    test('100 carte, set e rarità', () {
      expect(cards.length, 100);
      expect(cards.map((item) => item['id']).toSet().length, 100);

      const sets = ['Piccante', 'Dolce', 'Frutta', 'Verdura', 'Fast Food'];
      for (final set in sets) {
        final setCards = cards.where((item) => item['cardSet'] == set).toList();
        expect(setCards.length, 20);
        for (final entry in {
          'common': 7,
          'uncommon': 5,
          'rare': 4,
          'epic': 3,
          'legendary': 1,
        }.entries) {
          expect(setCards.where((item) => item['rarity'] == entry.key).length, entry.value);
        }
      }

      for (final entry in {
        'common': 35,
        'uncommon': 25,
        'rare': 20,
        'epic': 15,
        'legendary': 5,
      }.entries) {
        expect(cards.where((item) => item['rarity'] == entry.key).length, entry.value);
      }
    });

    test('immagini, testi e fasce statistiche', () {
      final usedImages = <String>{};
      final ranges = {
        'common': {'health': [3, 4], 'attack': [1, 3], 'defense': [0, 1], 'speed': [1, 3]},
        'uncommon': {'health': [4, 5], 'attack': [2, 4], 'defense': [1, 2], 'speed': [2, 4]},
        'rare': {'health': [5, 6], 'attack': [3, 5], 'defense': [2, 3], 'speed': [3, 5]},
        'epic': {'health': [6, 8], 'attack': [4, 6], 'defense': [3, 4], 'speed': [4, 6]},
        'legendary': {'health': [8, 10], 'attack': [6, 8], 'defense': [4, 5], 'speed': [5, 7]},
      };

      for (final item in cards) {
        final rarity = item['rarity'] as String;
        for (final stat in ['health', 'attack', 'defense', 'speed']) {
          final value = item[stat] as int;
          final limits = ranges[rarity]![stat]!;
          expect(value >= limits[0] && value <= limits[1], isTrue, reason: '${item['id']} $stat');
        }

        final image = item['image'] as String;
        usedImages.add(image);
        expect(File('assets/images/cards/$image').existsSync(), isTrue, reason: image);
        expect((item['abilityName'] as String).isNotEmpty, isTrue);
        expect((item['abilityName'] as String).length <= 20, isTrue);
        expect((item['description'] as String).isNotEmpty, isTrue);
        expect((item['description'] as String).length <= 60, isTrue);
      }

      final folderImages = Directory('assets/images/cards')
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .where((name) => name.endsWith('.png'))
          .toSet();
      expect(usedImages, folderImages);
    });
  });

  group('StorageService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await SharedPreferences.getInstance();
    });

    test('isola gli utenti e legge JSON corrotti', () async {
      final prefs = await SharedPreferences.getInstance();
      final first = StorageService(prefs, uid: 'user-a');
      final second = StorageService(prefs, uid: 'user-b');

      await first.writeInt('coins', 300);
      await second.writeInt('coins', 700);
      expect(first.readInt('coins'), 300);
      expect(second.readInt('coins'), 700);

      await first.writeString('bad_json', '{corrotto');
      expect(first.readJson('bad_json'), isNull);
      expect(first.readJsonList('bad_json'), isNull);

      await first.clearUserData();
      expect(first.readInt('coins'), isNull);
      expect(second.readInt('coins'), 700);
    });
  });

  group('CollectionRepository', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('inizializza una sola volta e gestisce carte e monete', () async {
      final prefs = await SharedPreferences.getInstance();
      final collection = CollectionRepository(StorageService(prefs, uid: 'user-a'));

      await collection.initializeForNewUser();
      expect(collection.coins, GameConstants.startingCoins);

      await collection.initializeForNewUser();
      expect(collection.coins, GameConstants.startingCoins);

      await collection.addCards(['pizza', 'pizza', 'tacos']);
      expect(collection.quantityOf('pizza'), 2);
      expect(collection.quantityOf('tacos'), 1);

      expect(await collection.spendCoins(100), isTrue);
      expect(collection.coins, GameConstants.startingCoins - 100);
      expect(await collection.spendCoins(999999), isFalse);
      expect(() => collection.spendCoins(0), throwsA(isA<ArgumentError>()));
      expect(() => collection.spendCoins(-10), throwsA(isA<ArgumentError>()));

      final recreated = CollectionRepository(StorageService(prefs, uid: 'user-a'));
      await recreated.load();
      expect(recreated.coins, collection.coins);
      expect(recreated.owned, collection.owned);
    });

    test('due utenti hanno monete separate', () async {
      final prefs = await SharedPreferences.getInstance();
      final a = CollectionRepository(StorageService(prefs, uid: 'a'));
      final b = CollectionRepository(StorageService(prefs, uid: 'b'));
      await a.initializeForNewUser();
      await b.initializeForNewUser();

      await a.spendCoins(200);
      expect(a.coins, 300);
      expect(b.coins, 500);
    });
  });

  group('DeckRepository', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('salva, aggiorna, elimina e azzera deck attivo', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = DeckRepository(StorageService(prefs, uid: 'decks'));
      await repository.load();

      await repository.save(Deck(id: 'd1', name: 'Primo', cardIds: const ['a']));
      await repository.setActiveDeck('d1');
      expect(repository.byId('d1')?.name, 'Primo');
      expect(repository.activeDeckId, 'd1');

      await repository.save(Deck(id: 'd1', name: 'Aggiornato', cardIds: const ['a', 'b']));
      expect(repository.byId('d1')?.name, 'Aggiornato');

      await repository.delete('d1');
      expect(repository.byId('d1'), isNull);
      expect(repository.activeDeckId, isNull);

      final recreated = DeckRepository(StorageService(prefs, uid: 'decks'));
      await recreated.load();
      expect(recreated.decks, isEmpty);
      expect(recreated.activeDeckId, isNull);
    });

    test('rifiuta nomi non validi', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = DeckRepository(StorageService(prefs, uid: 'names'));

      expect(() => repository.save(Deck(id: 'empty', name: ' ', cardIds: const [])), throwsA(isA<ArgumentError>()));
      expect(
        () => repository.save(Deck(id: 'long', name: 'x' * (GameConstants.maxDeckNameLength + 1), cardIds: const [])),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CardRepository', () {
    test('ricerca carte dal catalogo reale', () async {
      final repository = CardRepository();
      await repository.load();

      expect(repository.all.length, 100);
      expect(repository.byId('pizza_margherita')?.name, 'Pizza Margherita');
      expect(() => repository.requireById('inesistente'), throwsStateError);
      expect(repository.byRarity(Rarity.legendary).length, 5);
    });

    test('rileva ID duplicati nel bundle fittizio', () async {
      const duplicate = '[{"id":"x","name":"X","rarity":"common","element":"acqua","health":3,"attack":1,"defense":0,"speed":1,"abilityName":"Prova","description":"Carta di prova.","cardSet":"Frutta","image":"x.png"},{"id":"x","name":"X2","rarity":"rare","element":"acqua","health":5,"attack":3,"defense":2,"speed":3,"abilityName":"Prova2","description":"Seconda carta.","cardSet":"Frutta","image":"x.png"}]';
      final repository = CardRepository(bundle: _TestBundle(duplicate));
      await expectLater(repository.load(), throwsA(isA<FormatException>()));
    });
  });
}
