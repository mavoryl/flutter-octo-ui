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
