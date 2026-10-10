// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Runs `flutter test` and treats only the failures registered in a known
/// failures file as expected, so the CI gate stays honest.
///
/// Why this exists: the workflow used to run `flutter test | tee`, which
/// returned tee's exit code, so a suite with hundreds of failures still
/// concluded the job as success. This runner makes the gate honest again:
///
///   * every failing test must either be listed in the registry (one line per
///     test, with the reason) or the run fails;
///   * registered entries that no longer fail are reported as stale, so the
///     list can shrink as the underlying issues get fixed;
///   * no test is deleted or hidden from the log: unexpected failures are
///     printed with their first error line, and the raw JSON reporter output is
///     kept in `test_output.json`.
///
/// Registry line format (comments start with `#`):
///
///   `<path relative to the working directory> :: <test name> :: <reason>`
///
/// The test name is the one `flutter test` reports: the enclosing group names
/// followed by the test description, joined by single spaces.
///
/// Usage (from the directory that holds the tests, same arguments as
/// `flutter test`):
///
///   dart run scripts/run_tests_with_known_failures.dart --coverage
///
/// Extra options (not forwarded to `flutter test`):
///
///   `--registry <path>`  known-failures file (default: tests/known_failures.txt)
///   `--json-out <path>`  where to keep the raw reporter output
///                      (default: test_output.json)
///
/// Exit code 0: no unexpected failures. Exit code 1: at least one failing test
/// is not registered, or the runner itself crashed.
library;

import 'dart:convert';
import 'dart:io';

/// A registered known failure: `path :: test name :: reason`.
class KnownFailure {
  KnownFailure(this.file, this.name, this.reason);

  final String file;
  final String name;
  final String reason;

  String get key => '$file$_fieldSeparator$name';

  @override
  String toString() => '$file$_fieldSeparator$name :: $reason';
}

const String _fieldSeparator = ' :: ';
const String _defaultRegistry = 'tests/known_failures.txt';
const String _defaultJsonLog = 'test_output.json';

Future<void> main(List<String> rawArgs) async {
  // The VM hands `main` a fixed-length list, so take a copy before mutating.
  final args = [...rawArgs];
  final registryPath = _takeOption(args, '--registry') ?? _defaultRegistry;
  final jsonLogPath = _takeOption(args, '--json-out') ?? _defaultJsonLog;
  final registry = _loadRegistry(registryPath);
  stdout.writeln('Known-failure registry: $registryPath '
      '(${registry.length} entries)');

  final forwarded = args.where((a) => !_isReporterFlag(a)).toList();
  final command = ['test', '--reporter', 'json', ...forwarded];

  stdout.writeln('Running: flutter ${command.join(' ')}');
  final log = <String>[];
  final Process process;
  try {
    process = await Process.start('flutter', command);
  } on ProcessException catch (e) {
    stderr.writeln('RUNNER ERROR: could not start flutter: ${e.message}');
    exit(1);
  }

  var completed = 0;
  var passedSoFar = 0;
  var failedSoFar = 0;

  /// Prints a `+passed -failed` line every 100 tests so CI logs show progress
  /// instead of staying silent until the whole suite finishes.
  void reportProgress(String line) {
    final event = _decode(line);
    if (event == null || event['type'] != 'testDone') return;
    completed++;
    if (event['skipped'] == true) return;
    if (event['result'] == 'success') {
      passedSoFar++;
    } else {
      failedSoFar++;
    }
    if (completed % 100 == 0) {
      stdout.writeln('[runner] $completed tests done: '
          '+$passedSoFar -$failedSoFar (unexpected failures are printed at the end)');
    }
  }

  final stdoutDone = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    log.add(line);
    reportProgress(line);
  }).asFuture<void>();
  final stderrDone = process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(stderr.writeln)
      .asFuture<void>();

  final exitCode = await process.exitCode;
  await stdoutDone;
  await stderrDone;

  await File(jsonLogPath).writeAsString(log.join('\n'));

  final report = _evaluate(log, registry, Directory.current.path, registryPath);
  report.processExitCode = exitCode;
  report.printReport();
  exit(report.isGreen ? 0 : 1);
}

