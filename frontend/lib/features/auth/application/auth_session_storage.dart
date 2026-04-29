import '../domain/models/auth_session.dart';

abstract class AuthSessionStorage {
  Future<AuthSession?> readSession();

  Future<void> writeSession(AuthSession session);

  Future<void> clearSession();
}
