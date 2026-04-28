import '../domain/models/review_author.dart';
import '../domain/models/review_criterion.dart';
import '../domain/models/review_criterion_code.dart';
import '../domain/models/review_submission_request.dart';
import '../domain/models/submitted_review.dart';
import '../domain/reviews_repository.dart';

class MockReviewsRepository implements ReviewsRepository {
  final List<SubmittedReview> _submittedReviews = <SubmittedReview>[];
  int _nextId = 1;

  @override
  Future<SubmittedReview> submitReview({
    required String accessToken,
    required String placeId,
    required ReviewSubmissionRequest request,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    _validateRequest(request);

    final review = SubmittedReview(
      id: 'rev_${_nextId++}',
      placeId: placeId,
      user: _authorFromToken(accessToken),
      recommendation: request.recommendation,
      costBenefitRating: request.costBenefitRating,
      criteria: request.criteria,
      createdAt: DateTime.now().toUtc(),
    );
    _submittedReviews.insert(0, review);
    return review;
  }

  void _validateRequest(ReviewSubmissionRequest request) {
    if (request.costBenefitRating < 1 || request.costBenefitRating > 5) {
      throw ReviewsRepositoryException(
        'Custo-beneficio deve ficar entre 1 e 5.',
      );
    }
    if (request.criteria.length != ReviewCriterionCode.orderedValues.length) {
      throw ReviewsRepositoryException(
        'A review precisa conter os 4 criterios obrigatorios.',
      );
    }

    final seenCodes = <ReviewCriterionCode>{};
    for (final criterion in request.criteria) {
      _validateCriterion(criterion);
      if (!seenCodes.add(criterion.code)) {
        throw ReviewsRepositoryException(
          'Cada criterio deve aparecer exatamente uma vez.',
        );
      }
    }

    if (seenCodes.length != ReviewCriterionCode.orderedValues.length) {
      throw ReviewsRepositoryException(
        'A review precisa conter todos os criterios obrigatorios.',
      );
    }
  }

  void _validateCriterion(ReviewCriterion criterion) {
    if (criterion.rating < 1 || criterion.rating > 5) {
      throw ReviewsRepositoryException(
        'A nota de ${criterion.code.label} deve ficar entre 1 e 5.',
      );
    }

    if (criterion.comment.trim().isEmpty) {
      throw ReviewsRepositoryException(
        'Comentario obrigatorio em ${criterion.code.label}.',
      );
    }

    if (criterion.comment.trim().length > 500) {
      throw ReviewsRepositoryException(
        'Comentario de ${criterion.code.label} excede o limite permitido.',
      );
    }

    final justification = criterion.justification?.trim();
    if (criterion.rating < 3 && (justification == null || justification.isEmpty)) {
      throw ReviewsRepositoryException(
        'Justificativa obrigatoria quando ${criterion.code.label} ficar abaixo de 3.',
      );
    }

    if (justification != null && justification.length > 500) {
      throw ReviewsRepositoryException(
        'Justificativa de ${criterion.code.label} excede o limite permitido.',
      );
    }
  }

  ReviewAuthor _authorFromToken(String accessToken) {
    final userId = accessToken.replaceFirst('mock-token-', '');
    final knownNames = <String, String>{
      'user-1': 'Gastronomo',
      'user-2': 'Rafa Vecchiato',
    };

    return ReviewAuthor(
      id: userId,
      name: knownNames[userId] ?? 'Avaliador',
    );
  }
}
