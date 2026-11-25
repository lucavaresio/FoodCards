import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService(this._prefs, {required String uid}) : _prefix = 'u_${uid}_';

  final SharedPreferences _prefs;
  final String _prefix;

  String _key(String key) => '$_prefix$key';

  int? readInt(String key) => _prefs.getInt(_key(key));
  Future<void> writeInt(String key, int value) =>
      _prefs.setInt(_key(key), value);

  String? readString(String key) => _prefs.getString(_key(key));
  Future<void> writeString(String key, String value) async {
    final saved = await _prefs.setString(_key(key), value);
    if (!saved) throw StateError('Impossibile salvare il dato: $key');
  }

  Map<String, dynamic>? readJson(String key) {
    final value = readString(key);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, dynamic>
          ? decoded
          : decoded is Map
          ? decoded.map((key, value) => MapEntry(key.toString(), value))
          : null;
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) {
    return writeString(key, jsonEncode(value));
  }

  List<dynamic>? readJsonList(String key) {
    final value = readString(key);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is List<dynamic> ? decoded : null;
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeJsonList(String key, List<dynamic> value) {
    return writeString(key, jsonEncode(value));
  }

  Future<void> remove(String key) => _prefs.remove(_key(key));

  Future<void> clearUserData() async {
    for (final key
        in _prefs.getKeys().where((key) => key.startsWith(_prefix)).toList()) {
      final removed = await _prefs.remove(key);
      if (!removed && _prefs.containsKey(key)) {
        throw StateError('Impossibile rimuovere il dato: $key');
      }
    }
  }
}
