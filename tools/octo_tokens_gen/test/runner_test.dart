import 'dart:convert';
import 'dart:io';

import 'package:octo_tokens_gen/src/emitter.dart';
import 'package:octo_tokens_gen/src/mapping.dart';
import 'package:octo_tokens_gen/src/runner.dart';
import 'package:test/test.dart';

late Directory _root;
late StringBuffer _log;

String _snapshotJson() => jsonEncode(<String, Object?>{
      'source': <String, Object?>{
        'package': '@primer/primitives',
        'version': '11.10.0',
        'tarballSha256': 'c' * 64,
      },
      'themes': <String, Object?>{
        for (final palette in kPrimerPalettes)
          palette.primerTheme: <String, Object?>{
            for (final token in kPrimerColorTokens) token: '#123456',
          },
      },
      'breakpoints': <String, Object?>{
        'breakpoint-xsmall': 320,
        'breakpoint-small': 544,
        'breakpoint-medium': 768,
        'breakpoint-large': 1012,
        'breakpoint-xlarge': 1280,
        'breakpoint-xxlarge': 1400,
      },
    });

Future<int> _run(List<String> args) => runOctoTokensGen(args, repoRoot: _root, log: _log.writeln);

File _generated() => File('${_root.path}/$kGeneratedTokensPath');

void main() {
  setUp(() async {
    _root = await Directory.systemTemp.createTemp('octo_tokens_gen_root');
    _log = StringBuffer();
    await File('${_root.path}/$kSnapshotPath').create(recursive: true);
    await File('${_root.path}/$kSnapshotPath').writeAsString(_snapshotJson());
  });

  tearDown(() => _root.delete(recursive: true));

  group('generate', () {
    test('writes the generated tokens and reports where', () async {
      final code = await _run(<String>['generate']);

      expect(code, 0);
      expect(_generated().existsSync(), isTrue);
      expect(_generated().readAsStringSync(), contains('kOctoLightStandard'));
      expect(_log.toString(), contains(kGeneratedTokensPath));
    });

    test('creates the output directory when it does not exist yet', () async {
      expect(Directory('${_root.path}/lib/src/tokens/generated').existsSync(), isFalse);

      expect(await _run(<String>['generate']), 0);

      expect(_generated().existsSync(), isTrue);
    });

    test('fails with a readable message when the snapshot is absent', () async {
      await File('${_root.path}/$kSnapshotPath').delete();

      final code = await _run(<String>['generate']);

      expect(code, isNot(0));
      expect(_log.toString(), contains(kSnapshotPath));
    });
  });

  group('generate --check', () {
    test('passes when the committed file matches the snapshot', () async {
      await _run(<String>['generate']);
      _log.clear();

      expect(await _run(<String>['generate', '--check']), 0);
    });

    test('fails when the committed file has drifted', () async {
      await _run(<String>['generate']);
      await _generated().writeAsString('// hand-edited\n');
      _log.clear();

      final code = await _run(<String>['generate', '--check']);

      expect(code, isNot(0));
      expect(_log.toString(), contains('out of date'));
      expect(_log.toString(), contains(kGeneratedTokensPath));
    });

    test('fails when the generated file is missing entirely', () async {
      final code = await _run(<String>['generate', '--check']);

      expect(code, isNot(0));
      expect(_log.toString(), contains(kGeneratedTokensPath));
    });

    test('leaves the committed file untouched', () async {
      await _run(<String>['generate']);
      await _generated().writeAsString('// hand-edited\n');

      await _run(<String>['generate', '--check']);

      expect(_generated().readAsStringSync(), '// hand-edited\n');
    });
  });

  group('usage', () {
    test('an unknown command is a usage error', () async {
      final code = await _run(<String>['frobnicate']);

      expect(code, 64);
      expect(_log.toString(), contains('frobnicate'));
    });

    test('no command prints usage', () async {
      expect(await _run(<String>[]), 64);
      expect(_log.toString(), contains('generate'));
      expect(_log.toString(), contains('fetch'));
    });

    test('fetch without a version is a usage error', () async {
      expect(await _run(<String>['fetch']), 64);
      expect(_log.toString(), contains('--version'));
    });
  });
}
