/**
 * Configuração API do ForkScore
 * 
 * Define a URL base, interceptadores, timeouts, etc.
 */

abstract class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout = Duration(seconds: 30);
  static const String apiVersion = 'v1';
}
