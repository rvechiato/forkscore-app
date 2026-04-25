import 'dart:convert';

import '../../../shared/http/simple_http_client.dart';
import '../domain/auth_repository.dart';
import '../domain/models/auth_session.dart';
import '../domain/models/auth_user.dart';

class ForkScoreApiAuthRepository implements AuthRepository {
  ForkScoreApiAuthRepository({
    required String baseUrl,
    SimpleHttpClient? client,
  }) : _baseUri = Uri.parse(baseUrl),
       _client = client ?? createPlatformHttpClient();

  final Uri _baseUri;
  final SimpleHttpClient _client;

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _resolve('/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    return _parseSession(response);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _resolve('/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _parseSession(response);
  }

  @override
  Future<AuthUser> getMyProfile({
    required String accessToken,
  }) async {
    final response = await _client.get(
      _resolve('/me'),
      headers: _authorizedHeaders(accessToken),
    );

    return _parseUserResponse(response);
  }

  @override
  Future<AuthUser> updateMyProfile({
    required String accessToken,
    required String name,
    required DateTime? birthDate,
    required String email,
  }) async {
    final response = await _client.put(
      _resolve('/me'),
      headers: _authorizedHeaders(accessToken),
      body: jsonEncode({
        'name': name,
        'birth_date': birthDate == null ? null : _formatDate(birthDate),
        'email': email,
      }),
    );

    return _parseUserResponse(response);
  }

  Uri _resolve(String path) => _baseUri.resolve(path);

  AuthSession _parseSession(HttpResponseData response) {
    final body = _decodeBody(response);
    _ensureSuccess(response.statusCode, body);

    return AuthSession(
      accessToken: body['access_token'] as String,
      user: _parseUser(body['user'] as Map<String, dynamic>),
    );
  }

  AuthUser _parseUserResponse(HttpResponseData response) {
    final body = _decodeBody(response);
    _ensureSuccess(response.statusCode, body);
    return _parseUser(body);
  }

  Map<String, dynamic> _decodeBody(HttpResponseData response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  AuthUser _parseUser(Map<String, dynamic> payload) {
    final birthDateValue = payload['birth_date'];
    final ageValue = payload['age'];

    return AuthUser(
      id: payload['id'] as String,
      name: payload['name'] as String,
      birthDate: birthDateValue is String ? DateTime.parse(birthDateValue) : null,
      age: ageValue is int ? ageValue : null,
      email: payload['email'] as String,
    );
  }

  void _ensureSuccess(int statusCode, Map<String, dynamic> body) {
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) {
      throw AuthRepositoryException(detail);
    }

    throw AuthRepositoryException('Nao foi possivel concluir a solicitacao.');
  }

  Map<String, String> get _jsonHeaders => const {
    'content-type': 'application/json',
    'accept': 'application/json',
  };

  Map<String, String> _authorizedHeaders(String accessToken) => {
    ..._jsonHeaders,
    'authorization': 'Bearer $accessToken',
  };

  String _formatDate(DateTime value) {
    final safeValue = DateTime(value.year, value.month, value.day);
    final month = safeValue.month.toString().padLeft(2, '0');
    final day = safeValue.day.toString().padLeft(2, '0');
    return '${safeValue.year}-$month-$day';
  }
}

class AuthRepositoryException implements Exception {
  AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
