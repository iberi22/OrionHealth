// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Fixture tests for `scripts/run_tests_with_known_failures.dart`.
///
/// Every row of the T8 review table
/// (`orchestration/wave-pi-2/results/T8-review-grok-r1.md`) is replayed here
/// with a fake `flutter` on `PATH`, and the runner's exit code is asserted.
/// This is the proof that a crash, a compiler death, an empty run or a stale
/// registry entry can no longer be reported as a green build.
///
/// Run from the repository root (also runs in the gating CI job):
///
///   dart run scripts/test_runner_fixtures.dart
///
/// An optional first argument overrides the runner under test; it exists so the
/// fixtures can be shown red against an older runner revision.
///
/// Exit code 0: every fixture produced the expected runner exit code.
/// Exit code 1: at least one mismatch (each one is printed).
library;

import 'dart:convert';
import 'dart:io';

/// One `flutter test --reporter json` transcript plus the expected gate
/// verdict.
class Fixture {
  Fixture({
    required this.name,
    required this.registry,
    required this.flutterOutput,
    required this.flutterExitCode,
    required this.expectedRunnerExitCode,
    this.mustContain = const <String>[],
    this.mustNotContain = const <String>[],
  });

  final String name;

  /// Contents of the known-failures registry file.
  final String registry;

  /// Exactly what the fake `flutter` writes to stdout.
  final String flutterOutput;

  /// Exit code the fake `flutter` returns.
  final int flutterExitCode;

  /// Exit code the runner under test must return.
  final int expectedRunnerExitCode;

  final List<String> mustContain;
  final List<String> mustNotContain;
}

String _event(Map<String, dynamic> value) => jsonEncode(value);

String _suite(String path) =>
    _event({'type': 'suite', 'suite': {'id': 0, 'path': path}});

String _group(String name, {int id = 1}) => _event({
      'type': 'group',
      'group': {'id': id, 'parentID': null, 'name': name},
    });

String _testStart(int id, String name,
        {int suiteId = 0, List<int> groupIds = const [1]}) =>
    _event({
      'type': 'testStart',
      'test': {
        'id': id,
        'name': name,
        'suiteID': suiteId,
        'groupIDs': groupIds,
      },
    });

String _error(int testId, String message) => _event({
      'type': 'error',
      'testID': testId,
      'error': message,
      'stackTrace': '',
      'isFailure': true,
    });

String _testDone(int testId,
        {required String result, bool skipped = false, bool hidden = false}) =>
    _event({
      'type': 'testDone',
      'testID': testId,
      'result': result,
      'skipped': skipped,
      'hidden': hidden,
    });

String _done({required bool success}) =>
    _event({'type': 'done', 'success': success});

const String _registryOne = '# fixture registry\n'
    'test/foo_test.dart :: group alpha fails :: golden diff\n';

/// A registered failure that is the only failure: the intended green row.
final Fixture _registeredOnly = Fixture(
  name: 'registered-only (302-style row stays green)',
  registry: _registryOne,
  flutterOutput: [
    _suite('test/foo_test.dart'),
    _group('group alpha'),
    _testStart(2, 'fails'),
    _error(2, 'Expected: true\n  Actual: false'),
    _testDone(2, result: 'failure'),
    _done(success: false),
  ].join('\n'),
  flutterExitCode: 1,
  expectedRunnerExitCode: 0,
  mustContain: ['GREEN', 'Expected failures (registered): 1'],
);

/// A sibling test name fails while the registry lists another one.
final Fixture _siblingName = Fixture(
  name: 'sibling name group alpha extra also fails',
  registry: _registryOne,
  flutterOutput: [
    _suite('test/foo_test.dart'),
    _group('group alpha'),
    _testStart(2, 'extra'),
    _error(2, 'Expected: true\n  Actual: false'),
    _testDone(2, result: 'failure'),
    _done(success: false),
  ].join('\n'),
  flutterExitCode: 1,
  expectedRunnerExitCode: 1,
  mustContain: ['Unexpected failures: 1'],
);

/// An unregistered `loading …` compile error.
final Fixture _unregisteredLoadError = Fixture(
  name: 'unregistered loading … compile error',
  registry: '# fixture registry\n',
  flutterOutput: [
    _suite('test/broken_test.dart'),
    _group(''),
    _testStart(2, 'loading test/broken_test.dart'),
    _error(2, "Error: Couldn't resolve the package 'flutter_test'."),
    _testDone(2, result: 'failure'),
    _done(success: false),
  ].join('\n'),
  flutterExitCode: 1,
  expectedRunnerExitCode: 1,
  mustContain: ['Unexpected failures: 1'],
);

