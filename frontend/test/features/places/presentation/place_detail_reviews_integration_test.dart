import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkscore_frontend/app/app.dart';
import 'package:forkscore_frontend/app/navigation/app_routes.dart';

void main() {
  testWidgets('detalhe lateral mostra reviews sem esconder o CTA', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp(initialRoute: AppRoutes.home));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login-email-field')),
      'chef@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      'super-secret-123',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('place-review-summary-content')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('start-review-button')), findsOneWidget);
    expect(find.text('2 reviews registradas'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('place-search-result-place-2')));
    await tester.tap(find.byKey(const Key('place-search-result-place-2')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-review-summary-empty')), findsOneWidget);
    expect(find.byKey(const Key('start-review-button')), findsOneWidget);
  });
}
