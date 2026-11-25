import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_user.dart';
import '../../data/providers.dart';
import '../../data/session_providers.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> signIn(String email, String password) => _run(() async {
    await ref.read(authRepositoryProvider).signIn(email.trim(), password);
    await _initializeCurrentUser();
  });

  Future<void> register(String email, String password, String displayName) =>
      _run(() async {
        await ref
            .read(authRepositoryProvider)
            .register(email.trim(), password, displayName.trim());
        await _initializeCurrentUser();
      });

  Future<void> signOut() => _run(ref.read(authRepositoryProvider).signOut);

  Future<void> sendPasswordReset(String email) => _run(
    () => ref.read(authRepositoryProvider).sendPasswordReset(email.trim()),
  );

  Future<void> updateDisplayName(String name) => _run(
    () => ref.read(authRepositoryProvider).updateDisplayName(name.trim()),
  );

  Future<void> changePassword(String currentPassword, String newPassword) =>
      _run(
        () => ref
            .read(authRepositoryProvider)
            .changePassword(currentPassword, newPassword),
      );

  Future<void> deleteAccount(String password) => _run(() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw StateError('Nessuna sessione attiva');
    await ref.read(authRepositoryProvider).deleteAccount(password);
    final storage = ref.read(storageServiceProvider(user.uid));
    await storage.clearUserData();
  });

  Future<void> _initializeCurrentUser() async {
    final AppUser? user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw StateError('Autenticazione senza utente corrente');
    await ref
        .read(collectionRepositoryProvider(user.uid))
        .initializeForNewUser();
    await ref.read(deckRepositoryProvider(user.uid)).load();
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading<void>();
    try {
      await action();
      state = const AsyncData<void>(null);
    } catch (error, stackTrace) {
      state = AsyncError<void>(error, stackTrace);
      rethrow;
    }
  }
}
