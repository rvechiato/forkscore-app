import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../application/auth_session_storage.dart';
import '../domain/models/auth_session.dart';

class SharedPreferencesAuthSessionStorage implements AuthSessionStorage {
  SharedPreferencesAuthSessionStorage({required SharedPreferences preferences})
    : _preferences = preferences;

  static const _sessionKey = 'forkscore.auth.session';

  final SharedPreferences _preferences;

  @override
  Future<AuthSession?> readSession() async {
    final raw = _preferences.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSession.fromJson(decoded);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  @override
  Future<void> writeSession(AuthSession session) async {
    await _preferences.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clearSession() async {
    await _preferences.remove(_sessionKey);
  }
}
