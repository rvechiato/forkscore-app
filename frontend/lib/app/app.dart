import 'package:flutter/material.dart';

import '../features/auth/data/forkscore_api_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/auth/presentation/pages/auth_shell_page.dart';
import '../shared/theme/app_theme.dart';

class ForkScoreApp extends StatefulWidget {
  const ForkScoreApp({
    super.key,
    AuthRepository? repository,
  }) : _repository = repository;

  final AuthRepository? _repository;

  @override
  State<ForkScoreApp> createState() => _ForkScoreAppState();
}

class _ForkScoreAppState extends State<ForkScoreApp> {
  late final SessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SessionController(
      repository:
          widget._repository ??
          ForkScoreApiAuthRepository(baseUrl: _defaultBaseUrl),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForkScore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AuthShellPage(controller: _controller),
    );
  }

  String get _defaultBaseUrl => const String.fromEnvironment(
    'FORKSCORE_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
