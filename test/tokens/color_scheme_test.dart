import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

void main() {
  group('OctoColorScheme', () {
    test('standard light/dark constructors produce distinct schemes', () {
      final light = OctoColorScheme.light();
      final dark = OctoColorScheme.dark();
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light, isNot(equals(dark)));
    });

    test('non-standard variants throw UnimplementedError (ADR-0005)', () {
      expect(
        () => OctoColorScheme.light(
          variant: OctoColorSchemeVariant.highContrast,
        ),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => OctoColorScheme.dark(
          variant: OctoColorSchemeVariant.protanopia,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('== and hashCode are value-based', () {
      final a = OctoColorScheme.light();
      final b = OctoColorScheme.light();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith overrides only the named field', () {
      final base = OctoColorScheme.light();
      final patched = base.copyWith(
        accent: base.accent.copyWith(fg: const Color(0xFFAABBCC)),
      );
      expect(patched.accent.fg, const Color(0xFFAABBCC));
      expect(patched.canvas, base.canvas);
      expect(patched.fg, base.fg);
      expect(patched, isNot(equals(base)));
    });

    test('lerp(t=0) == a and lerp(t=1) == b', () {
      final a = OctoColorScheme.light();
      final b = OctoColorScheme.dark();
      expect(OctoColorScheme.lerp(a, b, 0), equals(a));
      expect(OctoColorScheme.lerp(a, b, 1), equals(b));
    });

    test('lerp(identical, identical, t) returns same instance', () {
      final a = OctoColorScheme.light();
      expect(identical(OctoColorScheme.lerp(a, a, 0.4), a), isTrue);
    });
  });

  group('WCAG AA contrast (ADR-0008)', () {
    void expectContrast(
      Color foreground,
      Color background,
      double minRatio,
      String label,
    ) {
      final ratio = _contrast(foreground, background);
      expect(
        ratio,
        greaterThanOrEqualTo(minRatio),
        reason: '$label contrast ${ratio.toStringAsFixed(2)}:1 < $minRatio:1',
      );
    }

    for (final entry in <String, OctoColorScheme>{
      'light': OctoColorScheme.light(),
      'dark': OctoColorScheme.dark(),
    }.entries) {
      final name = entry.key;
      final scheme = entry.value;

      test('$name: fg.default on canvas.default >= 4.5:1', () {
        expectContrast(
          scheme.fg.defaultColor,
          scheme.canvas.defaultColor,
          4.5,
          '$name fg.default/canvas.default',
        );
      });

      test('$name: fg.muted on canvas.default >= 4.5:1', () {
        expectContrast(
          scheme.fg.muted,
          scheme.canvas.defaultColor,
          4.5,
          '$name fg.muted/canvas.default',
        );
      });

      // Primary button-grade backgrounds: 4.5:1 (body text on emphasis).
      test('$name: fg.onEmphasis on primary *.emphasis >= 4.5:1', () {
        expectContrast(
          scheme.fg.onEmphasis,
          scheme.accent.emphasis,
          4.5,
          '$name onEmphasis/accent',
        );
        expectContrast(
          scheme.fg.onEmphasis,
          scheme.danger.emphasis,
          4.5,
          '$name onEmphasis/danger',
        );
        expectContrast(
          scheme.fg.onEmphasis,
          scheme.neutral.emphasis,
          4.5,
          '$name onEmphasis/neutral',
        );
      });

      // Banner-grade status backgrounds use Flash with bodyEmphasis text
      // (14pt 600 — qualifies as WCAG large UI text). Target is 3:1.
      test('$name: fg.onEmphasis on status *.emphasis >= 3:1', () {
        expectContrast(
          scheme.fg.onEmphasis,
          scheme.success.emphasis,
          3.0,
          '$name onEmphasis/success',
        );
        expectContrast(
          scheme.fg.onEmphasis,
          scheme.attention.emphasis,
          3.0,
          '$name onEmphasis/attention',
        );
      });
    }
  });
}

/// WCAG 2.1 relative luminance for an opaque sRGB color.
double _relativeLuminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color fg, Color bg) {
  final lf = _relativeLuminance(fg);
  final lb = _relativeLuminance(bg);
  final hi = lf > lb ? lf : lb;
  final lo = lf > lb ? lb : lf;
  return (hi + 0.05) / (lo + 0.05);
}
