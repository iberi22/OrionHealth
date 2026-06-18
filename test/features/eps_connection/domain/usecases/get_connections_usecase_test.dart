import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/get_connections_usecase.dart';

class MockOAuthRepository extends Mock implements OAuthRepository {}

void main() {
  late GetConnectionsUseCase useCase;
  late MockOAuthRepository mockRepository;

  final testProvider = const EPSProvider(
    id: 'test_id',
    name: 'Test EPS',
    discoveryUrl: 'D',
    clientId: 'C',
    redirectUrl: 'R',
    scopes: ['S'],
  );
  final testToken = const OAuthToken(accessToken: 'token');

  setUp(() {
    mockRepository = MockOAuthRepository();
    useCase = GetConnectionsUseCase(mockRepository);
  });

  test('should return list of EPSConnection from repository', () async {
    when(() => mockRepository.getConnectedProviders()).thenAnswer((_) async => ['test_id']);
    when(() => mockRepository.getToken('test_id')).thenAnswer((_) async => testToken);
    when(() => mockRepository.getProviderDetails('test_id')).thenAnswer((_) async => testProvider);
    when(() => mockRepository.getPatientId('test_id')).thenAnswer((_) async => 'PT-123');

    final result = await useCase();

    expect(result.length, 1);
    expect(result.first.provider, testProvider);
    expect(result.first.token, testToken);
    expect(result.first.patientId, 'PT-123');
    verify(() => mockRepository.getConnectedProviders()).called(1);
    verify(() => mockRepository.getToken('test_id')).called(1);
    verify(() => mockRepository.getProviderDetails('test_id')).called(1);
    verify(() => mockRepository.getPatientId('test_id')).called(1);
  });

  test('should skip if token or provider details are missing', () async {
    when(() => mockRepository.getConnectedProviders()).thenAnswer((_) async => ['test_id']);
    when(() => mockRepository.getToken('test_id')).thenAnswer((_) async => null);
    when(() => mockRepository.getProviderDetails('test_id')).thenAnswer((_) async => null);
    when(() => mockRepository.getPatientId('test_id')).thenAnswer((_) async => null);

    final result = await useCase();

    expect(result, isEmpty);
  });

  test('should use "Unknown" as patientId if missing', () async {
    when(() => mockRepository.getConnectedProviders()).thenAnswer((_) async => ['test_id']);
    when(() => mockRepository.getToken('test_id')).thenAnswer((_) async => testToken);
    when(() => mockRepository.getProviderDetails('test_id')).thenAnswer((_) async => testProvider);
    when(() => mockRepository.getPatientId('test_id')).thenAnswer((_) async => null);

    final result = await useCase();

    expect(result.first.patientId, 'Unknown');
  });
}