/// Removes `--<name> <value>` (or `--<name>=<value>`) from [args] and returns
/// the value it pointed at, or null when the option was not given.
String? _takeOption(List<String> args, String name) {
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == name && i + 1 < args.length) {
      final value = args[i + 1];
      args.removeRange(i, i + 2);
      return value;
    }
    if (arg.startsWith('$name=')) {
      args.removeAt(i);
      return arg.substring(name.length + 1);
    }
  }
  return null;
}

/// The runner always owns the reporter, so reporter flags from the caller are
/// dropped instead of being forwarded twice.
bool _isReporterFlag(String arg) =>
    arg == '--reporter' ||
    arg == '--file-reporter' ||
    arg == 'json' ||
    arg == 'expanded' ||
    arg == 'compact' ||
    arg == 'github';

class _Report {
  _Report(this.registryPath);

  final String registryPath;
  int passed = 0;
  int skipped = 0;
  int? processExitCode;
  int _registrySize = 0;
  final List<String> expectedFailures = <String>[];
  final List<String> unexpectedFailures = <String>[];
  final List<String> staleEntries = <String>[];
  final Set<String> matchedKeys = <String>{};
  final Set<String> ranKeys = <String>{};

  bool get isGreen => unexpectedFailures.isEmpty;

  void printReport() {
    for (final entry in staleEntries) {
      stdout.writeln('STALE REGISTRY ENTRY (passes now, remove it): $entry');
    }
    final notRun = matchedKeys.length + staleEntries.length;
    if (notRun < _registrySize) {
      stdout.writeln('Note: ${_registrySize - notRun} registered '
          'entr${_registrySize - notRun == 1 ? 'y' : 'ies'} did not run in this '
          'invocation; the registry describes the whole suite, so run the '
          'runner without path filters (and without --name) to judge it.');
    }
    stdout.writeln('---');
    stdout.writeln('Expected failures (registered): ${expectedFailures.length}');
    for (final entry in expectedFailures) {
      stdout.writeln('  $entry');
    }
    stdout.writeln('Unexpected failures: ${unexpectedFailures.length}');
    for (final entry in unexpectedFailures) {
      stderr.writeln('  $entry');
    }
    stdout.writeln('---');
    stdout.writeln('flutter test exit code: $processExitCode');
    stdout.writeln('Totals: $passed passed, $skipped skipped, '
        '${expectedFailures.length} registered failures, '
        '${unexpectedFailures.length} unexpected failures');
    if (isGreen) {
      stdout.writeln(unexpectedFailures.isEmpty && expectedFailures.isEmpty
          ? 'GREEN: the whole suite passed.'
          : 'GREEN (with ${expectedFailures.length} registered known '
              'failures): no unexpected failure.');
    } else {
      stdout.writeln('RED: ${unexpectedFailures.length} failure(s) are not '
          'registered. Fix them, or register each one with a reason in '
          '$registryPath.');
    }
  }
}

List<KnownFailure> _loadRegistry(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('REGISTRY ERROR: $path does not exist.');
    exit(1);
  }
  final entries = <KnownFailure>[];
  var lineNumber = 0;
  for (final raw in file.readAsLinesSync()) {
    lineNumber++;
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final parts = line.split(_fieldSeparator);
    if (parts.length < 3) {
      stderr.writeln('REGISTRY FORMAT ERROR in $path:$lineNumber '
          '(expected "file :: test :: reason"): $line');
      exit(1);
    }
    entries.add(KnownFailure(
      parts[0].trim(),
      parts[1].trim(),
      parts.sublist(2).join(_fieldSeparator).trim(),
    ));
  }
  return entries;
}

