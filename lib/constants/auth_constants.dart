class AuthConstants {
  AuthConstants._();

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const int minDisplayNameLength = 3;
  static const int maxDisplayNameLength = 20;
  static const String emailPattern =
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$";
}
