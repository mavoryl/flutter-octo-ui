import 'dart:convert';
import 'dart:io';

import 'package:octo_tokens_gen/src/emitter.dart';
import 'package:octo_tokens_gen/src/mapping.dart';
import 'package:octo_tokens_gen/src/snapshot.dart';
import 'package:test/test.dart';

PrimerSnapshot _snapshot({String colour = '#123456'}) => PrimerSnapshot.parse(
      jsonEncode(<String, Object?>{
        'source': <String, Object?>{
          'package': '@primer/primitives',
          'version': '11.10.0',
          'tarballSha256': 'f' * 64,
        },
        'themes': <String, Object?>{
          for (final palette in kPrimerPalettes)
            palette.primerTheme: <String, Object?>{
              for (final token in kPrimerColorTokens) token: colour,
            },
        },
        'breakpoints': <String, Object?>{
          'breakpoint-xsmall': 320,
          'breakpoint-small': 544,
          'breakpoint-medium': 768,
          'breakpoint-large': 1012,
          'breakpoint-xlarge': 1280,
          'breakpoint-xxlarge': 1400,
        },
      }),
    );

void main() {
  group('dartColorLiteral', () {
    test('opaque six-digit hex gets an FF alpha channel', () {
      expect(dartColorLiteral('#ffffff'), 'Color(0xFFFFFFFF)');
      expect(dartColorLiteral('#1f2328'), 'Color(0xFF1F2328)');
    });

    test('eight-digit hex moves alpha to the front', () {
      expect(dartColorLiteral('#1f232826'), 'Color(0x261F2328)');
      expect(dartColorLiteral('#54aeff66'), 'Color(0x6654AEFF)');
    });

    test('accepts uppercase input', () {
      expect(dartColorLiteral('#AABBCC'), 'Color(0xFFAABBCC)');
    });

    test('rejects anything that is not a 6- or 8-digit hex colour', () {
      expect(() => dartColorLiteral('#fff'), throwsFormatException);
      expect(() => dartColorLiteral('rgb(1,2,3)'), throwsFormatException);
      expect(() => dartColorLiteral('#12345g'), throwsFormatException);
      expect(() => dartColorLiteral(''), throwsFormatException);
    });
  });

  group('emitTokens', () {
    test('records provenance in the header so the file traces to a version', () {
      final dart = emitTokens(_snapshot());

      expect(dart, contains('GENERATED CODE'));
      expect(dart, contains('@primer/primitives 11.10.0'));
      expect(dart, contains('f' * 64));
      expect(dart, contains('tools/primer_primitives_snapshot.json'));
    });

    test('emits one constant per shipped palette', () {
      final dart = emitTokens(_snapshot());

      for (final palette in kPrimerPalettes) {
        expect(dart, contains('const OctoColorScheme ${palette.constantName} ='));
      }
    });

    test('carries brightness and variant into each palette', () {
      final dart = emitTokens(_snapshot());

      expect(dart, contains('brightness: Brightness.light'));
      expect(dart, contains('brightness: Brightness.dark'));
      expect(dart, contains('variant: OctoColorSchemeVariant.standard'));
      expect(dart, contains('variant: OctoColorSchemeVariant.highContrast'));
    });

    test('emits every colour group with every leaf', () {
      final dart = emitTokens(_snapshot());

      for (final group in kPrimerColorGroups) {
        expect(dart, contains('${group.field}: ${group.className}('));
        for (final leaf in group.leaves.keys) {
          expect(dart, contains('$leaf: Color(0xFF123456)'), reason: 'missing $leaf');
        }
      }
    });

    test('emits the breakpoint scale as top-level constants', () {
      final dart = emitTokens(_snapshot());

      expect(dart, contains('const double kOctoBreakpointXs = 320;'));
      expect(dart, contains('const double kOctoBreakpointXxl = 1400;'));
    });

    test('is deterministic — same snapshot, byte-identical output', () {
      expect(emitTokens(_snapshot()), emitTokens(_snapshot()));
    });

    test('output survives dart format unchanged', () async {
      final dir = await Directory.systemTemp.createTemp('octo_tokens_gen');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/primer_tokens.g.dart');
      await file.writeAsString(emitTokens(_snapshot()));

      final result = await Process.run('dart', <String>[
        'format',
        '--output=none',
        '--set-exit-if-changed',
        '--page-width=100',
        file.path,
      ]);

      expect(
        result.exitCode,
        0,
        reason: 'dart format would rewrite the generated file:\n${result.stdout}',
      );
    });
  });
}
