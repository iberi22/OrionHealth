import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/features/sync/presentation/pages/sync_page.dart';
import 'package:orionhealth_health/features/sync/application/sync_cubit.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/fhir_client.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:orionhealth_health/features/sync/infrastructure/repositories/sync_repository_impl.dart';
import 'package:orionhealth_health/features/sync/domain/services/node_discovery_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:medical_standards/medical_standards.dart' as ms;
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/video_recorder.dart';

class MockFhirClient extends Mock implements FhirClient {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockNodeDiscoveryService extends Mock implements NodeDiscoveryService {}
class MockMedicalStandardsSyncService extends Mock implements ms.SyncService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockFhirClient mockFhirClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockNodeDiscoveryService mockDiscoveryService;
  late MockMedicalStandardsSyncService mockMedicalStandardsSync;
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(libraries: {Abi.linuxX64: '/tmp/libisar.so'});
  });

  setUp(() async {
    mockFhirClient = MockFhirClient();
    mockSecureStorage = MockFlutterSecureStorage();
    mockDiscoveryService = MockNodeDiscoveryService();
    mockMedicalStandardsSync = MockMedicalStandardsSyncService();

    when(() => mockDiscoveryService.discoveredNodes).thenAnswer((_) => Stream.value([]));
    when(() => mockDiscoveryService.currentNodes).thenReturn([]);
    when(() => mockSecureStorage.read(key: 'ihce_access_token'))
        .thenAnswer((_) async => 'valid_fhir_token_123');
    when(() => mockMedicalStandardsSync.syncAll()).thenAnswer((_) async => []);

    SharedPreferences.setMockInitialValues({});

    final tempDir = await Directory.systemTemp.createTemp();
    isar = await Isar.open(
      [UserProfileSchema, MedicationSchema, AllergySchema, VitalSignSchema],
      directory: tempDir.path,
    );

    // Pre-seed UserProfile with Patient EPS ID
    final profile = UserProfile(
      uniqueId: 'fhir_usr_1',
      epsPatientId: 'PAT-FHIR-99',
      name: 'Old Patient Name',
    );
    await isar.writeTxn(() => isar.collection<UserProfile>().put(profile));
  });

  tearDown(() async {
    await isar.close();
  });

  Widget buildSyncPageWidget(FhirSyncCubit cubit) {
    return MaterialApp(
      home: BlocProvider<FhirSyncCubit>.value(
        value: cubit,
        child: const SyncPage(),
      ),
      theme: ThemeData.dark(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  group('E2E FHIR R4 Sync Flow', () {
    testWidgets('E2E FHIR R4: Full sync converts Patient and RDA Bundle to Isar entities and updates UI',
        (WidgetTester tester) async {
      // Setup mock FHIR responses
      final patientFhirJson = {
        'resourceType': 'Patient',
        'id': 'PAT-FHIR-99',
        'name': [
          {
            'given': ['Ana'],
            'family': 'Gómez'
          }
        ]
      };

      final rdaBundleJson = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Composition',
              'id': 'comp_01',
              'section': [
                {
                  'title': 'Sección Médica FHIR',
                  'entry': [
                    {'reference': 'MedicationStatement/med_1'},
                    {'reference': 'AllergyIntolerance/alg_1'},
                    {'reference': 'Observation/obs_1'},
                  ]
                }
              ]
            }
          },
          {
            'fullUrl': 'MedicationStatement/med_1',
            'resource': {
              'resourceType': 'MedicationStatement',
              'status': 'active',
              'medicationCodeableConcept': {'text': 'Losartán 50mg'},
              'effectiveDateTime': '2025-01-15T08:00:00Z'
            }
          },
          {
            'fullUrl': 'AllergyIntolerance/alg_1',
            'resource': {
              'resourceType': 'AllergyIntolerance',
              'code': {'text': 'Aspirina'},
              'criticality': 'high',
              'onsetDateTime': '2024-05-10T00:00:00Z'
            }
          },
          {
            'fullUrl': 'Observation/obs_1',
            'resource': {
              'resourceType': 'Observation',
              'code': {
                'coding': [
                  {'system': 'http://loinc.org', 'code': '8867-4'}
                ]
              },
              'valueQuantity': {'value': 72, 'unit': 'bpm'},
              'effectiveDateTime': '2025-01-15T10:00:00Z'
            }
          }
        ]
      };

      when(() => mockFhirClient.getPatient('PAT-FHIR-99', 'valid_fhir_token_123'))
          .thenAnswer((_) async => patientFhirJson);
      when(() => mockFhirClient.getRDA('PAT-FHIR-99', 'valid_fhir_token_123'))
          .thenAnswer((_) async => rdaBundleJson);

      final repository = SyncRepositoryImpl(
        mockFhirClient,
        isar,
        mockSecureStorage,
        mockDiscoveryService,
      );
      final syncServiceImpl = SyncServiceImpl(repository, mockMedicalStandardsSync);
      final cubit = FhirSyncCubit(syncServiceImpl, mockDiscoveryService);

      await tester.pumpWidget(buildSyncPageWidget(cubit));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'fhir_sync', '01_initial_state');

      // Verify Initial Screen
      expect(find.text('Sincronización'), findsWidgets);
      expect(find.text('SINCRONIZAR AHORA'), findsOneWidget);

      // Trigger FHIR Sync
      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pump(); // Start loading
      await VideoRecorder.recordStep(tester, 'fhir_sync', '02_syncing_in_progress');

      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'fhir_sync', '03_sync_completed');

      // Verify UI state updated to Success
      expect(find.textContaining('Éxito'), findsWidgets);

      // Verify local Isar database contains updated profile and synced FHIR resources
      final updatedProfile = await isar.collection<UserProfile>().where().findFirst();
      expect(updatedProfile?.name, 'Ana Gómez');

      final storedMeds = await isar.collection<Medication>().where().findAll();
      expect(storedMeds.length, 1);
      expect(storedMeds.first.name, 'Losartán 50mg');

      final storedAllergies = await isar.collection<Allergy>().where().findAll();
      expect(storedAllergies.length, 1);
      expect(storedAllergies.first.allergen, 'Aspirina');

      final storedVitals = await isar.collection<VitalSign>().where().findAll();
      expect(storedVitals.length, 1);
      expect(storedVitals.first.value, 72.0);

      cubit.close();
    });
  });
}
