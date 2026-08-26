import 'package:octo_tokens_gen/src/mapping.dart';
import 'package:octo_tokens_gen/src/snapshot.dart';

/// Path of the generated file, relative to the repository root.
const String kGeneratedTokensPath = 'lib/src/tokens/generated/primer_tokens.g.dart';

/// Path of the committed snapshot, relative to the repository root.
const String kSnapshotPath = 'tools/primer_primitives_snapshot.json';

final RegExp _hexColour = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

/// Converts a Primer CSS colour into a Dart `Color` literal.
///
/// Primer writes `#rrggbb` and `#rrggbbaa`; Dart wants `0xAARRGGBB`. Six-digit
/// input is opaque, so it gains an `FF` alpha channel.
String dartColorLiteral(String css) {
  if (!_hexColour.hasMatch(css)) {
    throw FormatException('"$css" is not a 6- or 8-digit hex colour');
  }
  final digits = css.substring(1).toUpperCase();
  final rgb = digits.substring(0, 6);
  final alpha = digits.length == 8 ? digits.substring(6, 8) : 'FF';
  return 'Color(0x$alpha$rgb)';
}

/// Renders [value] as a Dart numeric literal without a spurious `.0`.
String _number(double value) =>
    value == value.roundToDouble() ? value.round().toString() : value.toString();

/// `xs` → `kOctoBreakpointXs`.
String _breakpointConstant(String field) =>
    'kOctoBreakpoint${field[0].toUpperCase()}${field.substring(1)}';

/// Generates the Dart source for [snapshot].
///
/// Output is deterministic — the same snapshot always yields byte-identical
/// source, which is what lets `generate --check` act as a drift gate in CI.
/// Every argument list carries a trailing comma so `dart format` keeps the
/// layout as emitted instead of reflowing it.
String emitTokens(PrimerSnapshot snapshot) {
  final out = StringBuffer()
    ..writeln('// GENERATED CODE — DO NOT MODIFY BY HAND.')
    ..writeln('//')
    ..writeln('// Source:     ${snapshot.package} ${snapshot.version}')
    ..writeln('// Tarball:    sha256 ${snapshot.tarballSha256}')
    ..writeln('// Snapshot:   $kSnapshotPath')
    ..writeln('// Regenerate: dart run octo_tokens_gen generate')
    ..writeln('//')
    ..writeln('// The token-name mapping lives in')
    ..writeln('// tools/octo_tokens_gen/lib/src/mapping.dart. ADR-0010 records what the')
    ..writeln('// generator owns and what stays hand-written.')
    ..writeln()
    ..writeln("import 'dart:ui' show Brightness, Color;")
    ..writeln()
    ..writeln("import 'package:octo_ui/src/tokens/color_scheme.dart';");

  for (final palette in kPrimerPalettes) {
    out
      ..writeln()
      ..writeln('/// Primer `${palette.primerTheme}` palette.')
      ..writeln('const OctoColorScheme ${palette.constantName} = OctoColorScheme(')
      ..writeln('  brightness: Brightness.${palette.brightness},')
      ..writeln('  variant: OctoColorSchemeVariant.${palette.variant},');

    for (final group in kPrimerColorGroups) {
      out.writeln('  ${group.field}: ${group.className}(');
      for (final leaf in group.leaves.entries) {
        final css = snapshot.color(palette.primerTheme, leaf.value);
        out.writeln('    ${leaf.key}: ${dartColorLiteral(css)},');
      }
      out.writeln('  ),');
    }

    out.writeln(');');
  }

  for (final entry in kPrimerBreakpointTokens.entries) {
    final px = snapshot.breakpoint(entry.value);
    out
      ..writeln()
      ..writeln('/// `OctoBreakpoints.${entry.key}` — Primer `${entry.value}`.')
      ..writeln('const double ${_breakpointConstant(entry.key)} = ${_number(px)};');
  }

  return out.toString();
}
