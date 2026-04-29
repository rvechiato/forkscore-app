import 'package:flutter/foundation.dart';

import '../../domain/models/place_review_summary.dart';
import '../../domain/reviews_repository.dart';

class PlaceReviewSummaryController extends ChangeNotifier {
  PlaceReviewSummaryController({
    required ReviewsRepository repository,
    required String? Function() accessTokenProvider,
  }) : _repository = repository,
       _accessTokenProvider = accessTokenProvider;

  final ReviewsRepository _repository;
  final String? Function() _accessTokenProvider;

  PlaceReviewSummary? _summary;
  String? _errorMessage;
  bool _isLoading = false;
  String? _placeId;
  int _requestId = 0;

  PlaceReviewSummary? get summary => _summary;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get placeId => _placeId;

  Future<void> load(String placeId) async {
    final accessToken = _accessTokenProvider();
    if (accessToken == null) {
      _summary = null;
      _errorMessage = 'Sua sessao expirou. Entre novamente para ver reviews.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final requestId = ++_requestId;
    _placeId = placeId;
    _summary = null;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final summary = await _repository.getPlaceReviewSummary(
        accessToken: accessToken,
        placeId: placeId,
      );
      if (requestId != _requestId) {
        return;
      }
      _summary = summary;
    } on ReviewsRepositoryException catch (error) {
      if (requestId != _requestId) {
        return;
      }
      _errorMessage = error.message;
    } catch (_) {
      if (requestId != _requestId) {
        return;
      }
      _errorMessage = 'Nao foi possivel carregar o resumo de reviews.';
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> retry() async {
    final placeId = _placeId;
    if (placeId == null) {
      return;
    }
    await load(placeId);
  }

  void clear() {
    if (_summary == null &&
        _errorMessage == null &&
        _isLoading == false &&
        _placeId == null) {
      return;
    }

    _requestId++;
    _summary = null;
    _errorMessage = null;
    _isLoading = false;
    _placeId = null;
    notifyListeners();
  }
}
