import 'dart:io';

import 'package:octo_tokens_gen/src/repo.dart';
import 'package:octo_tokens_gen/src/runner.dart';

Future<void> main(List<String> args) async {
  final override = _flagValue(args, '--root');
  exitCode = await runOctoTokensGen(
    args,
    repoRoot: override == null ? findRepoRoot(Directory.current) : Directory(override),
    log: stdout.writeln,
  );
}

String? _flagValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index >= 0 && index + 1 < args.length) return args[index + 1];
  return null;
}
