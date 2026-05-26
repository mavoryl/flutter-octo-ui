import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

/// Variant of the colour palette.
///
/// `standard` is the default Primer-like palette. `highContrast` tightens
/// contrast for low-vision users. The colourblind variants ship as enum slots
/// only — their concrete values land in a later milestone (ADR-0005).
enum OctoColorSchemeVariant {
  standard,
  highContrast,
  protanopia,
  deuteranopia,
  tritanopia,
}

@immutable
class OctoColorScheme with Diagnosticable {
  final Brightness brightness;
  final OctoColorSchemeVariant variant;
  final OctoCanvasColors canvas;
  final OctoForegroundColors fg;
  final OctoBorderColors border;
  final OctoNeutralColors neutral;
  final OctoAccentColors accent;
  final OctoSuccessColors success;
  final OctoAttentionColors attention;
  final OctoDangerColors danger;

  const OctoColorScheme({
    required this.brightness,
    required this.variant,
    required this.canvas,
    required this.fg,
    required this.border,
    required this.neutral,
    required this.accent,
    required this.success,
    required this.attention,
    required this.danger,
  });

  factory OctoColorScheme.light({
    OctoColorSchemeVariant variant = OctoColorSchemeVariant.standard,
  }) {
    switch (variant) {
      case OctoColorSchemeVariant.standard:
        return const OctoColorScheme(
          brightness: Brightness.light,
          variant: OctoColorSchemeVariant.standard,
          canvas: OctoCanvasColors(
            defaultColor: Color(0xFFFFFFFF),
            overlay: Color(0xFFFFFFFF),
            inset: Color(0xFFF6F8FA),
            subtle: Color(0xFFF6F8FA),
          ),
          fg: OctoForegroundColors(
            defaultColor: Color(0xFF1F2328),
            muted: Color(0xFF59636E),
            subtle: Color(0xFF6E7781),
            onEmphasis: Color(0xFFFFFFFF),
          ),
          border: OctoBorderColors(
            defaultColor: Color(0xFFD1D9E0),
            muted: Color(0xFFD8DEE4),
            subtle: Color(0x0D1F2328),
          ),
          neutral: OctoNeutralColors(
            fg: Color(0xFF59636E),
            emphasis: Color(0xFF59636E),
            emphasisPlus: Color(0xFF1F2328),
            muted: Color(0x33AFB8C1),
            subtle: Color(0x1F818B98),
          ),
          accent: OctoAccentColors(
            fg: Color(0xFF0969DA),
            emphasis: Color(0xFF0969DA),
            muted: Color(0x6654AEFF),
            subtle: Color(0xFFDDF4FF),
          ),
          success: OctoSuccessColors(
            fg: Color(0xFF1A7F37),
            emphasis: Color(0xFF1F883D),
            muted: Color(0x664AC26B),
            subtle: Color(0xFFDAFBE1),
          ),
          attention: OctoAttentionColors(
            fg: Color(0xFF9A6700),
            emphasis: Color(0xFF9A6700),
            muted: Color(0x66D4A72C),
            subtle: Color(0xFFFFF8C5),
          ),
          danger: OctoDangerColors(
            fg: Color(0xFFD1242F),
            emphasis: Color(0xFFCF222E),
            muted: Color(0x66FF8182),
            subtle: Color(0xFFFFEBE9),
          ),
        );
      case OctoColorSchemeVariant.highContrast:
      case OctoColorSchemeVariant.protanopia:
      case OctoColorSchemeVariant.deuteranopia:
      case OctoColorSchemeVariant.tritanopia:
        throw UnimplementedError(
          'OctoColorScheme.light(variant: $variant) is not implemented in 0.1.0. '
          'Shape reserved per ADR-0005; values land in a later milestone.',
        );
    }
  }

