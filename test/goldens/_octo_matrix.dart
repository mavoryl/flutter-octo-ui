import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

/// Both [OctoThemeData] palettes wrapped as [MatrixTheme.custom]. The
/// `themeData` is the Material adapter output (ADR-0004) so MaterialApp
/// chrome (`Scaffold`, dialogs, etc.) picks up Octo colours; `data` carries
/// the OctoThemeData itself so [wrapInOctoTheme] can install [OctoTheme]
/// above the auto-built `MaterialApp`.
final List<MatrixTheme> octoThemes = <MatrixTheme>[
  MatrixTheme.custom('light', OctoThemeData.light().toMaterialTheme(), data: OctoThemeData.light()),
  MatrixTheme.custom('dark', OctoThemeData.dark().toMaterialTheme(), data: OctoThemeData.dark()),
];

/// Wraps the auto-built [MaterialApp] in an [OctoTheme] pulled from
/// `combination.theme.data`. Pass as `wrapApp` to [matrixGolden].
Widget wrapInOctoTheme(Widget app, MatrixCombination combination) {
  final octo = combination.theme.data! as OctoThemeData;
  return OctoTheme(data: octo, child: app);
}

/// Pixel-diff tolerance for every Octo golden, expressed as a fraction.
///
/// `0.01` = up to 1 % of pixels may differ before a test fails. This absorbs
/// sub-pixel anti-aliasing / font hinting differences between the local
/// macOS dev machine where baselines are baked and the CI macOS runner —
/// without hiding real visual regressions.
const double octoGoldenTolerance = 0.01;

/// Report formats for goldens.
///
/// Locally — silence (no HTML / Markdown / JSON / XML on disk). In CI
/// (detected by `isCiEnvironment`) — only the JUnit XML report, which the
/// CI workflow then publishes via `dorny/test-reporter` so failures surface
/// inline on the PR.
Set<MatrixReportFormat> get octoReportFormats => isCiEnvironment
    ? const <MatrixReportFormat>{MatrixReportFormat.junit}
    : const <MatrixReportFormat>{};
