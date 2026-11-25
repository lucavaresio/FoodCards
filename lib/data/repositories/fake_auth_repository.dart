import 'dart:async';

import '../models/app_user.dart';
import 'auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Map<String, _FakeAccount> _accounts = {};
  final StreamController<AppUser?> _changes =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;
  int _nextUid = 1;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _changes.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthFailure(AuthFailureCode.wrongCredentials);
    }
    _setCurrentUser(account.user);
  }

  @override
  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalizedEmail)) {
      throw const AuthFailure(AuthFailureCode.invalidEmail);
    }
    if (_accounts.containsKey(normalizedEmail)) {
      throw const AuthFailure(AuthFailureCode.emailInUse);
    }
    if (password.length < 8) {
      throw const AuthFailure(AuthFailureCode.weakPassword);
    }

    final user = AppUser(
      uid: 'fake-${_nextUid++}',
      email: normalizedEmail,
      displayName: displayName.trim(),
      createdAt: _clock().toUtc(),
    );
    _accounts[normalizedEmail] = _FakeAccount(user, password);
    _setCurrentUser(user);
  }

  @override
  Future<void> signOut() async => _setCurrentUser(null);

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _requireUser();
    final updatedUser = user.copyWith(displayName: name.trim());
    _accounts[user.email.toLowerCase()]!.user = updatedUser;
    _setCurrentUser(updatedUser);
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _requireUser();
    final account = _accounts[user.email.toLowerCase()]!;
    if (account.password != currentPassword) {
      throw const AuthFailure(AuthFailureCode.wrongCredentials);
    }
    if (newPassword.length < 8) {
      throw const AuthFailure(AuthFailureCode.weakPassword);
    }
    account.password = newPassword;
  }

  @override
  Future<void> deleteAccount(String password) async {
    final user = _requireUser();
    final account = _accounts[user.email.toLowerCase()]!;
    if (account.password != password) {
      throw const AuthFailure(AuthFailureCode.wrongCredentials);
    }
    _accounts.remove(user.email.toLowerCase());
    _setCurrentUser(null);
  }

  void dispose() => _changes.close();

  AppUser _requireUser() {
    final user = _currentUser;
    if (user == null) throw const AuthFailure(AuthFailureCode.unknown);
    return user;
  }

  void _setCurrentUser(AppUser? user) {
    _currentUser = user;
    if (!_changes.isClosed) _changes.add(user);
  }
}

class _FakeAccount {
  _FakeAccount(this.user, this.password);

  AppUser user;
  String password;
}
