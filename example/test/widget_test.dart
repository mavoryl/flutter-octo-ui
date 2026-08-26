import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';
import 'package:octo_ui_example/main.dart';

void main() {
  // pumpAndSettle would hang throughout this file — the demo ships an
  // indeterminate OctoProgressBar and animated skeletons. Pump a single
  // frame past the initial mount so the inherited MaterialApp's first build
  // resolves, then look at what is on screen.

  testWidgets('the dashboard is the landing screen', (tester) async {
    await tester.pumpWidget(const KitchenSinkApp());
    await tester.pump();

    expect(find.text('Service health'), findsOneWidget);
    expect(find.text('checkout-api'), findsOneWidget);
    expect(find.text('Incident feed'), findsOneWidget);
  });

  testWidgets('the dashboard filters its table down to nothing',
      (tester) async {
    await tester.pumpWidget(const KitchenSinkApp());
    await tester.pump();

    await tester.enterText(
        find.byType(OctoTextField).first, 'nothing-matches-this');
    await tester.pump();

    expect(find.text('checkout-api'), findsNothing);
    expect(find.text('No services match these filters'), findsOneWidget);
  });

  testWidgets('the kitchen sink is reachable from the dashboard',
      (tester) async {
    await tester.pumpWidget(const KitchenSinkApp());
    await tester.pump();

    await tester.tap(find.text('Kitchen sink'));
    await tester.pump();

    expect(find.text('octo_ui kitchen sink'), findsOneWidget);
    expect(find.text('Labels'), findsOneWidget);
  });

  testWidgets('the dashboard is reachable back from the kitchen sink',
      (tester) async {
    await tester.pumpWidget(const KitchenSinkApp());
    await tester.pump();
    await tester.tap(find.text('Kitchen sink'));
    await tester.pump();

    await tester.tap(find.text('Dashboard'));
    await tester.pump();

    expect(find.text('Service health'), findsOneWidget);
  });
}
