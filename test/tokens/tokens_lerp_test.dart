import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

void main() {
  group('OctoRadius', () {
    test('round-trip', () {
      final a = OctoRadius.standard();
      final b = a.copyWith(medium: 10);
      expect(a, isNot(equals(b)));
      expect(b.copyWith(medium: a.medium), equals(a));
      expect(OctoRadius.lerp(a, b, 0), equals(a));
      expect(OctoRadius.lerp(a, b, 1), equals(b));
    });
  });

  group('OctoTypography', () {
    test('round-trip', () {
      final a = OctoTypography.standard();
      final b = a.copyWith(body: a.body.copyWith(fontSize: 99));
      expect(a, isNot(equals(b)));
      expect(OctoTypography.lerp(a, b, 0), equals(a));
      expect(OctoTypography.lerp(a, b, 1), equals(b));
    });
  });

  group('OctoShadows', () {
    test('round-trip', () {
      final a = OctoShadows.standard();
      final b = OctoShadows.standardDark();
      expect(a, isNot(equals(b)));
      expect(OctoShadows.lerp(a, b, 0), equals(a));
      expect(OctoShadows.lerp(a, b, 1), equals(b));
    });
  });

  group('OctoBreakpoints', () {
    test('round-trip', () {
      const a = OctoBreakpoints();
      final b = a.copyWith(md: 800);
      expect(a, isNot(equals(b)));
      expect(b.copyWith(md: a.md), equals(a));
      expect(OctoBreakpoints.lerp(a, b, 0), equals(a));
      expect(OctoBreakpoints.lerp(a, b, 1), equals(b));
    });
  });

  group('OctoAnimation', () {
    test('step-lerp at t=0.5 picks b', () {
      const a = OctoAnimation();
      final b = a.copyWith(fast: const Duration(milliseconds: 500));
      expect(OctoAnimation.lerp(a, b, 0.49), equals(a));
      expect(OctoAnimation.lerp(a, b, 0.5), equals(b));
    });
  });
}
