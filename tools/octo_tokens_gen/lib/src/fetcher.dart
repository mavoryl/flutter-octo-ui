import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:octo_tokens_gen/src/mapping.dart';
import 'package:octo_tokens_gen/src/snapshot.dart';

/// npm package the tokens come from.
const String kPrimerPackage = '@primer/primitives';

const String _registry = 'https://registry.npmjs.org';

/// Downloads [version] of [kPrimerPackage] and trims it into a snapshot.
///
/// Network access happens here and only here — [snapshotFromTarball] does the
/// actual work and is exercised offline in the tests.
Future<PrimerSnapshot> fetchSnapshot(String version) async {
  final client = HttpClient();
  try {
    final path = kPrimerPackage.replaceFirst('@', '').replaceFirst('/', '%2f');
    final name = kPrimerPackage.split('/').last;
    final url = Uri.parse('$_registry/$kPrimerPackage/-/$name-$version.tgz');
    final legacy = Uri.parse('$_registry/@$path/-/$name-$version.tgz');

    final bytes = await _get(client, url) ?? await _get(client, legacy);
    if (bytes == null) {
      throw StateError('could not download $kPrimerPackage $version from $_registry');
    }
    return snapshotFromTarball(bytes, version: version);
  } finally {
    client.close(force: true);
  }
}

Future<Uint8List?> _get(HttpClient client, Uri url) async {
  final response = await (await client.getUrl(url)).close();
  if (response.statusCode != HttpStatus.ok) {
    await response.drain<void>();
    return null;
  }
  final chunks = <int>[];
  await response.forEach(chunks.addAll);
  return Uint8List.fromList(chunks);
}

/// Trims a downloaded npm tarball down to the tokens the mapping reads.
///
/// Upstream ships ~1000 tokens per theme across five output formats and 55 MB
/// of `dist/`; the committed snapshot keeps only the few dozen values octo_ui
/// consumes. A token that upstream renamed or dropped fails here, named, so
/// drift surfaces at fetch time rather than as a wrong colour later.
PrimerSnapshot snapshotFromTarball(Uint8List tarball, {required String version}) {
  final archive = TarDecoder().decodeBytes(GZipDecoder().decodeBytes(tarball));

  Map<String, Object?> read(String path) {
    for (final file in archive.files) {
      if (file.name == 'package/dist/$path') {
        final decoded = jsonDecode(utf8.decode(file.content as List<int>));
        if (decoded is Map<String, Object?>) return decoded;
        throw FormatException('$path is not a JSON object');
      }
    }
    throw FormatException('the tarball has no dist/$path');
  }

  final themes = <String, Map<String, String>>{};
  for (final palette in kPrimerPalettes) {
    final theme = palette.primerTheme;
    final document = read('styleLint/functional/themes/$theme.json');
    final colours = <String, String>{};
    for (final token in kPrimerColorTokens) {
      final value = _value(document, token, theme);
      if (value is! String || value.isEmpty) {
        throw FormatException('theme "$theme" has no usable value for "$token"');
      }
      colours[token] = value;
    }
    themes[theme] = colours;
  }

  final sizes = read('styleLint/functional/size/breakpoints.json');
  final breakpoints = <String, double>{
    for (final token in kPrimerBreakpointTokens.values)
      token: _pixels(_value(sizes, token, 'breakpoints'), token),
  };

  return PrimerSnapshot(
    package: kPrimerPackage,
    version: version,
    tarballSha256: sha256.convert(tarball).toString(),
    themes: themes,
    breakpoints: breakpoints,
  );
}

Object? _value(Map<String, Object?> document, String token, String label) {
  final entry = document[token];
  if (entry is! Map<String, Object?>) {
    throw FormatException('"$label" has no token "$token"');
  }
  return entry[r'$value'];
}

/// Primer states sizes as a `['63.25rem', '1012px']` pair; we want the pixels.
double _pixels(Object? value, String token) {
  final scalar = value is List<Object?> && value.isNotEmpty ? value.last : value;
  if (scalar is num) return scalar.toDouble();
  if (scalar is String) {
    final px = double.tryParse(scalar.replaceAll('px', '').trim());
    if (px != null) return px;
  }
  throw FormatException('breakpoint "$token" has no pixel value (got $value)');
}
