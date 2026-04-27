import 'auth_user.dart';

class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final AuthUser user;

  AuthSession copyWith({String? accessToken, AuthUser? user}) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      user: user ?? this.user,
    );
  }
}
