import 'simple_http_client.dart';

class _UnsupportedHttpClient implements SimpleHttpClient {
  @override
  Future<HttpResponseData> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) {
    throw UnsupportedError('HTTP client is not supported on this platform.');
  }

  @override
  Future<HttpResponseData> post(
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  }) {
    throw UnsupportedError('HTTP client is not supported on this platform.');
  }

  @override
  Future<HttpResponseData> put(
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  }) {
    throw UnsupportedError('HTTP client is not supported on this platform.');
  }
}

SimpleHttpClient createSimpleHttpClient() => _UnsupportedHttpClient();
