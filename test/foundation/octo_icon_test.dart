import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<Icon> _capture(WidgetTester tester, Widget icon) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: icon),
    ),
  );
  return tester.widget<Icon>(find.byType(Icon));
}

void main() {
  group('OctoIcon', () {
    const sample = IconData(0xe000, fontFamily: 'MaterialIcons');

    testWidgets('default size=medium=16, default color=fg.defaultColor', (tester) async {
      final icon = await _capture(tester, const OctoIcon(sample));
      expect(icon.size, 16);
      expect(icon.color, OctoThemeData.light().colors.fg.defaultColor);
    });

    testWidgets('small=12, large=24', (tester) async {
      final small = await _capture(tester, const OctoIcon(sample, size: OctoIconSize.small));
      final large = await _capture(tester, const OctoIcon(sample, size: OctoIconSize.large));
      expect(small.size, 12);
      expect(large.size, 24);
    });

    testWidgets('OctoIcon.sized respects custom size', (tester) async {
      final icon = await _capture(tester, const OctoIcon.sized(sample, size: 20));
      expect(icon.size, 20);
    });

    testWidgets('explicit color wins', (tester) async {
      const red = Color(0xFFFF0000);
      final icon = await _capture(tester, const OctoIcon(sample, color: red));
      expect(icon.color, red);
    });
  });
}
