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
  group('OctoAvatar', () {
    testWidgets('initials render when no image is provided', (tester) async {
      await _pump(
        tester,
        const OctoAvatar(initials: 'MA', semanticLabel: 'Marat'),
      );
      expect(find.text('MA'), findsOneWidget);
    });

    testWidgets('size maps to a square box of the right diameter', (tester) async {
      await _pump(
        tester,
        const OctoAvatar(
          initials: 'X',
          size: OctoAvatarSize.lg,
          semanticLabel: 'X',
        ),
      );
      // Find the inner SizedBox of the rendered avatar.
      final sized = tester.widgetList<SizedBox>(find.byType(SizedBox)).firstWhere(
            (s) => s.width == 48 && s.height == 48,
          );
      expect(sized.width, 48);
      expect(sized.height, 48);
    });

    testWidgets('square shape uses theme.radii.medium instead of full circle', (tester) async {
      await _pump(
        tester,
        const OctoAvatar(
          initials: 'O',
          shape: OctoAvatarShape.square,
          semanticLabel: 'O',
        ),
      );
      final theme = OctoThemeData.light();
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
      final radius = (clip.borderRadius as BorderRadius).topLeft;
      expect(radius.x, theme.radii.medium);
    });

    testWidgets('Semantics is image + label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoAvatar(initials: 'MA', semanticLabel: 'Marat Shakirov'),
      );
      final node = tester.getSemantics(find.byType(OctoAvatar));
      expect(node.getSemanticsData().flagsCollection.isImage, isTrue);
      expect(node.label, contains('Marat Shakirov'));
      handle.dispose();
    });

    testWidgets('passing both imageUrl and imageProvider fails the assertion', (tester) async {
      expect(
        () => OctoAvatar(
          imageUrl: 'https://example.com/a.png',
          imageProvider: const AssetImage('foo.png'),
          semanticLabel: 'a',
        ),
        throwsAssertionError,
      );
    });
  });
}
