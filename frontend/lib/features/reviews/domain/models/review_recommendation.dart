enum ReviewRecommendation {
  recommended(
    apiValue: 'recommended',
    label: 'Sim, recomendaria',
    summaryLabel: 'Recomendado',
  ),
  notRecommended(
    apiValue: 'not_recommended',
    label: 'Nao recomendaria',
    summaryLabel: 'Nao recomendado',
  );

  const ReviewRecommendation({
    required this.apiValue,
    required this.label,
    required this.summaryLabel,
  });

  final String apiValue;
  final String label;
  final String summaryLabel;

  static ReviewRecommendation fromApiValue(String value) {
    return ReviewRecommendation.values.firstWhere(
      (item) => item.apiValue == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Recommendation invalida.'),
    );
  }
}
