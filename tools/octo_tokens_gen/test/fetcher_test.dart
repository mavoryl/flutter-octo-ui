import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:octo_tokens_gen/src/fetcher.dart';
import 'package:octo_tokens_gen/src/mapping.dart';
import 'package:test/test.dart';

/// Builds a tarball shaped like the npm package, carrying only the files the
/// trimmer reads.
Uint8List _tarball({
  Map<String, String>? colours,
  Map<String, Object?>? breakpoints,
  Set<String>? skipThemes,
}) {
  Map<String, Object?> wrap(Map<String, Object?> values) => <String, Object?>{
        for (final entry in values.entries)
          entry.key: <String, Object?>{r'$value': entry.value, r'$type': 'color'},
      };

  final archive = Archive();
  void add(String path, Object? json) {
    final bytes = utf8.encode(jsonEncode(json));
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  for (final palette in kPrimerPalettes) {
    if (skipThemes?.contains(palette.primerTheme) ?? false) continue;
    add(
      'package/dist/styleLint/functional/themes/${palette.primerTheme}.json',
      wrap(<String, Object?>{
        for (final token in kPrimerColorTokens) token: colours?[token] ?? '#123456',
      }),
    );
  }
  add(
    'package/dist/styleLint/functional/size/breakpoints.json',
    wrap(
      breakpoints ??
          <String, Object?>{
            'breakpoint-xsmall': <String>['20rem', '320px'],
            'breakpoint-small': <String>['34rem', '544px'],
            'breakpoint-medium': <String>['48rem', '768px'],
            'breakpoint-large': <String>['63.25rem', '1012px'],
            'breakpoint-xlarge': <String>['80rem', '1280px'],
            'breakpoint-xxlarge': <String>['87.5rem', '1400px'],
          },
    ),
  );

  return Uint8List.fromList(GZipEncoder().encode(TarEncoder().encode(archive))!);
}

void main() {
  group('snapshotFromTarball', () {
    test('records the requested version and the tarball digest', () {
      final snapshot = snapshotFromTarball(_tarball(), version: '11.10.0');

      expect(snapshot.package, '@primer/primitives');
      expect(snapshot.version, '11.10.0');
      expect(snapshot.tarballSha256, hasLength(64));
    });

    test('the digest tracks the bytes it came from', () {
      final a = snapshotFromTarball(_tarball(), version: '1.0.0');
      final b = snapshotFromTarball(
        _tarball(colours: <String, String>{'bgColor-default': '#abcdef'}),
        version: '1.0.0',
      );

      expect(a.tarballSha256, isNot(b.tarballSha256));
    });

    test('keeps only the tokens the mapping reads', () {
      final snapshot = snapshotFromTarball(_tarball(), version: '11.10.0');

      expect(snapshot.themes['light']!.keys.toSet(), kPrimerColorTokens);
    });

    test('reads colours per theme', () {
      final snapshot = snapshotFromTarball(
        _tarball(colours: <String, String>{'fgColor-default': '#0a0b0c'}),
        version: '11.10.0',
      );

      expect(snapshot.color('dark', 'fgColor-default'), '#0a0b0c');
    });

    test('takes the pixel value out of a rem/px pair', () {
      final snapshot = snapshotFromTarball(_tarball(), version: '11.10.0');

      expect(snapshot.breakpoint('breakpoint-large'), 1012);
      expect(snapshot.breakpoint('breakpoint-xxlarge'), 1400);
    });

    test('accepts a bare numeric breakpoint', () {
      final snapshot = snapshotFromTarball(
        _tarball(
          breakpoints: <String, Object?>{
            'breakpoint-xsmall': 320,
            'breakpoint-small': '544px',
            'breakpoint-medium': 768,
            'breakpoint-large': 1012,
            'breakpoint-xlarge': 1280,
            'breakpoint-xxlarge': 1400,
          },
        ),
        version: '11.10.0',
      );

      expect(snapshot.breakpoint('breakpoint-small'), 544);
    });

    test('names the theme file when upstream stops shipping it', () {
      expect(
        () => snapshotFromTarball(
          _tarball(skipThemes: <String>{'dark-high-contrast'}),
          version: '11.10.0',
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('dark-high-contrast'),
          ),
        ),
      );
    });

    test('names the token when upstream renames one away', () {
      expect(
        () => snapshotFromTarball(
          _tarball(colours: <String, String>{'fgColor-disabled': ''}),
          version: '11.10.0',
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('fgColor-disabled'),
          ),
        ),
      );
    });
  });
}
