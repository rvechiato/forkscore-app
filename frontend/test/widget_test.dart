import 'package:flutter_test/flutter_test.dart';

import 'package:forkscore_frontend/app/app.dart';

void main() {
  testWidgets('renderiza a tela inicial do ForkScore', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp());

    expect(find.text('ForkScore'), findsOneWidget);
    expect(find.textContaining('Avalie restaurantes'), findsOneWidget);
  });
}
