import 'models/auth_session.dart';
import 'models/auth_user.dart';

abstract class AuthRepository {
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthUser> getMyProfile({
    required String accessToken,
  });

  Future<AuthUser> updateMyProfile({
    required String accessToken,
    required String name,
    required DateTime? birthDate,
    required String email,
  });
}
