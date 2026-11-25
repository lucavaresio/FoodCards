import '../../data/repositories/auth_repository.dart';

String authErrorMessage(Object error) {
  if (error is! AuthFailure) {
    return 'Si è verificato un errore. Riprova.';
  }
  return switch (error.code) {
    AuthFailureCode.invalidEmail => 'Inserisci un indirizzo email valido.',
    AuthFailureCode.wrongCredentials => 'Email o password non corretti.',
    AuthFailureCode.emailInUse => 'Questa email è già registrata.',
    AuthFailureCode.weakPassword => 'La password è troppo debole.',
    AuthFailureCode.network => 'Connessione non disponibile. Riprova.',
    AuthFailureCode.tooManyRequests => 'Troppi tentativi. Riprova più tardi.',
    AuthFailureCode.requiresRecentLogin =>
      'Accedi di nuovo per completare questa operazione.',
    AuthFailureCode.userDisabled => 'Questo account è stato disabilitato.',
    AuthFailureCode.unknown => 'Si è verificato un errore. Riprova.',
  };
}

String get passwordResetConfirmation =>
    'Se l’email è registrata, riceverai un link.';
