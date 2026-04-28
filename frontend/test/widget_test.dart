import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forkscore_frontend/app/app.dart';
import 'package:forkscore_frontend/app/navigation/app_routes.dart';
import 'package:forkscore_frontend/features/places/data/mock_places_repository.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/place_review_summary.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/review_submission_request.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/submitted_review.dart';
import 'package:forkscore_frontend/features/reviews/domain/reviews_repository.dart';

void main() {
  testWidgets('renderiza a tela de login inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const ForkScoreApp());
    await tester.pumpAndSettle();

    expect(find.text('ForkScore'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar nova conta'), findsOneWidget);
  });

  testWidgets(
    'redireciona rota protegida para login e volta ao destino apos autenticar',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ForkScoreApp(initialRoute: AppRoutes.home));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login-email-field')), findsOneWidget);
      expect(find.byKey(const ValueKey('home-page')), findsNothing);

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

      expect(find.byKey(const ValueKey('home-page')), findsOneWidget);
      expect(find.textContaining('Bem-vindo'), findsOneWidget);
      expect(find.text('Pesquisa de Lugares'), findsNothing);
      expect(find.byKey(const Key('places-search-field')), findsOneWidget);
      expect(find.byKey(const Key('new-establishment-button')), findsOneWidget);
    },
  );

  testWidgets('navega para cadastro, autentica e faz logout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('go-to-register-button')));
    await tester.tap(find.byKey(const Key('go-to-register-button')));
    await tester.pumpAndSettle();

    expect(find.text('Criar Conta'), findsWidgets);

    await tester.enterText(
      find.byKey(const Key('register-name-field')),
      'Rafa Vecchiato',
    );
    await tester.enterText(
      find.byKey(const Key('register-email-field')),
      'rafa@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register-password-field')),
      'super-secret-123',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm-password-field')),
      'super-secret-123',
    );

    await tester.ensureVisible(find.text('Criar Conta').last);
    await tester.tap(find.text('Criar Conta').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Rafa Vecchiato'), findsWidgets);
    expect(find.text('Sair'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-email-field')), findsOneWidget);
    expect(find.textContaining('Rafa Vecchiato'), findsNothing);
  });

  testWidgets('usuario autenticado navega para outra rota interna protegida', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp());
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

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsWidgets);
    expect(find.textContaining('Area protegida'), findsOneWidget);
  });

  testWidgets('home autenticada concentra busca e lista de lugares no MVP', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp());
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

    expect(find.byKey(const ValueKey('home-page')), findsOneWidget);
    expect(find.textContaining('Bem-vindo'), findsOneWidget);
    expect(find.text('Pesquisa de Lugares'), findsNothing);
    expect(find.byKey(const Key('places-search-field')), findsOneWidget);
    expect(find.byKey(const Key('new-establishment-button')), findsOneWidget);
    expect(find.text('Cafe do Centro'), findsWidgets);
  });

  testWidgets('abre o cadastro de lugar a partir da home unificada', (
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

    await tester.ensureVisible(
      find.byKey(const Key('new-establishment-button')),
    );
    await tester.tap(find.byKey(const Key('new-establishment-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-create-page')), findsOneWidget);
    expect(find.byKey(const Key('create-place-name-field')), findsOneWidget);
    expect(find.byKey(const Key('submit-new-establishment')), findsOneWidget);
  });

  testWidgets('cria uma review completa a partir da rota protegida', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ForkScoreApp(initialRoute: AppRoutes.reviews));
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

    expect(find.byKey(const Key('start-review-button')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('start-review-button')));
    await tester.tap(find.byKey(const Key('start-review-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('criterion-rating-taste-5')));
    await tester.enterText(
      find.byKey(const Key('criterion-comment-taste')),
      'Prato marcante e bem executado.',
    );

    await tester.tap(find.byKey(const Key('criterion-rating-service-4')));
    await tester.enterText(
      find.byKey(const Key('criterion-comment-service')),
      'Equipe atenciosa e agil.',
    );

    await tester.tap(find.byKey(const Key('criterion-rating-options-2')));
    await tester.enterText(
      find.byKey(const Key('criterion-comment-options')),
      'Poucas alternativas no cardapio.',
    );
    await tester.enterText(
      find.byKey(const Key('criterion-justification-options')),
      'Faltaram opcoes vegetarianas e sem lactose.',
    );

    await tester.tap(find.byKey(const Key('criterion-rating-infrastructure-3')));
    await tester.enterText(
      find.byKey(const Key('criterion-comment-infrastructure')),
      'Ambiente confortavel e limpo.',
    );

    await tester.ensureVisible(find.byKey(const Key('cost-benefit-rating-4')));
    await tester.tap(find.byKey(const Key('cost-benefit-rating-4')));
    await tester.ensureVisible(find.text('Sim, recomendaria'));
    await tester.tap(find.text('Sim, recomendaria'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('review-submit-button')));
    await tester.tap(find.byKey(const Key('review-submit-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('review-success-card')), findsOneWidget);
    expect(find.text('Avaliacao enviada'), findsOneWidget);
  });

  testWidgets('home autenticada mostra resumo de reviews no detalhe do local', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp());
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-review-summary-content')), findsOneWidget);
    expect(find.text('Reviews do local'), findsOneWidget);
    expect(find.text('4.3'), findsOneWidget);
    expect(find.textContaining('2 reviews registradas'), findsOneWidget);
    expect(find.byKey(const Key('place-review-item-rev_1')), findsOneWidget);
    expect(find.byKey(const Key('start-review-button')), findsOneWidget);
  });

  testWidgets('detalhe do local mostra estado vazio de reviews quando necessario', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp());
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('place-search-result-place-2')));
    await tester.tap(find.byKey(const Key('place-search-result-place-2')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-review-summary-empty')), findsOneWidget);
    expect(
      find.text('Ainda nao existem reviews para este local.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('start-review-button')), findsOneWidget);
  });

  testWidgets('detalhe do local mostra erro de reviews sem quebrar CTA', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ForkScoreApp(
        placesRepository: MockPlacesRepository(),
        reviewsRepository: _FailingReviewsRepository(),
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-review-summary-error')), findsOneWidget);
    expect(find.text('Falha ao carregar reviews.'), findsOneWidget);
    expect(find.byKey(const Key('start-review-button')), findsOneWidget);
  });
}

class _FailingReviewsRepository implements ReviewsRepository {
  @override
  Future<PlaceReviewSummary> getPlaceReviewSummary({
    required String accessToken,
    required String placeId,
  }) {
    throw ReviewsRepositoryException('Falha ao carregar reviews.');
  }

  @override
  Future<SubmittedReview> submitReview({
    required String accessToken,
    required String placeId,
    required ReviewSubmissionRequest request,
  }) {
    throw UnimplementedError();
  }
}
