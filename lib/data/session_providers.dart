import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/app_user.dart';
import 'models/deck.dart';
import 'providers.dart';
import 'repositories/auth_repository.dart';
import 'repositories/collection_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final sessionProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(sessionProvider).value?.uid;
});

class PlayerCollectionState {
  const PlayerCollectionState({required this.coins, required this.owned});

  const PlayerCollectionState.empty() : coins = 0, owned = const {};

  final int coins;
  final Map<String, int> owned;

  int quantityOf(String cardId) => owned[cardId] ?? 0;
}

final playerCollectionProvider =
    NotifierProvider<
      PlayerCollectionNotifier,
      AsyncValue<PlayerCollectionState>
    >(PlayerCollectionNotifier.new);

class PlayerCollectionNotifier
    extends Notifier<AsyncValue<PlayerCollectionState>> {
  String? _uid;
  CollectionRepository? _repository;

  @override
  AsyncValue<PlayerCollectionState> build() {
    _uid = ref.watch(currentUidProvider);
    final uid = _uid;
    if (uid == null) {
      _repository = null;
      return const AsyncData(PlayerCollectionState.empty());
    }

    final repository = ref.watch(collectionRepositoryProvider(uid));
    _repository = repository;
    Future<void>.microtask(() => _load(uid, repository));
    return const AsyncLoading();
  }

  Future<void> addCards(List<String> cardIds) async {
    final repository = _requireRepository();
    await repository.addCards(cardIds);
    state = AsyncData(_snapshot(repository));
  }

  Future<void> addCoins(int amount) async {
    final repository = _requireRepository();
    await repository.addCoins(amount);
    state = AsyncData(_snapshot(repository));
  }

  Future<bool> spendCoins(int amount) async {
    final repository = _requireRepository();
    final success = await repository.spendCoins(amount);
    state = AsyncData(_snapshot(repository));
    return success;
  }

  Future<void> _load(String uid, CollectionRepository repository) async {
    try {
      await repository.initializeForNewUser();
      if (!ref.mounted || _uid != uid) return;
      state = AsyncData(_snapshot(repository));
    } catch (error, stackTrace) {
      if (!ref.mounted || _uid != uid) return;
      state = AsyncError(error, stackTrace);
    }
  }

  CollectionRepository _requireRepository() {
    final repository = _repository;
    if (repository == null || state.value == null) {
      throw StateError('Collezione non ancora caricata');
    }
    return repository;
  }

  PlayerCollectionState _snapshot(CollectionRepository repository) =>
      PlayerCollectionState(coins: repository.coins, owned: repository.owned);
}

final playerDecksProvider = FutureProvider.family<List<Deck>, String>((
  ref,
  uid,
) async {
  final repository = ref.watch(deckRepositoryProvider(uid));
  await repository.load();
  return repository.decks;
});

final coinsProvider = Provider<int?>((ref) {
  if (ref.watch(currentUidProvider) == null) return null;
  return ref.watch(playerCollectionProvider).value?.coins;
});

final appReadyProvider = Provider<AsyncValue<bool>>((ref) {
  final session = ref.watch(sessionProvider);
  if (session.isLoading) return const AsyncLoading<bool>();
  if (session.hasError) {
    return AsyncError<bool>(session.error!, session.stackTrace!);
  }

  final user = session.value;
  if (user == null) return const AsyncData<bool>(true);

  final collection = ref.watch(playerCollectionProvider);
  final decks = ref.watch(playerDecksProvider(user.uid));
  if (collection.hasError) {
    return AsyncError<bool>(collection.error!, collection.stackTrace!);
  }
  if (decks.hasError) {
    return AsyncError<bool>(decks.error!, decks.stackTrace!);
  }
  if (collection.isLoading || decks.isLoading) {
    return const AsyncLoading<bool>();
  }
  return const AsyncData<bool>(true);
});

final routerRefreshListenableProvider = Provider<ChangeNotifier>((ref) {
  final refresh = RouterRefreshListenable();
  ref.listen(sessionProvider, (previous, next) => refresh.refresh());
  ref.listen(appReadyProvider, (previous, next) => refresh.refresh());
  ref.onDispose(refresh.dispose);
  return refresh;
});

class RouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}
