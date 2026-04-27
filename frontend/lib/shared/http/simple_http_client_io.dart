import 'dart:convert';
import 'dart:io';

import 'simple_http_client.dart';

class _IoHttpClient implements SimpleHttpClient {
  final HttpClient _client = HttpClient();

  @override
  Future<HttpResponseData> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) {
    return _send(method: 'GET', uri: uri, headers: headers);
  }

  @override
  Future<HttpResponseData> post(
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  }) {
    return _send(method: 'POST', uri: uri, headers: headers, body: body);
  }

  @override
  Future<HttpResponseData> put(
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  }) {
    return _send(method: 'PUT', uri: uri, headers: headers, body: body);
  }

  Future<HttpResponseData> _send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    final request = await _client.openUrl(method, uri);

    headers.forEach(request.headers.set);
    if (body != null) {
      request.add(utf8.encode(body));
    }

    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);

    return HttpResponseData(
      statusCode: response.statusCode,
      body: responseBody,
    );
  }
}

SimpleHttpClient createSimpleHttpClient() => _IoHttpClient();
