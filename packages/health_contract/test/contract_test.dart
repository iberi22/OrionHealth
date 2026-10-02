import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:archive/archive.dart';
import 'package:health_contract/health_contract.dart';
import 'package:test/test.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;
String payload(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');
Uri rawLink(String text) =>
    Uri.parse('orionhealth://import?p=j.${payload(utf8.encode(text))}');
void main() {
  for (final dir in ['valid', 'invalid']) {
    final files =
        Directory('test/fixtures/$dir')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      test('$dir ${file.uri.pathSegments.last}', () {
        final result = validateRecord(json);
        expect(result.ok, dir == 'valid', reason: result.errors.join('; '));
        if (dir == 'invalid')
          expect(
            () => Envelope.fromJson(json),
            throwsA(isA<ContractValidationError>()),
          );
      });
      if (dir == 'valid') {
        test('lossless model/file/link ${file.uri.pathSegments.last}', () {
          final record = Envelope.fromJson(json);
          expect(record.toJson(), json);
          expect(fromFile(toFile([record])).single.toJson(), json);
          for (final base in [
            'https://orionhealth.example/import',
            'orionhealth://import',
          ]) {
            expect(
              decodeDeepLink(encodeDeepLink([record], base)).single.toJson(),
              json,
            );
          }
        });
      }
    }
  }
  test('exact TS validation errors match for every shared fixture', () {
    final expected =
        jsonDecode(File('test/fixtures/ts-validation.json').readAsStringSync())
            as Map;
    for (final entry in expected.entries) {
      expect(
        validateRecord(fixture(entry.key as String)).errors,
        entry.value,
        reason: entry.key as String,
      );
    }
  });
  test('reference TS gzip deep link decodes', () {
    final ts = fixture('ts-deep-link.json');
    expect(
      decodeDeepLink(Uri.parse(ts['link'] as String)).single.toJson(),
      fixture(ts['recordFixture'] as String),
    );
  });
  test('immutable nested lists and maps', () {
    final record = Envelope.fromJson(fixture('valid/meal-log-01.json'));
    final meal = record.data as MealLog;
    expect(() => meal.items.clear(), throwsUnsupportedError);
    expect(() => meal.nutrition.micros['iron'] = 1, throwsUnsupportedError);
    final items = [...meal.items];
    final copy = MealLog(
      consumedAt: meal.consumedAt,
      mealType: meal.mealType,
      items: items,
      nutrition: meal.nutrition,
      nutritionSource: meal.nutritionSource,
      origin: meal.origin,
    );
    items.clear();
    expect(copy.items, isNotEmpty);
  });
  test('empty arrays round-trip', () {
    expect(fromFile(toFile([])), isEmpty);
    expect(decodeDeepLink(encodeDeepLink([], 'orionhealth://import')), isEmpty);
  });
  test('raw TS fallback decodes UTF-8', () {
    final json = fixture('valid/workout-session-01.json');
    (json['data'] as Map)['notes'] = 'Entrenamiento 🏋️';
    expect(decodeDeepLink(rawLink(jsonEncode([json]))).single.toJson(), json);
  });
  test('file malformed, wrapper and invalid records rejected', () {
    for (final text in ['{', '{}', '[{}]', '[null]']) {
      expect(() => fromFile(text), throwsA(isA<ContractValidationError>()));
    }
  });
  test('export validates constructed model', () {
    final valid = Envelope.fromJson(fixture('valid/workout-session-01.json'));
    final broken = Envelope(
      schema: valid.schema,
      id: 'bad',
      subject: valid.subject,
      createdAt: valid.createdAt,
      source: valid.source,
      gosDataset: valid.gosDataset,
      data: valid.data,
    );
    expect(() => toFile([broken]), throwsA(isA<ContractValidationError>()));
    expect(
      () => encodeDeepLink([broken], 'orionhealth://import'),
      throwsA(isA<ContractValidationError>()),
    );
  });
  test('preserves unrelated parameters and removes both stale carriers', () {
    final link = encodeDeepLink(
      [],
      'https://orionhealth.example/import?q=1&q=2&p=old#x=a&x=b&p=old',
    );
    expect(link.queryParametersAll['q'], ['1', '2']);
    expect(link.queryParameters.containsKey('p'), isFalse);
    expect(Uri(query: link.fragment).queryParametersAll['x'], ['a', 'b']);
    expect(decodeDeepLink(link), isEmpty);
    final custom = encodeDeepLink(
      [],
      'orionhealth://import?q=ok&p=old#x=ok&p=old',
    );
    expect(custom.queryParameters['q'], 'ok');
    expect(Uri(query: custom.fragment).queryParameters['x'], 'ok');
    expect(decodeDeepLink(custom), isEmpty);
  });
  test('rejects missing, duplicate and unsupported links', () {
    for (final link in [
      'http://example/import#p=x',
      'orionhealth://import',
      'orionhealth://import?p=',
      'orionhealth://import?p=x&p=x',
      'https://example/import?p=x#p=x',
    ]) {
      expect(
        () => decodeDeepLink(Uri.parse(link)),
        throwsA(isA<ContractValidationError>()),
      );
    }
    expect(
      () => encodeDeepLink([], 'http://example/import'),
      throwsA(isA<ContractValidationError>()),
    );
  });
  test('rejects noncanonical base64 and invalid gzip/UTF-8', () {
    for (final encoded in ['j.A', 'j.AB', 'j.====', 'j.a+b', 'e30', 'j._w']) {
      expect(
        () => decodeDeepLink(Uri.parse('orionhealth://import?p=$encoded')),
        throwsA(isA<ContractValidationError>()),
      );
    }
  });
  test('strict 8192 byte payload guard reports sizes', () {
    final atLimit = 'a' * 8192;
    expect(
      () => decodeDeepLink(Uri.parse('orionhealth://import?p=$atLimit')),
      throwsA(isA<ContractValidationError>()),
    );
    final tooLarge = '$atLimit${'a'}';
    expect(
      () => decodeDeepLink(Uri.parse('orionhealth://import?p=$tooLarge')),
      throwsA(
        isA<DeepLinkSizeError>()
            .having((e) => e.payloadBytes, 'size', 8193)
            .having((e) => e.limitBytes, 'limit', 8192),
      ),
    );
    final random = Random(42);
    final json = fixture('valid/workout-session-01.json');
    (json['data'] as Map)['notes'] = List.generate(
      20000,
      (_) => String.fromCharCode(33 + random.nextInt(90)),
    ).join();
    expect(
      () => encodeDeepLink([Envelope.fromJson(json)], 'orionhealth://import'),
      throwsA(isA<DeepLinkSizeError>()),
    );
  });
  test('gzip expansion aborts at 1 MiB; file remains unlimited', () {
    final json = fixture('valid/workout-session-01.json');
    (json['data'] as Map)['notes'] = 'a' * (1024 * 1024 + 1);
    final text = jsonEncode([json]);
    final link = Uri.parse(
      'orionhealth://import?p=${payload(GZipEncoder().encode(utf8.encode(text)))}',
    );
    expect(
      () => decodeDeepLink(link),
      throwsA(
        isA<ContractValidationError>().having(
          (e) => e.errors.single,
          'error',
          contains('exceeds 1 MiB'),
        ),
      ),
    );
    expect(fromFile(text).single.toJson(), json);
  });
  test('validator rejects non-finite values and null optional values', () {
    for (final value in [double.nan, double.infinity, -1, null]) {
      final json = fixture('valid/workout-session-01.json');
      (json['data'] as Map)['perceivedEffort'] = value;
      expect(validateRecord(json).ok, isFalse);
    }
    expect(validateRecord(null).ok, isFalse);
  });
}