/// `Error: Compilation failed.` and no JSON at all.
final Fixture _compileErrorNoJson = Fixture(
  name: 'Error: Compilation failed. and no JSON',
  registry: '# fixture registry\n',
  flutterOutput: 'Error: Compilation failed.',
  flutterExitCode: 1,
  expectedRunnerExitCode: 1,
  mustContain: ['RED'],
  mustNotContain: ['GREEN: the whole suite passed'],
);

/// `done.success: false` and zero tests.
final Fixture _doneFalseZeroTests = Fixture(
  name: 'done.success: false and zero tests',
  registry: '# fixture registry\n',
  flutterOutput: _done(success: false),
  flutterExitCode: 1,
  expectedRunnerExitCode: 1,
  mustNotContain: ['GREEN: the whole suite passed'],
);

/// Plain `No tests ran.` with no JSON.
final Fixture _noTestsRan = Fixture(
  name: 'stdout No tests ran.',
  registry: '# fixture registry\n',
  flutterOutput: 'No tests ran.',
  flutterExitCode: 1,
  expectedRunnerExitCode: 1,
  mustNotContain: ['GREEN: the whole suite passed'],
);

/// A registered failure, then a crash (exit 139) with no `done` event.
final Fixture _exit139NoDone = Fixture(
  name: 'registered failure, then exit 139, no done',
  registry: _registryOne,
  flutterOutput: [
    _suite('test/foo_test.dart'),
    _group('group alpha'),
    _testStart(2, 'fails'),
    _error(2, 'Expected: true\n  Actual: false'),
    _testDone(2, result: 'failure'),
  ].join('\n'),
  flutterExitCode: 139,
  expectedRunnerExitCode: 1,
);

/// A registered failure plus `done`, but `flutter test` crashed (exit 139).
final Fixture _registeredPlusCrash = Fixture(
  name: 'registered failure with done but exit 139',
  registry: _registryOne,
  flutterOutput: [
    _suite('test/foo_test.dart'),
    _group('group alpha'),
    _testStart(2, 'fails'),
    _error(2, 'Expected: true\n  Actual: false'),
    _testDone(2, result: 'failure'),
    _done(success: false),
  ].join('\n'),
  flutterExitCode: 139,
  expectedRunnerExitCode: 1,
);

/// A `testDone` success, then a later `error` for the same test.
final Fixture _errorAfterSuccess = Fixture(
  name: 'testDone success, then a later error',
  registry: '# fixture registry\n',
  flutterOutput: [
    _suite('test/foo_test.dart'),
    _group('group alpha'),
    _testStart(2, 'flaky'),
    _testDone(2, result: 'success'),
    _error(2, 'failed after it had already completed'),
    _done(success: true),
  ].join('\n'),
  flutterExitCode: 1,
  expectedRunnerExitCode: 1,
  mustContain: ['error reported after the test completed as success'],
);

/// A registry entry whose test now passes: stale, so the run must fail.
final Fixture _stalePass = Fixture(
  name: 'stale registry entry (passes now)',
  registry: _registryOne,
  flutterOutput: [
    _suite('test/foo_test.dart'),
    _group('group alpha'),
    _testStart(2, 'fails'),
    _testDone(2, result: 'success'),
    _done(success: true),
  ].join('\n'),
  flutterExitCode: 0,
  expectedRunnerExitCode: 1,
  mustContain: ['STALE REGISTRY ENTRY'],
);

/// Hidden virtual successes must not be counted in the pass total.
final Fixture _hiddenSuccessNotCounted = Fixture(
  name: 'hidden: true success is not counted as passed',
  registry: '# fixture registry\n',
  flutterOutput: [
    _suite('test/foo_test.dart'),
    _group('group alpha'),
    _testStart(2, 'virtual node'),
    _testDone(2, result: 'success', hidden: true),
    _done(success: true),
  ].join('\n'),
  flutterExitCode: 0,
  expectedRunnerExitCode: 0,
  mustContain: ['0 passed'],
  mustNotContain: ['1 passed'],
);

