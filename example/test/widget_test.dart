import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui_example/main.dart';

void main() {
  testWidgets('kitchen sink boots and renders title', (tester) async {
    await tester.pumpWidget(const KitchenSinkApp());
    await tester.pumpAndSettle();
    expect(find.text('octo_ui kitchen sink'), findsOneWidget);
    expect(find.text('Labels'), findsOneWidget);
  });
}
