// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'simple_http_client.dart';

class _WebHttpClient implements SimpleHttpClient {
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
    final request = html.HttpRequest();
    final completer = Completer<HttpResponseData>();

    request
      ..open(method, uri.toString())
      ..responseType = 'text';

    headers.forEach(request.setRequestHeader);

    request.onLoadEnd.listen((_) {
      if (completer.isCompleted) {
        return;
      }

      completer.complete(
        HttpResponseData(
          statusCode: request.status ?? 0,
          body: request.responseText ?? '',
        ),
      );
    });

    request.onError.listen((_) {
      if (completer.isCompleted) {
        return;
      }

      completer.completeError(
        StateError('Falha de rede ao chamar ${uri.toString()}.'),
      );
    });

    request.send(body);
    return completer.future;
  }
}

SimpleHttpClient createSimpleHttpClient() => _WebHttpClient();
