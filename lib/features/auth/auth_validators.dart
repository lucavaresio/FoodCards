import '../../constants/auth_constants.dart';

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty || !RegExp(AuthConstants.emailPattern).hasMatch(email)) {
    return 'Inserisci un indirizzo email valido';
  }
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.length < AuthConstants.minPasswordLength) {
    return 'La password deve contenere almeno ${AuthConstants.minPasswordLength} caratteri';
  }
  if (password.length > AuthConstants.maxPasswordLength) {
    return 'La password non può superare ${AuthConstants.maxPasswordLength} caratteri';
  }
  return null;
}

String? validatePasswordConfirmation(String? value, String password) {
  if (value != password) return 'Le password non coincidono';
  return null;
}

String? validateDisplayName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Inserisci un nome';
  if (name.length < AuthConstants.minDisplayNameLength) {
    return 'Il nome deve contenere almeno ${AuthConstants.minDisplayNameLength} caratteri';
  }
  if (name.length > AuthConstants.maxDisplayNameLength) {
    return 'Il nome non può superare ${AuthConstants.maxDisplayNameLength} caratteri';
  }
  return null;
}
