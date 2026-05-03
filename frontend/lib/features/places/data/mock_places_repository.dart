import 'forkscore_api_places_repository.dart';
import '../domain/models/place_author.dart';
import '../domain/models/place_category.dart';
import '../domain/models/place_detail.dart';
import '../domain/models/place_review_summary_brief.dart';
import '../domain/models/place_summary.dart';
import '../domain/models/place_subcategory.dart';
import '../domain/places_repository.dart';

class MockPlacesRepository implements PlacesRepository {
  MockPlacesRepository() {
    _seedTaxonomy();
    _seedPlaces();
  }

  final List<PlaceCategory> _categories = <PlaceCategory>[];
  final List<PlaceSubcategory> _subcategories = <PlaceSubcategory>[];
  final List<PlaceDetail> _places = <PlaceDetail>[];
  int _nextId = 1;

  @override
  Future<List<PlaceCategory>> listCategories({
    required String accessToken,
  }) async {
    await _simulateLatency();
    return List<PlaceCategory>.from(_categories);
  }

  @override
  Future<List<PlaceSubcategory>> listSubcategories({
    required String accessToken,
    required String categoryId,
  }) async {
    await _simulateLatency();
    return _subcategories
        .where((item) => item.categoryId == categoryId)
        .toList(growable: false);
  }

  @override
  Future<PlaceDetail> createPlace({
    required String accessToken,
    required String name,
    required String street,
    required String number,
    required String neighborhood,
    required String city,
    String? instagramUrl,
    required String categoryId,
    required String subcategoryId,
  }) async {
    await _simulateLatency();

    final category = _categories
        .where((item) => item.id == categoryId)
        .firstOrNull;
    if (category == null) {
      throw PlacesRepositoryException('Categoria invalida.');
    }

    final subcategory = _subcategories
        .where((item) => item.id == subcategoryId)
        .firstOrNull;
    if (subcategory == null) {
      throw PlacesRepositoryException('Subcategoria invalida.');
    }
    if (subcategory.categoryId != category.id) {
      throw PlacesRepositoryException(
        'A subcategoria informada nao pertence a categoria selecionada.',
      );
    }

    final place = PlaceDetail(
      id: 'place-${_nextId++}',
      name: name.trim(),
      street: street.trim(),
      number: number.trim(),
      neighborhood: neighborhood.trim(),
      city: city.trim(),
      instagramUrl: _normalizeOptional(instagramUrl),
      category: category,
      subcategory: subcategory,
      createdBy: _authorFromToken(accessToken),
    );
    _places.insert(0, place);
    return place;
  }

  @override
  Future<PlaceDetail> getPlaceById({
    required String accessToken,
    required String placeId,
  }) async {
    await _simulateLatency();

    final place = _places.where((item) => item.id == placeId).firstOrNull;
    if (place == null) {
      throw PlacesRepositoryException('Local nao encontrado.');
    }
    return place;
  }

  @override
  Future<List<PlaceSummary>> listPlaces({required String accessToken}) async {
    await _simulateLatency();

    return _places
        .map(
          (place) => PlaceSummary(
            id: place.id,
            name: place.name,
            neighborhood: place.neighborhood,
            city: place.city,
            instagramUrl: place.instagramUrl,
            category: place.category,
            subcategory: place.subcategory,
            createdBy: place.createdBy,
            reviewSummary: _reviewSummaryByPlaceId(place.id),
          ),
        )
        .toList(growable: false);
  }

  PlaceAuthor _authorFromToken(String accessToken) {
    final userId = accessToken.replaceFirst('mock-token-', '');
    final knownNames = <String, String>{
      'user-1': 'Gastronomo',
      'user-2': 'Rafa Vecchiato',
    };

    return PlaceAuthor(id: userId, name: knownNames[userId]);
  }

