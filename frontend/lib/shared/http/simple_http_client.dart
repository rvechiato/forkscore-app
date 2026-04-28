import 'simple_http_client_impl.dart';

class HttpResponseData {
  const HttpResponseData({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

abstract class SimpleHttpClient {
  Future<HttpResponseData> get(
    Uri uri, {
    Map<String, String> headers = const {},
  });

  Future<HttpResponseData> post(
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  });

  Future<HttpResponseData> put(
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  });
}

SimpleHttpClient createPlatformHttpClient() => createSimpleHttpClient();
