import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class ApiClient extends http.BaseClient {
  late final http.Client _inner;
  String? _token;

  ApiClient({String? token}) : _token = token {
    _inner = http.Client();
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Add auth header if token exists
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    // Add default headers
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';

    return _inner.send(request);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await get(Uri.parse('${ApiConfig.baseUrl}$path'));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, {required Map<String, dynamic> body}) async {
    final response = await post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, {required Map<String, dynamic> body}) async {
    final response = await put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await delete(Uri.parse('${ApiConfig.baseUrl}$path'));
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      throw Exception(data['message'] ?? 'Unknown error');
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }
}
