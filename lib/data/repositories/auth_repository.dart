import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

enum AuthFailureCode {
  invalidEmail,
  wrongCredentials,
  emailInUse,
  weakPassword,
  network,
  tooManyRequests,
  requiresRecentLogin,
  userDisabled,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthFailureCode code;

  @override
  String toString() => 'AuthFailure(${code.name})';
}

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<void> signIn(String email, String password);

  Future<void> register(String email, String password, String displayName);

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);

  Future<void> updateDisplayName(String name);

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<void> deleteAccount(String password);
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository([FirebaseAuth? auth])
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<AppUser?> authStateChanges() => _auth.userChanges().map(_mapUser);

  @override
  AppUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Future<void> signIn(String email, String password) => _run(() async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  });

  @override
  Future<void> register(String email, String password, String displayName) =>
      _run(() async {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = credential.user;
        if (user == null) throw const AuthFailure(AuthFailureCode.unknown);
        await user.updateDisplayName(displayName.trim());
      });

  @override
  Future<void> signOut() => _run(_auth.signOut);

  @override
  Future<void> sendPasswordReset(String email) =>
      _run(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> updateDisplayName(String name) => _run(() async {
    final user = _requireUser();
    await user.updateDisplayName(name.trim());
  });

  @override
  Future<void> changePassword(String currentPassword, String newPassword) =>
      _run(() async {
        final user = _requireUser();
        final email = user.email;
        if (email == null || email.isEmpty) {
          throw const AuthFailure(AuthFailureCode.unknown);
        }
        final credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      });

  @override
  Future<void> deleteAccount(String password) => _run(() async {
    final user = _requireUser();
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw const AuthFailure(AuthFailureCode.unknown);
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await user.delete();
  });

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure(AuthFailureCode.unknown);
    return user;
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      createdAt: user.metadata.creationTime?.toUtc() ?? DateTime.now().toUtc(),
    );
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapFailureCode(error.code));
    }
  }

  AuthFailureCode _mapFailureCode(String code) {
    return switch (code) {
      'invalid-email' => AuthFailureCode.invalidEmail,
      'wrong-password' ||
      'user-not-found' ||
      'invalid-credential' => AuthFailureCode.wrongCredentials,
      'email-already-in-use' => AuthFailureCode.emailInUse,
      'weak-password' => AuthFailureCode.weakPassword,
      'network-request-failed' => AuthFailureCode.network,
      'too-many-requests' => AuthFailureCode.tooManyRequests,
      'requires-recent-login' => AuthFailureCode.requiresRecentLogin,
      'user-disabled' => AuthFailureCode.userDisabled,
      _ => AuthFailureCode.unknown,
    };
  }
}
