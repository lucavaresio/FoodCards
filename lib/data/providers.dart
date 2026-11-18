import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local/storage_service.dart';
import 'repositories/card_repository.dart';
import 'repositories/collection_repository.dart';
import 'repositories/deck_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences non inizializzato');
});

final cardRepositoryProvider = FutureProvider<CardRepository>((ref) async {
  final repository = CardRepository();
  await repository.load();
  return repository;
});

final storageServiceProvider = Provider.family<StorageService, String>((ref, uid) {
  return StorageService(ref.watch(sharedPreferencesProvider), uid: uid);
});

final collectionRepositoryProvider = Provider.family<CollectionRepository, String>((ref, uid) {
  return CollectionRepository(ref.watch(storageServiceProvider(uid)));
});

final deckRepositoryProvider = Provider.family<DeckRepository, String>((ref, uid) {
  return DeckRepository(ref.watch(storageServiceProvider(uid)));
});