final List<Fixture> _fixtures = <Fixture>[
  _registeredOnly,
  _siblingName,
  _unregisteredLoadError,
  _compileErrorNoJson,
  _doneFalseZeroTests,
  _noTestsRan,
  _exit139NoDone,
  _registeredPlusCrash,
  _errorAfterSuccess,
  _stalePass,
  _hiddenSuccessNotCounted,
];

Future<void> main(List<String> args) async {
  final repoRoot = File.fromUri(Platform.script).parent.parent.path;
  final runner = args.isNotEmpty
      ? args.first
      : '$repoRoot${Platform.pathSeparator}scripts${Platform.pathSeparator}'
          'run_tests_with_known_failures.dart';
  if (!File(runner).existsSync()) {
    stderr.writeln('FIXTURE ERROR: runner not found at $runner');
    exit(1);
  }

  final failures = <String>[];
  for (final fixture in _fixtures) {
    final result = await _runFixture(fixture, runner);
    final problems = <String>[];
    final output = '${result.stdout}\n${result.stderr}';
    if (result.exitCode != fixture.expectedRunnerExitCode) {
      problems.add('exit code ${result.exitCode}, expected '
          '${fixture.expectedRunnerExitCode}');
    }
    for (final needle in fixture.mustContain) {
      if (!output.contains(needle)) {
        problems.add('output missing "$needle"');
      }
    }
    for (final needle in fixture.mustNotContain) {
      if (output.contains(needle)) {
        problems.add('output must not contain "$needle"');
      }
    }
    if (problems.isEmpty) {
      stdout.writeln('PASS  ${fixture.name} '
          '(runner exit ${result.exitCode})');
    } else {
      failures.add('${fixture.name}: ${problems.join('; ')}');
      stdout.writeln('FAIL  ${fixture.name}: ${problems.join('; ')}');
      stdout.writeln('--- runner stdout ---');
      stdout.writeln(result.stdout);
      stdout.writeln('--- runner stderr ---');
      stdout.writeln(result.stderr);
      stdout.writeln('--- end ---');
    }
  }

  stdout.writeln('${_fixtures.length - failures.length}/${_fixtures.length} '
      'fixtures matched the expected runner exit code.');
  if (failures.isNotEmpty) {
    stderr.writeln('${failures.length} fixture(s) failed.');
    exit(1);
  }
}

class _FixtureResult {
  _FixtureResult(this.exitCode, this.stdout, this.stderr);

  final int exitCode;
  final String stdout;
  final String stderr;
}

Future<_FixtureResult> _runFixture(Fixture fixture, String runner) async {
  final dir = Directory.systemTemp.createTempSync('t8r2-fixture-');
  try {
    final binDir = Directory('${dir.path}/bin')..createSync();
    final registryFile = File('${dir.path}/known_failures.txt');
    registryFile.writeAsStringSync(fixture.registry);
    final flutterOutputFile = File('${dir.path}/flutter_stdout.txt');
    flutterOutputFile.writeAsStringSync(fixture.flutterOutput);

    // A fake `flutter` that replays the fixture transcript and returns its exit
    // code. It is put first on PATH so the runner's `Process.start('flutter')`
    // finds it instead of a real SDK.
    final fakeFlutter = File('${binDir.path}/flutter');
    fakeFlutter.writeAsStringSync('#!/bin/sh\n'
        'cat ${_shellQuote(flutterOutputFile.path)}\n'
        'exit ${fixture.flutterExitCode}\n');
    final chmod = Process.runSync('chmod', ['+x', fakeFlutter.path]);
    if (chmod.exitCode != 0) {
      throw StateError('chmod +x failed: ${chmod.stderr}');
    }

    final env = Map<String, String>.from(Platform.environment);
    final pathKey = env.keys
        .firstWhere((k) => k.toUpperCase() == 'PATH', orElse: () => 'PATH');
    env[pathKey] = '${binDir.path}${Platform.isWindows ? ';' : ':'}'
        '${env[pathKey] ?? ''}';

    final result = await Process.run(
      Platform.resolvedExecutable,
      [
        runner,
        '--registry',
        'known_failures.txt',
        '--json-out',
        'test_output.json',
      ],
      workingDirectory: dir.path,
      environment: env,
    );
    return _FixtureResult(
        result.exitCode, '${result.stdout}', '${result.stderr}');
  } finally {
    dir.deleteSync(recursive: true);
  }
}

String _shellQuote(String value) => "'${value.replaceAll("'", "'\\''")}'";
