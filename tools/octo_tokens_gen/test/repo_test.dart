import 'dart:io';

import 'package:octo_tokens_gen/src/repo.dart';
import 'package:test/test.dart';

late Directory _tmp;

Future<Directory> _repo() async {
  final root = Directory('${_tmp.path}/octo_ui')..createSync(recursive: true);
  File('${root.path}/pubspec.yaml').writeAsStringSync('name: octo_ui\nversion: 0.10.0\n');
  return root;
}

void main() {
  setUp(() async => _tmp = await Directory.systemTemp.createTemp('octo_repo'));
  tearDown(() => _tmp.delete(recursive: true));

  group('findRepoRoot', () {
    test('finds the root when started from it', () async {
      final root = await _repo();
      expect(findRepoRoot(root).path, root.path);
    });

    test('walks up from a nested tool directory', () async {
      final root = await _repo();
      final nested = Directory('${root.path}/tools/octo_tokens_gen/.dart_tool')
        ..createSync(recursive: true);

      expect(findRepoRoot(nested).path, root.path);
    });

    test('ignores a pubspec belonging to another package', () async {
      final root = await _repo();
      final tool = Directory('${root.path}/tools/octo_tokens_gen')..createSync(recursive: true);
      File('${tool.path}/pubspec.yaml').writeAsStringSync('name: octo_tokens_gen\n');

      expect(findRepoRoot(tool).path, root.path);
    });

    test('throws a readable error when there is no octo_ui above', () async {
      expect(
        () => findRepoRoot(_tmp),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', contains('octo_ui')),
        ),
      );
    });
  });
}
