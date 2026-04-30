import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../../shared/widgets/authenticated_page_scaffold.dart';

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
    return AuthenticatedPageScaffold(
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(description),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            },
            child: const Text('Voltar para a home'),
          ),
        ],
      ),
    );
  }
}
