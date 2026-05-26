import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: Center(child: child)),
    ),
  );
}

void main() {
  group('OctoRadio', () {
    testWidgets('tapping an unselected radio sends its value', (tester) async {
      String? picked = 'apple';
      await _pump(
        tester,
        StatefulBuilder(
          builder: (_, setState) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OctoRadio<String>(
                value: 'apple',
                groupValue: picked,
                onChanged: (v) => setState(() => picked = v),
              ),
              const SizedBox(width: 16),
              OctoRadio<String>(
                value: 'banana',
                groupValue: picked,
                onChanged: (v) => setState(() => picked = v),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(OctoRadio<String>).at(1));
      expect(picked, 'banana');
    });

    testWidgets('tapping the already-selected radio is a no-op', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoRadio<String>(
          value: 'a',
          groupValue: 'a',
          onChanged: (_) => taps++,
        ),
      );
      await tester.tap(find.byType(OctoRadio<String>));
      expect(taps, 0);
    });

    testWidgets('Space activates the focused radio', (tester) async {
      String? picked;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (_, setState) => OctoRadio<String>(
            value: 'x',
            groupValue: picked,
            autofocus: true,
            onChanged: (v) => setState(() => picked = v),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(picked, 'x');
    });

    testWidgets('Semantics exposes inMutuallyExclusiveGroup + correct isChecked', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoRadio<String>(
          value: 'a',
          groupValue: 'a',
          onChanged: (_) {},
        ),
      );
      final flags =
          tester.getSemantics(find.byType(OctoRadio<String>)).getSemanticsData().flagsCollection;
      expect(flags.isInMutuallyExclusiveGroup, isTrue);
      expect(flags.isChecked, isTrue);
      handle.dispose();
    });
  });
}
