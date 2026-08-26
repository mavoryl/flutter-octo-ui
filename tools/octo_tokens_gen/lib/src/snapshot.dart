import 'dart:convert';

import 'package:octo_tokens_gen/src/mapping.dart';

/// A frozen slice of Primer Primitives, trimmed to the tokens the mapping
/// reads.
///
/// ADR-0009 requires the snapshot to be committed rather than fetched at build
/// time, so a generator run is reproducible from the repository alone. Parsing
/// validates against [kPrimerColorTokens] up front: a snapshot that cannot
/// satisfy the mapping fails here, with the missing token named, instead of
/// producing a half-populated palette.
class PrimerSnapshot {
  /// npm package the snapshot came from.
  final String package;

  /// Exact upstream version.
  final String version;

  /// sha256 of the upstream tarball, so a snapshot can be traced back.
  final String tarballSha256;

  /// Primer theme name → token name → CSS colour string.
  final Map<String, Map<String, String>> themes;

  /// Breakpoint token name → logical pixels.
  final Map<String, double> breakpoints;

  const PrimerSnapshot({
    required this.package,
    required this.version,
    required this.tarballSha256,
    required this.themes,
    required this.breakpoints,
  });

  /// Parses and validates a snapshot document.
  ///
  /// Throws [FormatException] naming the first structural problem found.
  factory PrimerSnapshot.parse(String json) {
    final root = _asMap(jsonDecode(json), 'root');
    final source = _asMap(root['source'], 'source');

    String provenance(String key) {
      final value = source[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('snapshot source.$key is missing or empty');
      }
      return value;
    }

    final rawThemes = _asMap(root['themes'], 'themes');
    final themes = <String, Map<String, String>>{};
    for (final palette in kPrimerPalettes) {
      final theme = palette.primerTheme;
      if (!rawThemes.containsKey(theme)) {
        throw FormatException('snapshot is missing theme "$theme"');
      }
      final raw = _asMap(rawThemes[theme], 'themes.$theme');
      final colours = <String, String>{};
      for (final token in kPrimerColorTokens) {
        final value = raw[token];
        if (value is! String || value.isEmpty) {
          throw FormatException('snapshot theme "$theme" is missing token "$token"');
        }
        colours[token] = value;
      }
      themes[theme] = colours;
    }

    final rawBreakpoints = _asMap(root['breakpoints'], 'breakpoints');
    final breakpoints = <String, double>{};
    for (final token in kPrimerBreakpointTokens.values) {
      final value = rawBreakpoints[token];
      if (value is! num) {
        throw FormatException('snapshot is missing breakpoint "$token"');
      }
      breakpoints[token] = value.toDouble();
    }

    return PrimerSnapshot(
      package: provenance('package'),
      version: provenance('version'),
      tarballSha256: provenance('tarballSha256'),
      themes: themes,
      breakpoints: breakpoints,
    );
  }

  static Map<String, Object?> _asMap(Object? value, String label) {
    if (value is! Map<String, Object?>) {
      throw FormatException('snapshot $label must be a JSON object');
    }
    return value;
  }

  /// Colour string for [token] in [theme].
  String color(String theme, String token) {
    final value = themes[theme]?[token];
    if (value == null) {
      throw FormatException('no colour "$token" in theme "$theme"');
    }
    return value;
  }

  /// Logical pixels for a breakpoint [token].
  double breakpoint(String token) {
    final value = breakpoints[token];
    if (value == null) {
      throw FormatException('no breakpoint "$token" in snapshot');
    }
    return value;
  }

  /// Canonical JSON for the committed snapshot file.
  ///
  /// Keys are sorted at every level: upstream reordering its own output must
  /// not show up as a diff in our repository.
  String encode() {
    Map<String, Object?> sorted(Map<String, Object?> input) => Map<String, Object?>.fromEntries(
          input.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
        );

    final document = <String, Object?>{
      'source': <String, Object?>{
        'package': package,
        'version': version,
        'tarballSha256': tarballSha256,
      },
      'themes': sorted(<String, Object?>{
        for (final entry in themes.entries) entry.key: sorted(entry.value),
      }),
      'breakpoints': sorted(<String, Object?>{
        for (final entry in breakpoints.entries)
          entry.key: entry.value == entry.value.roundToDouble() ? entry.value.round() : entry.value,
      }),
    };

    return '${const JsonEncoder.withIndent('  ').convert(document)}\n';
  }
}
