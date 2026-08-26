import 'dart:io';

/// Locates the `octo_ui` repository root at or above [start].
///
/// The tool writes into the main package, so it needs the root regardless of
/// where it was invoked from. `Platform.script` is not usable for this:
/// `dart run octo_tokens_gen` executes a kernel snapshot under
/// `.dart_tool/`, which would put the root four levels below the real one.
Directory findRepoRoot(Directory start) {
  final marker = RegExp(r'^name:\s*octo_ui\s*$', multiLine: true);
  for (Directory dir = start.absolute;; dir = dir.parent) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (pubspec.existsSync() && marker.hasMatch(pubspec.readAsStringSync())) {
      return dir;
    }
    if (dir.parent.path == dir.path) {
      throw StateError(
        'no octo_ui pubspec.yaml at or above ${start.absolute.path} — '
        'run the tool from inside the repository',
      );
    }
  }
}
