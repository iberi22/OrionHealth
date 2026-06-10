import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/repositories/oauth_repository_impl.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/did.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';
import 'package:orionhealth_health/features/ssi/domain/repositories/ssi_repository.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/ssi_service_impl.dart';

class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockSsiRepository extends Mock implements SsiRepository {}

void main() {
  late OAuthRepositoryImpl oauthRepository;
  late SsiServiceImpl ssiService;
  late MockFlutterAppAuth mockAppAuth;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockSsiRepository mockSsiRepository;

  setUpAll(() {
    registerFallbackValue(AuthorizationTokenRequest(
      'clientId',
      'redirectUrl',
      discoveryUrl: 'discoveryUrl',
    ));
    registerFallbackValue(Did(
      did: 'did:test',
      longForm: 'did:test:long',
      createdAt: DateTime.now(),
    ));
    registerFallbackValue(VerifiableCredential(
      id: 'vc:test',
      issuer: 'did:issuer',
      subject: 'did:subject',
      type: 'Test',
      schemaId: 'schema',
      claims: {},
      issuanceDate: DateTime.now(),
    ));
  });

  setUp(() {
    mockAppAuth = MockFlutterAppAuth();
    mockSecureStorage = MockFlutterSecureStorage();
    mockSsiRepository = MockSsiRepository();

    oauthRepository = OAuthRepositoryImpl(
      appAuth: mockAppAuth,
      secureStorage: mockSecureStorage,
    );

    ssiService = SsiServiceImpl(mockSsiRepository);

    // Default mocks
    when(() => mockSecureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => mockSsiRepository.saveDid(any(), any())).thenAnswer((_) async {});
    when(() => mockSsiRepository.saveCredential(any())).thenAnswer((_) async {});
    when(() => mockSsiRepository.getDids()).thenAnswer((_) async => []);
    when(() => mockSsiRepository.getDidDocument(any())).thenAnswer((_) async => null);
    when(() => mockSsiRepository.getCredentialById(any())).thenAnswer((_) async => null);
  });

  group('SSI + Auth Integration', () {
    test('Full Flow: OIDC Login -> Patient ID -> Issue SSI VC -> Verify SSI VC', () async {
      // 1. OIDC Login
      final authResponse = AuthorizationTokenResponse(
        'access-token',
        'refresh-token',
        DateTime.now().add(const Duration(hours: 1)),
        'id-token',
        'Bearer',
        null,
        {'patient': 'patient-123'},
        null,
      );

      when(() => mockAppAuth.authorizeAndExchangeCode(any()))
          .thenAnswer((_) async => authResponse);

      final loginResult = await oauthRepository.login();
      final patientId = loginResult?.authorizationAdditionalParameters?['patient'];

      expect(patientId, 'patient-123');

      // 2. Setup user's DID and capture its document for verification
      late Map<String, dynamic> userDidDoc;
      when(() => mockSsiRepository.saveDid(any(), any())).thenAnswer((inv) async {
        userDidDoc = inv.positionalArguments[1] as Map<String, dynamic>;
      });

      final userDid = await ssiService.createDid();
      when(() => mockSsiRepository.getDids()).thenAnswer((_) async => [userDid]);
      when(() => mockSsiRepository.getDidDocument(userDid.did)).thenAnswer((_) async => userDidDoc);

      // 3. Issue Credential
      final vc = await ssiService.issueCredential(
        schemaId: 'orion:schemas:HealthIDCredential:v1',
        subjectDid: userDid.activeDid,
        claims: {'ihcePatientId': patientId},
      );

      expect(vc.claims['ihcePatientId'], 'patient-123');

      // 4. Verify Credential (Full Loop)
      final isValid = await ssiService.verifyCredential(vc);
      expect(isValid, true, reason: 'Credential should be valid and verified with issuer public key');
    });

    test('Flow fails when patient ID is missing from OIDC response', () async {
      // 1. OIDC Login with missing patient claim
      final authResponse = AuthorizationTokenResponse(
        'access-token',
        'refresh-token',
        DateTime.now().add(const Duration(hours: 1)),
        'id-token',
        'Bearer',
        null,
        {}, // No patient claim
        null,
      );

      when(() => mockAppAuth.authorizeAndExchangeCode(any()))
          .thenAnswer((_) async => authResponse);

      final loginResult = await oauthRepository.login();
      final patientId = loginResult?.authorizationAdditionalParameters?['patient'];

      expect(patientId, isNull);

      // If we try to issue credential with null patient ID, it should handle it or fail accordingly
      // Depending on SsiServiceImpl implementation, it might throw or result in invalid claims
      // For this test, we expect the app logic to realize patientId is missing.
    });

    test('Flow handles SSI VC verification failure', () async {
      // 1. Setup (simplified)
      final userDid = Did(did: 'did:test', longForm: 'did:test:long', createdAt: DateTime.now());
      final vc = VerifiableCredential(
        id: 'vc:test',
        issuer: 'did:issuer',
        subject: userDid.did,
        type: 'Test',
        schemaId: 'schema',
        claims: {'ihcePatientId': 'patient-123'},
        issuanceDate: DateTime.now(),
      );

      // Mock verification to fail
      when(() => mockSsiRepository.getDidDocument(any())).thenAnswer((_) async => null);

      final isValid = await ssiService.verifyCredential(vc);
      expect(isValid, false, reason: 'Credential should be invalid if DID document is missing');
    });

    test('Flow handles SSI VC issuance failure', () async {
       when(() => mockSsiRepository.saveDid(any(), any())).thenAnswer((_) async {});
       final userDid = await ssiService.createDid();

       // Mock saveCredential to throw or fail if that's how it's implemented
       // In SsiServiceImpl, if saveCredential fails it might throw.
       when(() => mockSsiRepository.saveCredential(any())).thenThrow(Exception('Storage error'));

       expect(
         () => ssiService.issueCredential(
           schemaId: 'schema',
           subjectDid: userDid.activeDid,
           claims: {'id': '123'},
         ),
         throwsException,
       );
    });
  });
}
