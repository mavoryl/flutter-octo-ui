import 'package:octo_tokens_gen/src/mapping.dart';
import 'package:test/test.dart';

void main() {
  group('kPrimerColorGroups', () {
    test('covers every OctoColorScheme colour group', () {
      expect(
        kPrimerColorGroups.map((g) => g.field),
        ['canvas', 'fg', 'border', 'neutral', 'accent', 'success', 'attention', 'danger'],
      );
    });

    test('describes all 32 colour leaves', () {
      final total = kPrimerColorGroups.fold<int>(0, (sum, g) => sum + g.leaves.length);
      expect(total, 32);
    });

    test('every leaf names a non-empty Primer token', () {
      for (final group in kPrimerColorGroups) {
        for (final entry in group.leaves.entries) {
          expect(
            entry.value,
            isNotEmpty,
            reason: '${group.field}.${entry.key} has no Primer token',
          );
        }
      }
    });

    test('group class names match the octo_ui token classes', () {
      expect(
        kPrimerColorGroups.map((g) => g.className),
        [
          'OctoCanvasColors',
          'OctoForegroundColors',
          'OctoBorderColors',
          'OctoNeutralColors',
          'OctoAccentColors',
          'OctoSuccessColors',
          'OctoAttentionColors',
          'OctoDangerColors',
        ],
      );
    });
  });

  group('kPrimerPalettes', () {
    test('targets the four shipped palettes', () {
      expect(
        kPrimerPalettes.map((p) => p.constantName),
        [
          'kOctoLightStandard',
          'kOctoLightHighContrast',
          'kOctoDarkStandard',
          'kOctoDarkHighContrast',
        ],
      );
    });

    test('each palette names the Primer theme it reads', () {
      expect(
        kPrimerPalettes.map((p) => p.primerTheme),
        ['light', 'light-high-contrast', 'dark', 'dark-high-contrast'],
      );
    });
  });

  group('kPrimerBreakpointTokens', () {
    test('maps all six OctoBreakpoints fields', () {
      expect(kPrimerBreakpointTokens.keys, ['xs', 'sm', 'md', 'lg', 'xl', 'xxl']);
    });
  });
}
