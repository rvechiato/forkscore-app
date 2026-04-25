import 'package:flutter/foundation.dart';

import '../../data/forkscore_api_places_repository.dart';
import '../../domain/models/place_detail.dart';
import '../../domain/models/place_summary.dart';
import '../../domain/places_repository.dart';

class PlacesController extends ChangeNotifier {
  PlacesController({
    required PlacesRepository repository,
    required String? Function() accessTokenProvider,
  }) : _repository = repository,
       _accessTokenProvider = accessTokenProvider;

  final PlacesRepository _repository;
  final String? Function() _accessTokenProvider;

  List<PlaceSummary> _places = const [];
  PlaceDetail? _selectedPlace;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isLoadingDetail = false;

  List<PlaceSummary> get places => _places;
  PlaceDetail? get selectedPlace => _selectedPlace;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isLoadingDetail => _isLoadingDetail;

  Future<void> loadPlaces() async {
    final accessToken = _accessTokenProvider();
    if (accessToken == null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final places = await _repository.listPlaces(accessToken: accessToken);
      _places = places;
      if (_selectedPlace == null && places.isNotEmpty) {
        await _loadPlaceDetail(accessToken, places.first.id, notify: false);
      }
    } on PlacesRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Nao foi possivel carregar os locais agora.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPlace(String placeId) async {
    final accessToken = _accessTokenProvider();
    if (accessToken == null) {
      return;
    }

    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadPlaceDetail(accessToken, placeId, notify: false);
    } on PlacesRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Nao foi possivel carregar o detalhe do local.';
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> createPlace({
    required String name,
    required String street,
    required String number,
    required String neighborhood,
    required String city,
  }) async {
    final accessToken = _accessTokenProvider();
    if (accessToken == null) {
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final detail = await _repository.createPlace(
        accessToken: accessToken,
        name: name,
        street: street,
        number: number,
        neighborhood: neighborhood,
        city: city,
      );
      _selectedPlace = detail;
      _places = [
        PlaceSummary(
          id: detail.id,
          name: detail.name,
          neighborhood: detail.neighborhood,
          city: detail.city,
          createdBy: detail.createdBy,
        ),
        ..._places.where((place) => place.id != detail.id),
      ];
    } on PlacesRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Nao foi possivel salvar o local agora.';
    } finally {
      _isSaving = false;
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

  Future<void> _loadPlaceDetail(
    String accessToken,
    String placeId, {
    required bool notify,
  }) async {
    _selectedPlace = await _repository.getPlaceById(
      accessToken: accessToken,
      placeId: placeId,
    );
    if (notify) {
      notifyListeners();
    }
  }
}