  void _seedTaxonomy() {
    _categories.addAll(const <PlaceCategory>[
      PlaceCategory(
        id: 'cat_restaurante',
        name: 'Restaurante',
        slug: 'restaurante',
      ),
      PlaceCategory(
        id: 'cat_lanchonete',
        name: 'Lanchonete',
        slug: 'lanchonete',
      ),
      PlaceCategory(id: 'cat_cafeteria', name: 'Cafeteria', slug: 'cafeteria'),
      PlaceCategory(id: 'cat_bar', name: 'Bar', slug: 'bar'),
      PlaceCategory(
        id: 'cat_especializado',
        name: 'Especializado',
        slug: 'especializado',
      ),
      PlaceCategory(
        id: 'cat_street_food',
        name: 'Street Food',
        slug: 'street-food',
      ),
      PlaceCategory(
        id: 'cat_experiencia',
        name: 'Experiencia',
        slug: 'experiencia',
      ),
    ]);

    _subcategories.addAll(const <PlaceSubcategory>[
      PlaceSubcategory(
        id: 'sub_fine_dining',
        categoryId: 'cat_restaurante',
        name: 'Fine Dining',
        slug: 'fine-dining',
      ),
      PlaceSubcategory(
        id: 'sub_casual_dining',
        categoryId: 'cat_restaurante',
        name: 'Casual Dining',
        slug: 'casual-dining',
      ),
      PlaceSubcategory(
        id: 'sub_self_service',
        categoryId: 'cat_restaurante',
        name: 'Self-Service',
        slug: 'self-service',
      ),
      PlaceSubcategory(
        id: 'sub_tematico',
        categoryId: 'cat_restaurante',
        name: 'Tematico',
        slug: 'tematico',
      ),
      PlaceSubcategory(
        id: 'sub_fast_food',
        categoryId: 'cat_lanchonete',
        name: 'Fast Food',
        slug: 'fast-food',
      ),
      PlaceSubcategory(
        id: 'sub_hamburgueria',
        categoryId: 'cat_lanchonete',
        name: 'Hamburgueria',
        slug: 'hamburgueria',
      ),
      PlaceSubcategory(
        id: 'sub_sanduiches',
        categoryId: 'cat_lanchonete',
        name: 'Sanduiches',
        slug: 'sanduiches',
      ),
      PlaceSubcategory(
        id: 'sub_salgados',
        categoryId: 'cat_lanchonete',
        name: 'Salgados',
        slug: 'salgados',
      ),
      PlaceSubcategory(
        id: 'sub_cafeteria',
        categoryId: 'cat_cafeteria',
        name: 'Cafeteria',
        slug: 'cafeteria',
      ),
      PlaceSubcategory(
        id: 'sub_doceria',
        categoryId: 'cat_cafeteria',
        name: 'Doceria',
        slug: 'doceria',
      ),
      PlaceSubcategory(
        id: 'sub_confeitaria',
        categoryId: 'cat_cafeteria',
        name: 'Confeitaria',
        slug: 'confeitaria',
      ),
      PlaceSubcategory(
        id: 'sub_padaria_gourmet',
        categoryId: 'cat_cafeteria',
        name: 'Padaria Gourmet',
        slug: 'padaria-gourmet',
      ),
      PlaceSubcategory(
        id: 'sub_bar_tradicional',
        categoryId: 'cat_bar',
        name: 'Bar Tradicional',
        slug: 'bar-tradicional',
      ),
      PlaceSubcategory(
        id: 'sub_gastrobar',
        categoryId: 'cat_bar',
        name: 'Gastrobar',
        slug: 'gastrobar',
      ),
      PlaceSubcategory(
        id: 'sub_pub',
        categoryId: 'cat_bar',
        name: 'Pub',
        slug: 'pub',
      ),
      PlaceSubcategory(
        id: 'sub_bar_com_musica',
        categoryId: 'cat_bar',
        name: 'Bar com Musica',
        slug: 'bar-com-musica',
      ),
    ]);
  }

  void _seedPlaces() {
    _places.addAll(<PlaceDetail>[
      PlaceDetail(
        id: 'place-${_nextId++}',
        name: 'Cafe do Centro',
        street: 'Rua das Flores',
        number: '123',
        neighborhood: 'Centro',
        city: 'Curitiba',
        instagramUrl: 'https://www.instagram.com/cafedocentro',
        category: _categoryById('cat_cafeteria'),
        subcategory: _subcategoryById('sub_cafeteria'),
        createdBy: const PlaceAuthor(id: 'user-1', name: 'Gastronomo'),
      ),
      PlaceDetail(
        id: 'place-${_nextId++}',
        name: 'Padaria da Vila',
        street: 'Avenida Principal',
        number: '987',
        neighborhood: 'Vila Nova',
        city: 'Joinville',
        instagramUrl: null,
        category: _categoryById('cat_cafeteria'),
        subcategory: _subcategoryById('sub_padaria_gourmet'),
        createdBy: const PlaceAuthor(id: 'user-1', name: 'Gastronomo'),
      ),
      PlaceDetail(
        id: 'place-${_nextId++}',
        name: 'Bistro da Praca',
        street: 'Alameda Verde',
        number: '45',
        neighborhood: 'Batel',
        city: 'Curitiba',
        instagramUrl: null,
        category: _categoryById('cat_restaurante'),
        subcategory: _subcategoryById('sub_casual_dining'),
        createdBy: const PlaceAuthor(id: 'user-1', name: 'Gastronomo'),
      ),
    ]);
  }

  PlaceCategory _categoryById(String id) {
    return _categories.firstWhere((item) => item.id == id);
  }

  PlaceSubcategory _subcategoryById(String id) {
    return _subcategories.firstWhere((item) => item.id == id);
  }

  PlaceReviewSummaryBrief _reviewSummaryByPlaceId(String id) {
    return switch (id) {
      'place-1' => const PlaceReviewSummaryBrief(
        totalReviews: 2,
        averageRating: 4.3,
      ),
      _ => const PlaceReviewSummaryBrief(totalReviews: 0, averageRating: null),
    };
  }

  Future<void> _simulateLatency() {
    return Future<void>.delayed(const Duration(milliseconds: 80));
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
