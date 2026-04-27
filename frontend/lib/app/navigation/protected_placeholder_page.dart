import 'package:flutter/material.dart';

import '../auth_scope.dart';
import 'app_routes.dart';

class ProtectedPlaceholderPage extends StatelessWidget {
  const ProtectedPlaceholderPage({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final userName = sessionController.currentUser?.name ?? 'Gastronomo';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            key: Key('${title.toLowerCase()}-logout-button'),
            onPressed: () {
              sessionController.logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Area protegida para $userName.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              },
              child: const Text('Voltar para a home'),
            ),
          ],
        ),
      ),
    );
  }
}
