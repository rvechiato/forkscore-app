enum ReviewCriterionCode {
  taste(
    apiValue: 'taste',
    label: 'Sabor',
    helperText: 'O prato entregou sabor, equilibrio e execucao tecnica?',
  ),
  service(
    apiValue: 'service',
    label: 'Atendimento',
    helperText: 'Como foi a atencao, ritmo e clareza do atendimento?',
  ),
  options(
    apiValue: 'options',
    label: 'Opcoes',
    helperText: 'O cardapio oferece variedade e boas alternativas?',
  ),
  infrastructure(
    apiValue: 'infrastructure',
    label: 'Infraestrutura',
    helperText: 'Ambiente, conforto e estrutura apoiaram a experiencia?',
  );

  const ReviewCriterionCode({
    required this.apiValue,
    required this.label,
    required this.helperText,
  });

  final String apiValue;
  final String label;
  final String helperText;

  static const orderedValues = <ReviewCriterionCode>[
    ReviewCriterionCode.taste,
    ReviewCriterionCode.service,
    ReviewCriterionCode.options,
    ReviewCriterionCode.infrastructure,
  ];

  static ReviewCriterionCode fromApiValue(String value) {
    return ReviewCriterionCode.values.firstWhere(
      (item) => item.apiValue == value,
      orElse: () => throw ArgumentError.value(
        value,
        'value',
        'Criterio invalido.',
      ),
    );
  }
}
