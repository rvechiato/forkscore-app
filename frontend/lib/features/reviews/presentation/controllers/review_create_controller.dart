import 'package:flutter/foundation.dart';

import '../../domain/models/review_submission_request.dart';
import '../../domain/models/submitted_review.dart';
import '../../domain/reviews_repository.dart';

class ReviewCreateController extends ChangeNotifier {
  ReviewCreateController({
    required ReviewsRepository repository,
    required String? Function() accessTokenProvider,
  }) : _repository = repository,
       _accessTokenProvider = accessTokenProvider;

  final ReviewsRepository _repository;
  final String? Function() _accessTokenProvider;

  bool _isSubmitting = false;
  String? _errorMessage;
  SubmittedReview? _submittedReview;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  SubmittedReview? get submittedReview => _submittedReview;

  Future<bool> submit({
    required String placeId,
    required ReviewSubmissionRequest request,
  }) async {
    final accessToken = _accessTokenProvider();
    if (accessToken == null) {
      _errorMessage = 'Sua sessao expirou. Entre novamente para avaliar.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _submittedReview = await _repository.submitReview(
        accessToken: accessToken,
        placeId: placeId,
        request: request,
      );
      return true;
    } on ReviewsRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Nao foi possivel enviar a avaliacao agora.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void resetSubmissionState() {
    if (_errorMessage == null && _submittedReview == null) {
      return;
    }

    _errorMessage = null;
    _submittedReview = null;
    notifyListeners();
  }
}
