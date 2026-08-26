import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(
        data: OctoThemeData.light(),
        child: Center(child: child),
      ),
    ),
  );
}

void main() {
  group('OctoStateLabel', () {
    testWidgets('renders label + variant-implied icon', (tester) async {
      await _pump(
        tester,
        const OctoStateLabel(label: 'Open', variant: OctoStateLabelVariant.open),
      );
      expect(find.text('Open'), findsOneWidget);
      expect(find.byIcon(OctIcons.git_pull_request_16), findsOneWidget);
    });

    testWidgets('variant maps to the right default icon', (tester) async {
      const cases = {
        OctoStateLabelVariant.open: OctIcons.git_pull_request_16,
        OctoStateLabelVariant.closed: OctIcons.issue_closed_16,
        OctoStateLabelVariant.merged: OctIcons.git_merge_16,
        OctoStateLabelVariant.draft: OctIcons.git_pull_request_draft_16,
      };
      for (final entry in cases.entries) {
        await _pump(
          tester,
          OctoStateLabel(label: entry.key.name, variant: entry.key),
        );
        expect(find.byIcon(entry.value), findsOneWidget, reason: '${entry.key}');
      }
    });

    testWidgets('icon override beats the variant default', (tester) async {
      await _pump(
        tester,
        const OctoStateLabel(
          label: 'Stale',
          variant: OctoStateLabelVariant.attention,
          icon: OctIcons.clock_16,
        ),
      );
      expect(find.byIcon(OctIcons.clock_16), findsOneWidget);
      expect(find.byIcon(OctIcons.git_pull_request_16), findsNothing);
    });

    testWidgets('high emphasis fills with .emphasis background', (tester) async {
      final theme = OctoThemeData.light();
      await _pump(
        tester,
        const OctoStateLabel(label: 'Open', variant: OctoStateLabelVariant.open),
      );
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(OctoStateLabel),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((box.decoration as BoxDecoration).color, theme.colors.success.emphasis);
    });

    testWidgets('low emphasis uses .subtle background + .fg foreground', (tester) async {
      final theme = OctoThemeData.light();
      await _pump(
        tester,
        const OctoStateLabel(
          label: 'Merged',
          variant: OctoStateLabelVariant.merged,
          emphasis: OctoStateLabelEmphasis.low,
        ),
      );
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(OctoStateLabel),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((box.decoration as BoxDecoration).color, theme.colors.accent.subtle);
      final text = tester.widget<Text>(find.text('Merged'));
      expect(text.style!.color, theme.colors.accent.fg);
    });

    testWidgets('shrinks instead of overflowing a narrow column', (tester) async {
      // Status pills live in table cells, and a table cell is exactly where
      // the available width is decided by something other than the label.
      await _pump(
        tester,
        const SizedBox(
          width: 60,
          child: OctoStateLabel(
            label: 'Maintenance',
            variant: OctoStateLabelVariant.draft,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('semanticLabel overrides the visible text for AT', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoStateLabel(
          label: 'M',
          variant: OctoStateLabelVariant.merged,
          semanticLabel: 'Merged pull request',
        ),
      );
      final data = tester.getSemantics(find.byType(OctoStateLabel)).getSemanticsData();
      expect(data.label, 'Merged pull request');
      handle.dispose();
    });
  });
}
