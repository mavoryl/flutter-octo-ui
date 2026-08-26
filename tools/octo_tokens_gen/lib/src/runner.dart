import 'dart:io';

import 'package:octo_tokens_gen/src/emitter.dart';
import 'package:octo_tokens_gen/src/fetcher.dart';
import 'package:octo_tokens_gen/src/snapshot.dart';

/// Exit code for a usage error, matching `sysexits.h` `EX_USAGE`.
const int _usageError = 64;

const String _usage = '''
octo_tokens_gen — regenerates octo_ui tokens from a frozen Primer snapshot.

Usage:
  dart run octo_tokens_gen fetch --version <x.y.z>
      Downloads @primer/primitives, trims it to the tokens the mapping reads,
      and rewrites $kSnapshotPath.

  dart run octo_tokens_gen generate [--check]
      Regenerates $kGeneratedTokensPath from the committed snapshot.
      With --check nothing is written: a stale file is an error instead, which
      is how CI catches a hand-edited or forgotten regeneration.
''';

/// Runs the tool. Returns the process exit code.
///
/// [repoRoot] and [log] are injected so the whole command surface is testable
/// against a temporary directory without touching the real repository.
Future<int> runOctoTokensGen(
  List<String> args, {
  required Directory repoRoot,
  required void Function(String) log,
}) async {
  if (args.isEmpty) {
    log(_usage);
    return _usageError;
  }

  switch (args.first) {
    case 'generate':
      return _generate(repoRoot: repoRoot, log: log, check: args.contains('--check'));
    case 'fetch':
      final version = _flag(args, '--version');
      if (version == null) {
        log('fetch needs --version <x.y.z>\n');
        log(_usage);
        return _usageError;
      }
      return _fetch(repoRoot: repoRoot, log: log, version: version);
    case '--help':
    case '-h':
    case 'help':
      log(_usage);
      return 0;
    default:
      log('unknown command "${args.first}"\n');
      log(_usage);
      return _usageError;
  }
}

String? _flag(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index >= 0 && index + 1 < args.length) return args[index + 1];
  for (final arg in args) {
    if (arg.startsWith('$name=')) return arg.substring(name.length + 1);
  }
  return null;
}

Future<int> _generate({
  required Directory repoRoot,
  required void Function(String) log,
  required bool check,
}) async {
  final snapshotFile = File('${repoRoot.path}/$kSnapshotPath');
  if (!snapshotFile.existsSync()) {
    log('no snapshot at $kSnapshotPath — run `fetch --version <x.y.z>` first');
    return 1;
  }

  final String generated;
  try {
    generated = emitTokens(PrimerSnapshot.parse(await snapshotFile.readAsString()));
  } on FormatException catch (error) {
    log('$kSnapshotPath is unusable: ${error.message}');
    return 1;
  }

  final target = File('${repoRoot.path}/$kGeneratedTokensPath');

  if (check) {
    final current = target.existsSync() ? await target.readAsString() : null;
    if (current == generated) {
      log('$kGeneratedTokensPath is up to date');
      return 0;
    }
    log(
      current == null
          ? '$kGeneratedTokensPath is missing — run `generate`'
          : '$kGeneratedTokensPath is out of date — run `generate` and commit the result',
    );
    return 1;
  }

  await target.parent.create(recursive: true);
  await target.writeAsString(generated);
  log('wrote $kGeneratedTokensPath');
  return 0;
}

Future<int> _fetch({
  required Directory repoRoot,
  required void Function(String) log,
  required String version,
}) async {
  log('downloading $kPrimerPackage $version…');
  final PrimerSnapshot snapshot;
  try {
    snapshot = await fetchSnapshot(version);
  } on Object catch (error) {
    log('fetch failed: $error');
    return 1;
  }

  final file = File('${repoRoot.path}/$kSnapshotPath');
  await file.parent.create(recursive: true);
  await file.writeAsString(snapshot.encode());
  log('wrote $kSnapshotPath (${snapshot.package} ${snapshot.version})');
  log('sha256 ${snapshot.tarballSha256}');
  log('now run `generate` to refresh $kGeneratedTokensPath');
  return 0;
}
