import '../domain/auth_repository.dart';
import '../domain/models/auth_session.dart';
import '../domain/models/auth_user.dart';
import 'forkscore_api_auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _seedDemoUser();
  }

  final Map<String, _StoredUser> _usersByEmail = <String, _StoredUser>{};
  final Map<String, _StoredUser> _usersById = <String, _StoredUser>{};
  int _nextId = 1;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await _simulateLatency();

    final storedUser = _usersByEmail[email.trim().toLowerCase()];
    if (storedUser == null || storedUser.password != password) {
      throw AuthRepositoryException('Email ou senha invalidos.');
    }

    return _toSession(storedUser);
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _simulateLatency();

    final normalizedEmail = email.trim().toLowerCase();
    if (_usersByEmail.containsKey(normalizedEmail)) {
      throw AuthRepositoryException('Ja existe uma conta com este email.');
    }

    final storedUser = _StoredUser(
      id: 'user-${_nextId++}',
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );
    _save(storedUser);
    return _toSession(storedUser);
  }

  @override
  Future<AuthUser> getMyProfile({required String accessToken}) async {
    await _simulateLatency();
    return _getUserByToken(accessToken).toAuthUser();
  }

  @override
  Future<AuthUser> updateMyProfile({
    required String accessToken,
    required String name,
    required DateTime? birthDate,
    required String email,
  }) async {
    await _simulateLatency();

    final storedUser = _getUserByToken(accessToken);
    final updatedUser = storedUser.copyWith(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      birthDate: birthDate,
    );

    _usersByEmail.remove(storedUser.email);
    _save(updatedUser);

    return updatedUser.toAuthUser();
  }

  void _seedDemoUser() {
    final demoUser = _StoredUser(
      id: 'user-${_nextId++}',
      name: 'Gastronomo',
      email: 'chef@example.com',
      password: 'super-secret-123',
    );
    _save(demoUser);
  }

  void _save(_StoredUser storedUser) {
    _usersByEmail[storedUser.email] = storedUser;
    _usersById[storedUser.id] = storedUser;
  }

  _StoredUser _getUserByToken(String accessToken) {
    final userId = accessToken.replaceFirst('mock-token-', '');
    final storedUser = _usersById[userId];
    if (storedUser == null) {
      throw AuthRepositoryException('Sessao invalida. Faca login novamente.');
    }
    return storedUser;
  }

  AuthSession _toSession(_StoredUser storedUser) {
    return AuthSession(
      accessToken: 'mock-token-${storedUser.id}',
      user: storedUser.toAuthUser(),
    );
  }

  Future<void> _simulateLatency() {
    return Future<void>.delayed(const Duration(milliseconds: 120));
  }
}

class _StoredUser {
  const _StoredUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.birthDate,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final DateTime? birthDate;

  _StoredUser copyWith({String? name, String? email, DateTime? birthDate}) {
    return _StoredUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  AuthUser toAuthUser() {
    return AuthUser(
      id: id,
      name: name,
      birthDate: birthDate,
      age: birthDate == null ? null : _calculateAge(birthDate!),
      email: email,
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final birthdayPassed =
        now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);

    if (!birthdayPassed) {
      age -= 1;
    }

    return age;
  }
}
