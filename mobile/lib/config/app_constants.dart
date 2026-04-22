/**
 * Configuração de constantes da aplicação
 */

abstract class AppConstants {
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int minCommentLength = 10;
  static const int maxCommentLength = 500;

  // Rating
  static const int minRating = 0;
  static const int maxRating = 5;
  static const int minRatingForJustification = 3;

  // Review Criteria
  static const List<String> reviewCriteria = [
    'sabor',
    'atendimento',
    'custo',
    'infra',
  ];

  // Durations
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);
}
