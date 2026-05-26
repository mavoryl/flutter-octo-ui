import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

const _closeIcon = IconData(0xe5cd, fontFamily: 'MaterialIcons');

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: Center(child: child)),
    ),
  );
}

void main() {
  group('OctoIconButton', () {
    testWidgets('invokes onPressed on tap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoIconButton(
          icon: _closeIcon,
          onPressed: () => taps++,
          semanticLabel: 'Close',
        ),
      );
      await tester.tap(find.byType(OctoIconButton));
      expect(taps, 1);
    });

    testWidgets('semanticLabel reaches Semantics tree (no doubling)', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoIconButton(
          icon: _closeIcon,
          onPressed: () {},
          semanticLabel: 'Close dialog',
        ),
      );
      final node = tester.getSemantics(find.byType(OctoIconButton));
      expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
      expect(node.label, 'Close dialog');
      handle.dispose();
    });

    testWidgets('disabled when onPressed=null', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoIconButton(icon: _closeIcon, onPressed: null, semanticLabel: 'Close'),
      );
      final node = tester.getSemantics(find.byType(OctoIconButton));
      expect(node.getSemanticsData().flagsCollection.isEnabled, isFalse);
      handle.dispose();
    });

    testWidgets('size maps to OctoIcon size', (tester) async {
      await _pump(
        tester,
        OctoIconButton(
          icon: _closeIcon,
          onPressed: () {},
          semanticLabel: 'Close',
          size: OctoButtonSize.large,
        ),
      );
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 24);
    });
  });
}
