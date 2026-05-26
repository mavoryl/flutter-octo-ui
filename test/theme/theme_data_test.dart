import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

void main() {
  group('OctoThemeData', () {
    test('light != dark', () {
      final light = OctoThemeData.light();
      final dark = OctoThemeData.dark();
      expect(light, isNot(equals(dark)));
    });

    test('== / hashCode are value-based', () {
      final a = OctoThemeData.light();
      final b = OctoThemeData.light();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith overrides only named fields', () {
      final base = OctoThemeData.light();
      final patched = base.copyWith(radii: const OctoRadius(medium: 99));
      expect(patched.radii.medium, 99);
      expect(patched.colors, base.colors);
      expect(patched, isNot(equals(base)));
    });

    test('lerp(t=0) == this, lerp(t=1) == other', () {
      final a = OctoThemeData.light();
      final b = OctoThemeData.dark();
      expect(a.lerp(b, 0), equals(a));
      expect(a.lerp(b, 1), equals(b));
    });

    test('lerp returns this when other is not OctoThemeData', () {
      final a = OctoThemeData.light();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
