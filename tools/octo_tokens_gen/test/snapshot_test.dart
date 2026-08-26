import 'dart:convert';

import 'package:octo_tokens_gen/src/mapping.dart';
import 'package:octo_tokens_gen/src/snapshot.dart';
import 'package:test/test.dart';

/// A structurally complete snapshot with placeholder values, so each test can
/// break exactly one thing and assert on that.
Map<String, Object?> _validJson() => <String, Object?>{
      'source': <String, Object?>{
        'package': '@primer/primitives',
        'version': '11.10.0',
        'tarballSha256': 'a' * 64,
      },
      'themes': <String, Object?>{
        for (final palette in kPrimerPalettes)
          palette.primerTheme: <String, Object?>{
            for (final token in kPrimerColorTokens) token: '#123456',
          },
      },
      'breakpoints': <String, Object?>{
        for (final token in kPrimerBreakpointTokens.values) token: 100,
      },
    };

void main() {
  group('PrimerSnapshot.parse', () {
    test('reads provenance from the source block', () {
      final snapshot = PrimerSnapshot.parse(jsonEncode(_validJson()));

      expect(snapshot.package, '@primer/primitives');
      expect(snapshot.version, '11.10.0');
      expect(snapshot.tarballSha256, 'a' * 64);
    });

    test('exposes colours per theme', () {
      final json = _validJson();
      (json['themes']! as Map<String, Object?>)['light'] = <String, Object?>{
        for (final token in kPrimerColorTokens) token: '#abcdef',
      };

      final snapshot = PrimerSnapshot.parse(jsonEncode(json));

      expect(snapshot.color('light', 'bgColor-default'), '#abcdef');
    });

    test('exposes breakpoints as numbers', () {
      final snapshot = PrimerSnapshot.parse(jsonEncode(_validJson()));
      expect(snapshot.breakpoint('breakpoint-small'), 100);
    });

    test('rejects a snapshot missing a theme the mapping needs', () {
      final json = _validJson();
      (json['themes']! as Map<String, Object?>).remove('dark-high-contrast');

      expect(
        () => PrimerSnapshot.parse(jsonEncode(json)),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('dark-high-contrast'),
          ),
        ),
      );
    });

    test('rejects a snapshot missing a token the mapping needs', () {
      final json = _validJson();
      (json['themes']! as Map<String, Object?>)['dark'] = <String, Object?>{
        for (final token in kPrimerColorTokens.where((t) => t != 'fgColor-muted')) token: '#123456',
      };

      expect(
        () => PrimerSnapshot.parse(jsonEncode(json)),
        throwsA(
          isA<FormatException>()
              .having((e) => e.message, 'message', contains('fgColor-muted'))
              .having((e) => e.message, 'message', contains('dark')),
        ),
      );
    });

    test('rejects a snapshot missing a breakpoint', () {
      final json = _validJson();
      (json['breakpoints']! as Map<String, Object?>).remove('breakpoint-xxlarge');

      expect(
        () => PrimerSnapshot.parse(jsonEncode(json)),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('breakpoint-xxlarge'),
          ),
        ),
      );
    });

    test('rejects a snapshot without provenance', () {
      final json = _validJson();
      (json['source']! as Map<String, Object?>).remove('version');

      expect(
        () => PrimerSnapshot.parse(jsonEncode(json)),
        throwsA(
          isA<FormatException>().having((e) => e.message, 'message', contains('version')),
        ),
      );
    });
  });

  group('PrimerSnapshot.encode', () {
    test('is stable across encodes so the committed file has no churn', () {
      final snapshot = PrimerSnapshot.parse(jsonEncode(_validJson()));
      expect(snapshot.encode(), snapshot.encode());
    });

    test('round-trips through parse', () {
      final snapshot = PrimerSnapshot.parse(jsonEncode(_validJson()));
      expect(PrimerSnapshot.parse(snapshot.encode()).encode(), snapshot.encode());
    });

    test('sorts token keys so upstream reordering is not a diff', () {
      final snapshot = PrimerSnapshot.parse(jsonEncode(_validJson()));
      final themes = (jsonDecode(snapshot.encode()) as Map<String, Object?>)['themes']!;
      final tokens = ((themes as Map<String, Object?>)['light']! as Map<String, Object?>).keys;

      expect(tokens.toList(), orderedEquals(tokens.toList()..sort()));
    });
  });
}
