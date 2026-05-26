import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

void main() {
  group('OctoSpacing', () {
    test('default scale matches Primer baseline', () {
      const s = OctoSpacing();
      expect(s.scale(0), 0);
      expect(s.scale(4), 8);
      expect(s.scale(6), 16);
      expect(s.scale(7), 24);
    });

    test('scale assertion catches out-of-range step in debug', () {
      const s = OctoSpacing();
      expect(() => s.scale(-1), throwsA(isA<AssertionError>()));
      expect(() => s.scale(s.steps.length), throwsA(isA<AssertionError>()));
    });

    test('indexFor is inverse of scale for known values', () {
      const s = OctoSpacing();
      expect(s.indexFor(16), 6);
      expect(s.indexFor(999), -1);
    });

    test('semantic aliases default to Primer-like values', () {
      const s = OctoSpacing();
      expect(s.gap.md, 12);
      expect(s.inset.lg, 16);
    });

    test('== and hashCode are value-based', () {
      const a = OctoSpacing();
      const b = OctoSpacing();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith respects fields', () {
      const base = OctoSpacing();
      final patched = base.copyWith(
        gap: const OctoGap(xs: 1, sm: 2, md: 3, lg: 4, xl: 5),
      );
      expect(patched.gap.md, 3);
      expect(patched.inset, base.inset);
      expect(patched, isNot(equals(base)));
    });

    test('lerp endpoints', () {
      const a = OctoSpacing();
      final b = a.copyWith(
        gap: const OctoGap(xs: 10, sm: 20, md: 30, lg: 40, xl: 50),
      );
      expect(OctoSpacing.lerp(a, b, 0), equals(a));
      expect(OctoSpacing.lerp(a, b, 1), equals(b));
      expect(OctoSpacing.lerp(a, b, 0.5).gap.md, (12 + 30) / 2);
    });
  });
}
