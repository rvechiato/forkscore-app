class AppEnvironment {
  static const bool useMocks = bool.fromEnvironment(
    'FORKSCORE_USE_MOCKS',
    defaultValue: false,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'FORKSCORE_API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
