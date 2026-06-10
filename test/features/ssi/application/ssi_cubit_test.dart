import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/ssi/application/ssi_cubit.dart';
import 'package:orionhealth_health/features/ssi/application/ssi_state.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/did.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';
import 'package:orionhealth_health/features/ssi/domain/repositories/ssi_repository.dart';

class MockSsiRepository extends Mock implements SsiRepository {}

class FakeVerifiableCredential extends Fake implements VerifiableCredential {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeVerifiableCredential());
  });
  late MockSsiRepository repository;
  late SsiCubit cubit;

  setUp(() {
    repository = MockSsiRepository();
    cubit = SsiCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('SsiCubit', () {
    final tDids = [
      Did(did: 'did:ion:test1', longForm: 'did:ion:test1:lf', createdAt: DateTime.now()),
      Did(did: 'did:ion:test2', longForm: 'did:ion:test2:lf', createdAt: DateTime.now()),
    ];

    final tCredentials = [
      VerifiableCredential(
        id: 'vc1',
        issuer: 'did:ion:issuer',
        subject: 'did:ion:subject',
        type: 'VaccinationCredential',
        schemaId: 'schema:v1',
        claims: {'name': 'John'},
        issuanceDate: DateTime.now(),
      ),
    ];

    test('initial state is SsiInitial', () {
      expect(cubit.state, isA<SsiInitial>());
    });

    group('loadDids', () {
      test('emits loading then didsLoaded on success', () async {
        when(() => repository.getDids()).thenAnswer((_) async => tDids);

        final expected = [
          isA<SsiLoading>(),
          isA<SsiDidsLoaded>(),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));
        await cubit.loadDids();
      });

      test('emits loading then error on failure', () async {
        when(() => repository.getDids()).thenThrow(Exception('db error'));

        final expected = [
          isA<SsiLoading>(),
          isA<SsiError>(),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));
        await cubit.loadDids();
      });
    });

    group('loadCredentials', () {
      test('emits loading then credentialsLoaded on success', () async {
        when(() => repository.getCredentials()).thenAnswer((_) async => tCredentials);

        final expected = [
          isA<SsiLoading>(),
          isA<SsiCredentialsLoaded>(),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));
        await cubit.loadCredentials();
      });
    });

    group('saveCredential', () {
      test('saves and reloads on success', () async {
        when(() => repository.saveCredential(any())).thenAnswer((_) async {});
        when(() => repository.getCredentials()).thenAnswer((_) async => tCredentials);

        final expected = [
          isA<SsiLoading>(),
          isA<SsiCredentialsLoaded>(),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));
        await cubit.saveCredential(tCredentials.first);
      });

      test('emits error when save fails', () async {
        when(() => repository.saveCredential(any())).thenThrow(Exception('save failed'));

        final expected = [
          isA<SsiError>(),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));
        await cubit.saveCredential(tCredentials.first);
      });
    });

    group('deleteCredential', () {
      test('deletes and reloads on success', () async {
        when(() => repository.deleteCredential(any())).thenAnswer((_) async {});
        when(() => repository.getCredentials()).thenAnswer((_) async => tCredentials);

        final expected = [
          isA<SsiLoading>(),
          isA<SsiCredentialsLoaded>(),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));
        await cubit.deleteCredential('vc1');
      });
    });
  });
}
