import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/auth_shell_page.dart';
import '../shared/theme/app_theme.dart';

class ForkScoreApp extends StatelessWidget {
  const ForkScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForkScore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthShellPage(),
    );
  }
}
