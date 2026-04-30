import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkscore_frontend/app/app.dart';
import 'package:forkscore_frontend/app/navigation/app_routes.dart';
import 'package:forkscore_frontend/features/auth/data/mock_auth_repository.dart';
import 'package:forkscore_frontend/features/auth/presentation/controllers/session_controller.dart';
import 'package:forkscore_frontend/features/places/data/mock_places_repository.dart';
import 'package:forkscore_frontend/features/reviews/data/mock_reviews_repository.dart';

void main() {
  testWidgets('pagina dedicada mostra reviews sem esconder o CTA', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ForkScoreApp(
        initialRoute: AppRoutes.home,
        sessionController: SessionController(repository: MockAuthRepository()),
        placesRepository: MockPlacesRepository(),
        reviewsRepository: MockReviewsRepository(),
      ),
    );
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

    await tester.ensureVisible(
      find.byKey(const Key('place-search-result-place-1')),
    );
    await tester.tap(find.byKey(const Key('place-search-result-place-1')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('place-reviews-page')), findsOneWidget);
    expect(
      find.byKey(const Key('place-review-summary-content')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('start-review-button')), findsOneWidget);
    expect(find.text('2 reviews registradas'), findsOneWidget);
    expect(
      find.byKey(const Key('place-review-full-item-rev_1')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('place-search-result-place-2')),
    );
    await tester.tap(find.byKey(const Key('place-search-result-place-2')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-review-summary-empty')), findsOneWidget);
    expect(find.byKey(const Key('place-reviews-list-empty')), findsOneWidget);
    expect(find.byKey(const Key('start-review-button')), findsOneWidget);
  });
}
