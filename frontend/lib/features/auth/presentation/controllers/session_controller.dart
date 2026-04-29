import 'package:flutter/foundation.dart';

import '../../application/auth_session_storage.dart';
import '../../data/forkscore_api_auth_repository.dart';
import '../../domain/auth_repository.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/models/auth_user.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository repository,
    AuthSessionStorage? sessionStorage,
  }) : _repository = repository,
       _sessionStorage = sessionStorage {
    if (_sessionStorage == null) {
      _isRestoring = false;
    } else {
      restoreSession();
    }
  }

  final AuthRepository _repository;
  final AuthSessionStorage? _sessionStorage;

  AuthSession? _session;
  String? _errorMessage;
  bool _isBusy = false;
  bool _isRestoring = true;

  AuthSession? get session => _session;
  AuthUser? get currentUser => _session?.user;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _session != null;
  bool get isRestoring => _isRestoring;

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
      await _persistSession();
    });
  }

  Future<void> login({required String email, required String password}) async {
    await _run(() async {
      _session = await _repository.login(email: email, password: password);
      await _persistSession();
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
      await _persistSession();
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
      await _persistSession();
    });
  }

  Future<void> logout() async {
    _session = null;
    _errorMessage = null;
    await _sessionStorage?.clearSession();
    notifyListeners();
  }

  Future<void> restoreSession() async {
    final storage = _sessionStorage;
    if (storage == null) {
      return;
    }

    _isRestoring = true;
    notifyListeners();

    try {
      final storedSession = await storage.readSession();
      if (storedSession == null) {
        _session = null;
        return;
      }

      _session = storedSession;
      try {
        final user = await _repository.getMyProfile(
          accessToken: storedSession.accessToken,
        );
        _session = storedSession.copyWith(user: user);
        await _persistSession();
      } on AuthRepositoryException {
        _session = null;
        await storage.clearSession();
      }
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
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

  Future<void> _persistSession() async {
    final storage = _sessionStorage;
    final session = _session;
    if (storage == null || session == null) {
      return;
    }

    await storage.writeSession(session);
  }
}
