import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

/// Semantic typography scale.
///
/// Component widgets read by semantic name only ([body], [bodyEmphasis],
/// [title], [heading], [label], [code]). Raw [TextStyle] tokens are exposed
/// for escape hatches, not for direct widget use.
@immutable
class OctoTypography {
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle bodyEmphasis;
  final TextStyle label;
  final TextStyle labelSmall;
  final TextStyle title;
  final TextStyle heading;
  final TextStyle code;

  const OctoTypography({
    required this.body,
    required this.bodySmall,
    required this.bodyEmphasis,
    required this.label,
    required this.labelSmall,
    required this.title,
    required this.heading,
    required this.code,
  });

  factory OctoTypography.standard() {
    const sans = <String>[
      '-apple-system',
      'BlinkMacSystemFont',
      'Segoe UI',
      'Helvetica',
      'Arial',
      'sans-serif',
    ];
    const mono = <String>[
      'SFMono-Regular',
      'Consolas',
      'Liberation Mono',
      'Menlo',
      'monospace',
    ];
    const base = TextStyle(
      fontFamilyFallback: sans,
      height: 1.5,
    );
    return OctoTypography(
      body: base.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: base.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
      bodyEmphasis: base.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      label: base.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: base.copyWith(fontSize: 10, fontWeight: FontWeight.w500),
      title: base.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      heading: base.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      code: const TextStyle(
        fontFamilyFallback: mono,
        fontSize: 12,
        height: 1.45,
      ),
    );
  }

  OctoTypography copyWith({
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? bodyEmphasis,
    TextStyle? label,
    TextStyle? labelSmall,
    TextStyle? title,
    TextStyle? heading,
    TextStyle? code,
  }) =>
      OctoTypography(
        body: body ?? this.body,
        bodySmall: bodySmall ?? this.bodySmall,
        bodyEmphasis: bodyEmphasis ?? this.bodyEmphasis,
        label: label ?? this.label,
        labelSmall: labelSmall ?? this.labelSmall,
        title: title ?? this.title,
        heading: heading ?? this.heading,
        code: code ?? this.code,
      );

  static OctoTypography lerp(OctoTypography a, OctoTypography b, double t) => identical(a, b)
      ? a
      : OctoTypography(
          body: TextStyle.lerp(a.body, b.body, t)!,
          bodySmall: TextStyle.lerp(a.bodySmall, b.bodySmall, t)!,
          bodyEmphasis: TextStyle.lerp(a.bodyEmphasis, b.bodyEmphasis, t)!,
          label: TextStyle.lerp(a.label, b.label, t)!,
          labelSmall: TextStyle.lerp(a.labelSmall, b.labelSmall, t)!,
          title: TextStyle.lerp(a.title, b.title, t)!,
          heading: TextStyle.lerp(a.heading, b.heading, t)!,
          code: TextStyle.lerp(a.code, b.code, t)!,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoTypography &&
          other.body == body &&
          other.bodySmall == bodySmall &&
          other.bodyEmphasis == bodyEmphasis &&
          other.label == label &&
          other.labelSmall == labelSmall &&
          other.title == title &&
          other.heading == heading &&
          other.code == code;

  @override
  int get hashCode => Object.hash(
        body,
        bodySmall,
        bodyEmphasis,
        label,
        labelSmall,
        title,
        heading,
        code,
      );
}