class _Group {
  _Group(this.parentId, this.name);

  final int? parentId;
  final String name;
}

class _Test {
  _Test(this.suiteId, this.name, this.groupIds);

  final int suiteId;
  final String name;
  final List<int> groupIds;
}

_Report _evaluate(List<String> logLines, List<KnownFailure> registry,
    String cwd, String registryPath) {
  final report = _Report(registryPath).._registrySize = registry.length;
  final suites = <int, String>{};
  final groups = <int, _Group>{};
  final tests = <int, _Test>{};
  final errors = <int, List<String>>{};

  String relative(String path) =>
      path.startsWith('$cwd/') ? path.substring(cwd.length + 1) : path;

  for (final line in logLines) {
    final Map<String, dynamic>? event = _decode(line);
    if (event == null) continue;
    switch (event['type']) {
      case 'suite':
        final suite = event['suite'] as Map<String, dynamic>;
        suites[suite['id'] as int] = relative(suite['path'] as String);
      case 'group':
        final group = event['group'] as Map<String, dynamic>;
        groups[group['id'] as int] =
            _Group(group['parentID'] as int?, group['name'] as String);
      case 'testStart':
        final test = event['test'] as Map<String, dynamic>;
        tests[test['id'] as int] = _Test(
          test['suiteID'] as int,
          test['name'] as String,
          (test['groupIDs'] as List?)?.cast<int>() ?? const <int>[],
        );
      case 'error':
        final id = event['testID'] as int;
        (errors[id] ??= <String>[]).add(event['error'] as String? ?? '');
      case 'testDone':
        final id = event['testID'] as int;
        final test = tests[id];
        if (test == null) break;
        final file = suites[test.suiteId] ?? '?';
        // A suite that fails to compile is reported as a test named
        // `loading <absolute path>`; make that name portable across machines.
        final name = _displayName(test, groups).replaceAll('$cwd/', '');
        report.ranKeys.add('$file$_fieldSeparator$name');
        if (event['skipped'] == true) {
          report.skipped++;
          break;
        }
        if (event['result'] == 'success') {
          report.passed++;
          break;
        }
        final errorLine = _firstErrorLine(errors[id] ?? const <String>[]);
        final matches = registry
            .where((k) => k.file == file && k.name == name)
            .toList(growable: false);
        final key = '$file$_fieldSeparator$name';
        if (matches.isEmpty) {
          report.unexpectedFailures.add('$key :: $errorLine');
        } else {
          report.matchedKeys.add(key);
          final detail =
              errorLine == '(no message)' ? '' : ' [last error: $errorLine]';
          report.expectedFailures.add('$key :: ${matches.first.reason}$detail');
        }
    }
  }

  // An entry is stale only when its test ran and passed: a subset run says
  // nothing about the entries it did not execute.
  for (final known in registry) {
    if (report.ranKeys.contains(known.key) &&
        !report.matchedKeys.contains(known.key)) {
      report.staleEntries.add(known.toString());
    }
  }
  return report;
}

Map<String, dynamic>? _decode(String line) {
  if (!line.startsWith('{')) return null;
  try {
    final decoded = jsonDecode(line);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

String _displayName(_Test test, Map<int, _Group> groups) {
  final names = <String>[
    for (final id in test.groupIds)
      if ((groups[id]?.name ?? '').isNotEmpty) groups[id]!.name,
    test.name,
  ];
  return names.join(' ');
}

String _firstErrorLine(List<String> errors) {
  for (final error in errors) {
    for (final raw in error.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('package:') ||
          line.startsWith('dart:') ||
          line.startsWith('#')) {
        continue;
      }
      if (line.startsWith('Test failed.') ||
          line.contains('See exception logs above')) {
        continue;
      }
      return line.length > 200 ? '${line.substring(0, 200)}…' : line;
    }
  }
  return '(no message)';
}
