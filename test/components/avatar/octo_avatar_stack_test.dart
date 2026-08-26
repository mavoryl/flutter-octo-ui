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

Finder _avatarWith(String initials) =>
    find.byWidgetPredicate((w) => w is OctoAvatar && w.initials == initials);

double _leftOf(WidgetTester tester, String initials) => tester.getTopLeft(_avatarWith(initials)).dx;

const _three = [
  OctoAvatar(initials: 'A', semanticLabel: 'Ann'),
  OctoAvatar(initials: 'B', semanticLabel: 'Bob'),
  OctoAvatar(initials: 'C', semanticLabel: 'Cleo'),
];

void main() {
  group('OctoAvatar.dimension', () {
    test('exposes the diameter of each size bucket', () {
      const cases = {
        OctoAvatarSize.xs: 16.0,
        OctoAvatarSize.sm: 20.0,
        OctoAvatarSize.md: 32.0,
        OctoAvatarSize.lg: 48.0,
        OctoAvatarSize.xl: 64.0,
      };
      for (final entry in cases.entries) {
        final avatar = OctoAvatar(size: entry.key, semanticLabel: 'x');
        expect(avatar.dimension, entry.value, reason: '${entry.key}');
      }
    });
  });

  group('OctoAvatarStack', () {
    testWidgets('renders every avatar when maxVisible is null', (tester) async {
      await _pump(tester, const OctoAvatarStack(avatars: _three));
      expect(find.byType(OctoAvatar), findsNWidgets(3));
    });

    testWidgets('renders nothing for an empty list', (tester) async {
      await _pump(tester, const OctoAvatarStack(avatars: []));
      expect(find.byType(OctoAvatar), findsNothing);
    });

    testWidgets('overlaps avatars by overlapRatio of their diameter', (tester) async {
      await _pump(tester, const OctoAvatarStack(avatars: _three));
      // md avatars are 32 px wide; the default 0.3 ratio moves each
      // subsequent avatar 32 * 0.7 = 22.4 px to the right.
      expect(_leftOf(tester, 'B') - _leftOf(tester, 'A'), closeTo(22.4, 0.01));
    });

    testWidgets('overlapRatio drives the step between avatars', (tester) async {
      await _pump(tester, const OctoAvatarStack(avatars: _three, overlapRatio: 0.5));
      expect(_leftOf(tester, 'B') - _leftOf(tester, 'A'), closeTo(16, 0.01));
    });

    testWidgets('total width covers all avatars including the last full circle', (tester) async {
      await _pump(tester, const OctoAvatarStack(avatars: _three));
      // 2 steps of 22.4 px + one full 32 px avatar.
      expect(tester.getSize(find.byType(OctoAvatarStack)).width, closeTo(76.8, 0.01));
    });

    testWidgets('the first avatar paints on top of the second', (tester) async {
      await _pump(tester, const OctoAvatarStack(avatars: _three));
      // Overlapping region belongs to the earlier avatar, so a hit test in
      // the overlap resolves to 'Ann'.
      final stack = tester.widget<Stack>(
        find.descendant(of: find.byType(OctoAvatarStack), matching: find.byType(Stack)).first,
      );
      // Later children paint on top in a Stack, so the visual order must be
      // reversed: 'Ann' is built last.
      final labels = stack.children
          .map(
            (c) => (find
                    .descendant(of: find.byWidget(c), matching: find.byType(OctoAvatar))
                    .evaluate()
                    .single
                    .widget as OctoAvatar)
                .semanticLabel,
          )
          .toList();
      expect(labels, ['Cleo', 'Bob', 'Ann']);
    });

    testWidgets('maxVisible truncates and adds an overflow counter', (tester) async {
      await _pump(tester, const OctoAvatarStack(avatars: _three, maxVisible: 2));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('overflow counter carries a default semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoAvatarStack(avatars: _three, maxVisible: 1));
      expect(tester.getSemantics(_avatarWith('+2')).label, '2 more');
      handle.dispose();
    });

    testWidgets('overflowLabelBuilder overrides the counter label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoAvatarStack(
          avatars: _three,
          maxVisible: 1,
          overflowLabelBuilder: (n) => 'and $n other people',
        ),
      );
      expect(tester.getSemantics(_avatarWith('+2')).label, 'and 2 other people');
      handle.dispose();
    });

    testWidgets('no overflow counter when maxVisible covers the list', (tester) async {
      await _pump(tester, const OctoAvatarStack(avatars: _three, maxVisible: 3));
      expect(find.byType(OctoAvatar), findsNWidgets(3));
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('avatars are ringed with the canvas colour to separate them', (tester) async {
      await _pump(tester, const OctoAvatarStack(avatars: _three));
      final theme = OctoThemeData.light();
      final ring = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).first;
      final dec = ring.decoration as BoxDecoration;
      expect((dec.border! as Border).top.color, theme.colors.canvas.defaultColor);
    });
  });
}
