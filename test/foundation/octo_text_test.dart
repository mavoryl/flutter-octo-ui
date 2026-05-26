import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<TextStyle> _captureStyle(WidgetTester tester, Widget octoText) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: octoText),
    ),
  );
  final text = tester.widget<Text>(find.byType(Text));
  return text.style!;
}

void main() {
  group('OctoText', () {
    testWidgets('default kind reads theme.body and applies fg.defaultColor', (tester) async {
      final style = await _captureStyle(tester, const OctoText('hi'));
      final theme = OctoThemeData.light();
      expect(style.fontSize, theme.typography.body.fontSize);
      expect(style.color, theme.colors.fg.defaultColor);
    });

    testWidgets('kind=title pulls theme.title', (tester) async {
      final style = await _captureStyle(
        tester,
        const OctoText('hi', kind: OctoTextKind.title),
      );
      expect(style.fontSize, OctoThemeData.light().typography.title.fontSize);
    });

    testWidgets('explicit color wins over theme default', (tester) async {
      const red = Color(0xFFFF0000);
      final style = await _captureStyle(tester, const OctoText('hi', color: red));
      expect(style.color, red);
    });

    testWidgets('OctoText.styled bypasses kind mapping', (tester) async {
      const custom = TextStyle(fontSize: 42);
      final style = await _captureStyle(tester, const OctoText.styled('hi', style: custom));
      expect(style.fontSize, 42);
    });
  });
}