  factory OctoColorScheme.dark({
    OctoColorSchemeVariant variant = OctoColorSchemeVariant.standard,
  }) {
    switch (variant) {
      case OctoColorSchemeVariant.standard:
        return const OctoColorScheme(
          brightness: Brightness.dark,
          variant: OctoColorSchemeVariant.standard,
          canvas: OctoCanvasColors(
            defaultColor: Color(0xFF0D1117),
            overlay: Color(0xFF151B23),
            inset: Color(0xFF010409),
            subtle: Color(0xFF151B23),
          ),
          fg: OctoForegroundColors(
            defaultColor: Color(0xFFF0F6FC),
            muted: Color(0xFF9198A1),
            subtle: Color(0xFF6E7681),
            onEmphasis: Color(0xFFFFFFFF),
          ),
          border: OctoBorderColors(
            defaultColor: Color(0xFF3D444D),
            muted: Color(0xFF262C36),
            subtle: Color(0x14FFFFFF),
          ),
          neutral: OctoNeutralColors(
            fg: Color(0xFF9198A1),
            emphasis: Color(0xFF656C76),
            emphasisPlus: Color(0xFFF0F6FC),
            muted: Color(0x66656C76),
            subtle: Color(0x10656C76),
          ),
          accent: OctoAccentColors(
            fg: Color(0xFF4493F8),
            emphasis: Color(0xFF1F6FEB),
            muted: Color(0x664184E4),
            subtle: Color(0x264184E4),
          ),
          success: OctoSuccessColors(
            fg: Color(0xFF3FB950),
            emphasis: Color(0xFF238636),
            muted: Color(0x663FB950),
            subtle: Color(0x263FB950),
          ),
          attention: OctoAttentionColors(
            fg: Color(0xFFD29922),
            emphasis: Color(0xFF9E6A03),
            muted: Color(0x66D29922),
            subtle: Color(0x26D29922),
          ),
          danger: OctoDangerColors(
            fg: Color(0xFFF85149),
            emphasis: Color(0xFFDA3633),
            muted: Color(0x66F85149),
            subtle: Color(0x26F85149),
          ),
        );
      case OctoColorSchemeVariant.highContrast:
      case OctoColorSchemeVariant.protanopia:
      case OctoColorSchemeVariant.deuteranopia:
      case OctoColorSchemeVariant.tritanopia:
        throw UnimplementedError(
          'OctoColorScheme.dark(variant: $variant) is not implemented in 0.1.0. '
          'Shape reserved per ADR-0005; values land in a later milestone.',
        );
    }
  }

  OctoColorScheme copyWith({
    Brightness? brightness,
    OctoColorSchemeVariant? variant,
    OctoCanvasColors? canvas,
    OctoForegroundColors? fg,
    OctoBorderColors? border,
    OctoNeutralColors? neutral,
    OctoAccentColors? accent,
    OctoSuccessColors? success,
    OctoAttentionColors? attention,
    OctoDangerColors? danger,
  }) {
    return OctoColorScheme(
      brightness: brightness ?? this.brightness,
      variant: variant ?? this.variant,
      canvas: canvas ?? this.canvas,
      fg: fg ?? this.fg,
      border: border ?? this.border,
      neutral: neutral ?? this.neutral,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      attention: attention ?? this.attention,
      danger: danger ?? this.danger,
    );
  }

