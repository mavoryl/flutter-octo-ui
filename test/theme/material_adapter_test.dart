import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

ThemeData _build(OctoThemeData octo) => octo.toMaterialTheme();

void main() {
  group('OctoMaterialAdapter', () {
    test('uses Material 3 (ADR-0004)', () {
      expect(_build(OctoThemeData.light()).useMaterial3, isTrue);
    });

    test('colorScheme.primary maps to accent.emphasis (NOT accent.fg)', () {
      final octo = OctoThemeData.light();
      final material = _build(octo);
      expect(material.colorScheme.primary, octo.colors.accent.emphasis);
      expect(material.colorScheme.onPrimary, octo.colors.fg.onEmphasis);
    });

    test('colorScheme.error maps to danger.emphasis with onError=fg.onEmphasis', () {
      final octo = OctoThemeData.light();
      final material = _build(octo);
      expect(material.colorScheme.error, octo.colors.danger.emphasis);
      expect(material.colorScheme.onError, octo.colors.fg.onEmphasis);
    });

    test('surface / onSurface / outline pulled from canvas+border', () {
      final octo = OctoThemeData.light();
      final material = _build(octo);
      expect(material.colorScheme.surface, octo.colors.canvas.defaultColor);
      expect(material.colorScheme.onSurface, octo.colors.fg.defaultColor);
      expect(material.colorScheme.outline, octo.colors.border.defaultColor);
      expect(material.colorScheme.outlineVariant, octo.colors.border.muted);
    });

    test('splashFactory is NoSplash (Primer has no ripple)', () {
      expect(_build(OctoThemeData.light()).splashFactory, NoSplash.splashFactory);
    });

    test('brightness propagates from OctoColorScheme', () {
      expect(_build(OctoThemeData.light()).brightness, Brightness.light);
      expect(_build(OctoThemeData.dark()).brightness, Brightness.dark);
    });

    test('OctoThemeData is registered as ThemeExtension (ADR-0007)', () {
      final octo = OctoThemeData.light();
      final material = _build(octo);
      expect(material.extension<OctoThemeData>(), same(octo));
    });

    testWidgets('Theme.of(ctx).extension<OctoThemeData>() reachable in widget tree',
        (tester) async {
      final octo = OctoThemeData.dark();
      OctoThemeData? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: octo.toMaterialTheme(),
          home: Builder(
            builder: (ctx) {
              captured = Theme.of(ctx).extension<OctoThemeData>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, same(octo));
    });
  });
}
