import 'package:flutter/foundation.dart';

import '../../data/forkscore_api_auth_repository.dart';
import '../../domain/auth_repository.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/models/auth_user.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository repository,
  }) : _repository = repository;

  final AuthRepository _repository;

  AuthSession? _session;
  String? _errorMessage;
  bool _isBusy = false;

  AuthSession? get session => _session;
  AuthUser? get currentUser => _session?.user;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _session != null;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _run(() async {
      _session = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _run(() async {
      _session = await _repository.login(
        email: email,
        password: password,
      );
    });
  }

  Future<void> refreshProfile() async {
    final session = _session;
    if (session == null) {
      return;
    }

    await _run(() async {
      final user = await _repository.getMyProfile(
        accessToken: session.accessToken,
      );
      _session = session.copyWith(user: user);
    });
  }

  Future<void> updateProfile({
    required String name,
    required DateTime? birthDate,
    required String email,
  }) async {
    final session = _session;
    if (session == null) {
      return;
    }

    await _run(() async {
      final user = await _repository.updateMyProfile(
        accessToken: session.accessToken,
        name: name,
        birthDate: birthDate,
        email: email,
      );
      _session = session.copyWith(user: user);
    });
  }

  void logout() {
    _session = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on AuthRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Nao foi possivel falar com a API do ForkScore.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
