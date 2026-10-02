import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/ecosystem_subject_store.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/ecosystem_import_service.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/ecosystem_dietary_export_service.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/domain/repositories/allergy_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(
          File(
            'packages/health_contract/test/fixtures/valid/$name.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

class Subjects implements EcosystemSubjectStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> bind(String subject) async {
    value = subject;
  }
}

class Records implements EcosystemRecordStore {
  List<Map<String, dynamic>> saved = [];
  @override
  Future<void> save(List<Map<String, dynamic>> records) async {
    saved.addAll(records);
  }

  @override
  Future<String?> latestDataset() async => null;
}

class Allergies implements AllergyRepository {
  @override
  Future<List<Allergy>> getAllergies() async => [
    Allergy(allergen: 'maní'),
    Allergy(allergen: 'penicillin', notes: 'private clinical details'),
  ];
  @override
  Future<void> saveAllergy(Allergy allergy) async {}
  @override
  Future<void> deleteAllergy(int id) async {}
}

class Profiles implements UserProfileRepository {
  final UserProfile profile = UserProfile(
    name: 'Private name',
    medicalConditions: ['secret'],
    dietaryGoalsKcalPerDay: 2200,
    dietaryGoalsProteinGPerDay: 140,
    dietaryPreferences: ['gos:diet/mediterranean'],
  );
  @override
  Future<UserProfile?> getUserProfile() async => profile;
  @override
  Future<void> saveUserProfile(UserProfile profile) async {}
  @override
  Future<void> deleteUserProfile() async {}
}

void main() {
  test(
    'all shared valid fixtures preview and save with application clock',
    () async {
      final directory = Directory(
        'packages/health_contract/test/fixtures/valid',
      );
      final files = directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'));
      for (final file in files) {
        final record =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final store = Records();
        final service = EcosystemImportService.withClock(
          Subjects(),
          store,
          () => DateTime.utc(2026, 10, 2),
        );
        final preview = await service.preview([record]);
        await service.save(preview, consent: true, bindSubject: true);
        expect(store.saved.single, record, reason: file.path);
      }
    },
  );
  test('accepted lowercase timestamp separators remain importable', () async {
    final record = fixture('workout-session-01');
    final data = record['data'] as Map;
    data['startedAt'] = '2026-10-02t18:00:00z';
    data['endedAt'] = '2026-10-02t19:00:00z';
    final service = EcosystemImportService(Subjects(), Records());
    expect((await service.preview([record])).records.single, record);
  });

  test(
    'local subject survives store recreation and serializes concurrent binding',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = LocalEcosystemSubjectStore();
      final first = store.bind('subj_01J00000000000000000000000');
      final second = store.bind('subj_01J00000000000000000000001');
      await first;
      await expectLater(second, throwsFormatException);
      expect(
        await LocalEcosystemSubjectStore().read(),
        'subj_01J00000000000000000000000',
      );
    },
  );

  test(
    'import needs consent and first subject binding, then rejects foreign subjects',
    () async {
      final subjects = Subjects();
      final records = Records();
      final service = EcosystemImportService(subjects, records);
      final meal = fixture('meal-log-01');
      final preview = await service.preview([meal]);
      expect(preview.requiresSubjectBinding, true);
      await expectLater(
        service.save(preview, consent: false, bindSubject: true),
        throwsFormatException,
      );
      await expectLater(
        service.save(preview, consent: true),
        throwsFormatException,
      );
      expect(records.saved, isEmpty);
      expect(await service.save(preview, consent: true, bindSubject: true), 1);
      expect(records.saved.single, meal);
      final foreign = fixture('meal-log-01')
        ..['subject'] = 'subj_01J00000000000000000000001';
      await expectLater(service.preview([foreign]), throwsFormatException);
    },
  );
  test(
    'preview snapshots input and rejects malformed records before persistence',
    () async {
      final records = Records();
      final service = EcosystemImportService(Subjects(), records);
      final meal = fixture('meal-log-01');
      final original = fixture('meal-log-01');
      final preview = await service.preview([meal]);
      (meal['data'] as Map)['mealType'] = 'invalid';
      await service.save(preview, consent: true, bindSubject: true);
      expect(records.saved.single, original);
      await expectLater(service.preview([meal]), throwsA(isA<Exception>()));
    },
  );
  test('application enforces workout ordering and dietary expiry', () async {
    final service = EcosystemImportService.withClock(
      Subjects(),
      Records(),
      () => DateTime.utc(2030),
    );
    final workout = fixture('workout-session-01');
    final data = workout['data'] as Map;
    data['endedAt'] = '2020-01-01T00:00:00Z';
    await expectLater(service.preview([workout]), throwsFormatException);
    await expectLater(
      service.preview([fixture('dietary-profile-01')]),
      throwsFormatException,
    );
  });
  test('simultaneous first imports cannot bind different subjects', () async {
    final subjects = Subjects();
    final records = Records();
    final service = EcosystemImportService(subjects, records);
    final first = await service.preview([fixture('meal-log-01')]);
    final secondMeal = fixture('meal-log-01')
      ..['subject'] = 'subj_01J00000000000000000000001';
    final second = await service.preview([secondMeal]);
    final one = service.save(first, consent: true, bindSubject: true);
    final two = service.save(second, consent: true, bindSubject: true);
    expect(await one, 1);
    await expectLater(two, throwsFormatException);
    expect(records.saved, hasLength(1));
  });
  test(
    'dietary export contains only restrictions, explicit goals and pseudonym',
    () async {
      final subjects = Subjects();
      final service = DietaryProfileExportService(
        Allergies(),
        Profiles(),
        subjects,
      );
      final draft = await service.build(
        gosDataset: fixture('meal-log-01')['gosDataset'] as String,
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect((draft.record['data'] as Map)['allergens'], [
        'gos:allergen/peanut',
      ]);
      expect((draft.record['data'] as Map)['targets'], {
        'kcalPerDay': 2200.0,
        'proteinGPerDay': 140.0,
      });
      expect(draft.unmappedAllergens, ['penicillin']);
      expect(jsonEncode(draft.record), isNot(contains('Private name')));
      expect(jsonEncode(draft.record), isNot(contains('secret')));
      expect(
        jsonEncode(draft.record),
        isNot(contains('private clinical details')),
      );
      expect(subjects.value, isNull);
      await expectLater(
        service.confirm(draft, consent: false),
        throwsFormatException,
      );
      await service.confirm(draft, consent: true);
      expect(draft.record['subject'], subjects.value);
      final next = await service.build(
        gosDataset: draft.record['gosDataset'] as String,
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(next.record['subject'], draft.record['subject']);
      expect(next.record['id'], isNot(draft.record['id']));
    },
  );
}