  static OctoColorScheme lerp(OctoColorScheme a, OctoColorScheme b, double t) {
    if (identical(a, b)) return a;
    return OctoColorScheme(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      variant: t < 0.5 ? a.variant : b.variant,
      canvas: OctoCanvasColors.lerp(a.canvas, b.canvas, t),
      fg: OctoForegroundColors.lerp(a.fg, b.fg, t),
      border: OctoBorderColors.lerp(a.border, b.border, t),
      neutral: OctoNeutralColors.lerp(a.neutral, b.neutral, t),
      accent: OctoAccentColors.lerp(a.accent, b.accent, t),
      success: OctoSuccessColors.lerp(a.success, b.success, t),
      attention: OctoAttentionColors.lerp(a.attention, b.attention, t),
      danger: OctoDangerColors.lerp(a.danger, b.danger, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OctoColorScheme &&
        other.brightness == brightness &&
        other.variant == variant &&
        other.canvas == canvas &&
        other.fg == fg &&
        other.border == border &&
        other.neutral == neutral &&
        other.accent == accent &&
        other.success == success &&
        other.attention == attention &&
        other.danger == danger;
  }

  @override
  int get hashCode => Object.hash(
        brightness,
        variant,
        canvas,
        fg,
        border,
        neutral,
        accent,
        success,
        attention,
        danger,
      );
}

@immutable
class OctoCanvasColors {
  final Color defaultColor;
  final Color overlay;
  final Color inset;
  final Color subtle;

  const OctoCanvasColors({
    required this.defaultColor,
    required this.overlay,
    required this.inset,
    required this.subtle,
  });

  OctoCanvasColors copyWith({
    Color? defaultColor,
    Color? overlay,
    Color? inset,
    Color? subtle,
  }) =>
      OctoCanvasColors(
        defaultColor: defaultColor ?? this.defaultColor,
        overlay: overlay ?? this.overlay,
        inset: inset ?? this.inset,
        subtle: subtle ?? this.subtle,
      );

  static OctoCanvasColors lerp(
    OctoCanvasColors a,
    OctoCanvasColors b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return OctoCanvasColors(
      defaultColor: Color.lerp(a.defaultColor, b.defaultColor, t)!,
      overlay: Color.lerp(a.overlay, b.overlay, t)!,
      inset: Color.lerp(a.inset, b.inset, t)!,
      subtle: Color.lerp(a.subtle, b.subtle, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoCanvasColors &&
          other.defaultColor == defaultColor &&
          other.overlay == overlay &&
          other.inset == inset &&
          other.subtle == subtle;

  @override
  int get hashCode => Object.hash(defaultColor, overlay, inset, subtle);
}

@immutable
class OctoForegroundColors {
  final Color defaultColor;
  final Color muted;
  final Color subtle;

  /// Foreground for any `*.emphasis` background. Required (ADR-0005).
  final Color onEmphasis;

  const OctoForegroundColors({
    required this.defaultColor,
    required this.muted,
    required this.subtle,
    required this.onEmphasis,
  });

  OctoForegroundColors copyWith({
    Color? defaultColor,
    Color? muted,
    Color? subtle,
    Color? onEmphasis,
  }) =>
      OctoForegroundColors(
        defaultColor: defaultColor ?? this.defaultColor,
        muted: muted ?? this.muted,
        subtle: subtle ?? this.subtle,
        onEmphasis: onEmphasis ?? this.onEmphasis,
      );

  static OctoForegroundColors lerp(
    OctoForegroundColors a,
    OctoForegroundColors b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return OctoForegroundColors(
      defaultColor: Color.lerp(a.defaultColor, b.defaultColor, t)!,
      muted: Color.lerp(a.muted, b.muted, t)!,
      subtle: Color.lerp(a.subtle, b.subtle, t)!,
      onEmphasis: Color.lerp(a.onEmphasis, b.onEmphasis, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoForegroundColors &&
          other.defaultColor == defaultColor &&
          other.muted == muted &&
          other.subtle == subtle &&
          other.onEmphasis == onEmphasis;

  @override
  int get hashCode => Object.hash(defaultColor, muted, subtle, onEmphasis);
}

@immutable
class OctoBorderColors {
  final Color defaultColor;
  final Color muted;
  final Color subtle;

  const OctoBorderColors({
    required this.defaultColor,
    required this.muted,
    required this.subtle,
  });

  OctoBorderColors copyWith({
    Color? defaultColor,
    Color? muted,
    Color? subtle,
  }) =>
      OctoBorderColors(
        defaultColor: defaultColor ?? this.defaultColor,
        muted: muted ?? this.muted,
        subtle: subtle ?? this.subtle,
      );

  static OctoBorderColors lerp(
    OctoBorderColors a,
    OctoBorderColors b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return OctoBorderColors(
      defaultColor: Color.lerp(a.defaultColor, b.defaultColor, t)!,
      muted: Color.lerp(a.muted, b.muted, t)!,
      subtle: Color.lerp(a.subtle, b.subtle, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoBorderColors &&
          other.defaultColor == defaultColor &&
          other.muted == muted &&
          other.subtle == subtle;

  @override
  int get hashCode => Object.hash(defaultColor, muted, subtle);
}

@immutable
class OctoNeutralColors {
  final Color fg;
  final Color emphasis;
  final Color emphasisPlus;
  final Color muted;
  final Color subtle;

  const OctoNeutralColors({
    required this.fg,
    required this.emphasis,
    required this.emphasisPlus,
    required this.muted,
    required this.subtle,
  });

  OctoNeutralColors copyWith({
    Color? fg,
    Color? emphasis,
    Color? emphasisPlus,
    Color? muted,
    Color? subtle,
  }) =>
      OctoNeutralColors(
        fg: fg ?? this.fg,
        emphasis: emphasis ?? this.emphasis,
        emphasisPlus: emphasisPlus ?? this.emphasisPlus,
        muted: muted ?? this.muted,
        subtle: subtle ?? this.subtle,
      );

  static OctoNeutralColors lerp(
    OctoNeutralColors a,
    OctoNeutralColors b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return OctoNeutralColors(
      fg: Color.lerp(a.fg, b.fg, t)!,
      emphasis: Color.lerp(a.emphasis, b.emphasis, t)!,
      emphasisPlus: Color.lerp(a.emphasisPlus, b.emphasisPlus, t)!,
      muted: Color.lerp(a.muted, b.muted, t)!,
      subtle: Color.lerp(a.subtle, b.subtle, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoNeutralColors &&
          other.fg == fg &&
          other.emphasis == emphasis &&
          other.emphasisPlus == emphasisPlus &&
          other.muted == muted &&
          other.subtle == subtle;

  @override
  int get hashCode => Object.hash(fg, emphasis, emphasisPlus, muted, subtle);
}

abstract class _StatusColors {
  Color get fg;
  Color get emphasis;
  Color get muted;
  Color get subtle;
}

@immutable
class OctoAccentColors implements _StatusColors {
  @override
  final Color fg;
  @override
  final Color emphasis;
  @override
  final Color muted;
  @override
  final Color subtle;

  const OctoAccentColors({
    required this.fg,
    required this.emphasis,
    required this.muted,
    required this.subtle,
  });

  OctoAccentColors copyWith({
    Color? fg,
    Color? emphasis,
    Color? muted,
    Color? subtle,
  }) =>
      OctoAccentColors(
        fg: fg ?? this.fg,
        emphasis: emphasis ?? this.emphasis,
        muted: muted ?? this.muted,
        subtle: subtle ?? this.subtle,
      );

  static OctoAccentColors lerp(
    OctoAccentColors a,
    OctoAccentColors b,
    double t,
  ) =>
      identical(a, b)
          ? a
          : OctoAccentColors(
              fg: Color.lerp(a.fg, b.fg, t)!,
              emphasis: Color.lerp(a.emphasis, b.emphasis, t)!,
              muted: Color.lerp(a.muted, b.muted, t)!,
              subtle: Color.lerp(a.subtle, b.subtle, t)!,
            );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoAccentColors &&
          other.fg == fg &&
          other.emphasis == emphasis &&
          other.muted == muted &&
          other.subtle == subtle;

  @override
  int get hashCode => Object.hash(fg, emphasis, muted, subtle);
}

@immutable
class OctoSuccessColors implements _StatusColors {
  @override
  final Color fg;
  @override
  final Color emphasis;
  @override
  final Color muted;
  @override
  final Color subtle;

  const OctoSuccessColors({
    required this.fg,
    required this.emphasis,
    required this.muted,
    required this.subtle,
  });

  OctoSuccessColors copyWith({
    Color? fg,
    Color? emphasis,
    Color? muted,
    Color? subtle,
  }) =>
      OctoSuccessColors(
        fg: fg ?? this.fg,
        emphasis: emphasis ?? this.emphasis,
        muted: muted ?? this.muted,
        subtle: subtle ?? this.subtle,
      );

  static OctoSuccessColors lerp(
    OctoSuccessColors a,
    OctoSuccessColors b,
    double t,
  ) =>
      identical(a, b)
          ? a
          : OctoSuccessColors(
              fg: Color.lerp(a.fg, b.fg, t)!,
              emphasis: Color.lerp(a.emphasis, b.emphasis, t)!,
              muted: Color.lerp(a.muted, b.muted, t)!,
              subtle: Color.lerp(a.subtle, b.subtle, t)!,
            );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoSuccessColors &&
          other.fg == fg &&
          other.emphasis == emphasis &&
          other.muted == muted &&
          other.subtle == subtle;

  @override
  int get hashCode => Object.hash(fg, emphasis, muted, subtle);
}

@immutable
class OctoAttentionColors implements _StatusColors {
  @override
  final Color fg;
  @override
  final Color emphasis;
  @override
  final Color muted;
  @override
  final Color subtle;

  const OctoAttentionColors({
    required this.fg,
    required this.emphasis,
    required this.muted,
    required this.subtle,
  });

  OctoAttentionColors copyWith({
    Color? fg,
    Color? emphasis,
    Color? muted,
    Color? subtle,
  }) =>
      OctoAttentionColors(
        fg: fg ?? this.fg,
        emphasis: emphasis ?? this.emphasis,
        muted: muted ?? this.muted,
        subtle: subtle ?? this.subtle,
      );

  static OctoAttentionColors lerp(
    OctoAttentionColors a,
    OctoAttentionColors b,
    double t,
  ) =>
      identical(a, b)
          ? a
          : OctoAttentionColors(
              fg: Color.lerp(a.fg, b.fg, t)!,
              emphasis: Color.lerp(a.emphasis, b.emphasis, t)!,
              muted: Color.lerp(a.muted, b.muted, t)!,
              subtle: Color.lerp(a.subtle, b.subtle, t)!,
            );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoAttentionColors &&
          other.fg == fg &&
          other.emphasis == emphasis &&
          other.muted == muted &&
          other.subtle == subtle;

  @override
  int get hashCode => Object.hash(fg, emphasis, muted, subtle);
}

@immutable
class OctoDangerColors implements _StatusColors {
  @override
  final Color fg;
  @override
  final Color emphasis;
  @override
  final Color muted;
  @override
  final Color subtle;

  const OctoDangerColors({
    required this.fg,
    required this.emphasis,
    required this.muted,
    required this.subtle,
  });

  OctoDangerColors copyWith({
    Color? fg,
    Color? emphasis,
    Color? muted,
    Color? subtle,
  }) =>
      OctoDangerColors(
        fg: fg ?? this.fg,
        emphasis: emphasis ?? this.emphasis,
        muted: muted ?? this.muted,
        subtle: subtle ?? this.subtle,
      );

  static OctoDangerColors lerp(
    OctoDangerColors a,
    OctoDangerColors b,
    double t,
  ) =>
      identical(a, b)
          ? a
          : OctoDangerColors(
              fg: Color.lerp(a.fg, b.fg, t)!,
              emphasis: Color.lerp(a.emphasis, b.emphasis, t)!,
              muted: Color.lerp(a.muted, b.muted, t)!,
              subtle: Color.lerp(a.subtle, b.subtle, t)!,
            );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoDangerColors &&
          other.fg == fg &&
          other.emphasis == emphasis &&
          other.muted == muted &&
          other.subtle == subtle;

  @override
  int get hashCode => Object.hash(fg, emphasis, muted, subtle);
}
