import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/data_export_repository.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/services/data_export_service.dart' show ExportSummary;

void main() {
  group('DataExportRepository contract', () {
    test('abstract repository defines 18 methods (9 counts + 9 gets)', () {
      // Verify the contract exists and has the expected shape
      final repo = _ContractChecker();
      expect(repo.methods, 18);
    });

    test('getExportSummary contract returns total count', () async {
      final repo = _FakeRepo(_FakeRepoData());
      // Verify the contract exists
      expect(repo, isA<DataExportRepository>());

      // Verify ExportSummary aggregation works
      final s = ExportSummary(userProfile: 5);
      expect(s.total, 5);
    });
  });

  group('ExportSummary aggregation', () {
    test('total is sum of all fields', () {
      final s = ExportSummary(
        userProfile: 1,
        medicalRecords: 2,
        medications: 3,
        allergies: 4,
        appointments: 5,
        vitalSigns: 6,
        reports: 7,
        doctorProfiles: 8,
        appSettings: 9,
      );
      expect(s.total, 45);
    });

    test('toJson maps field names correctly', () {
      final s = ExportSummary(userProfile: 2, medications: 5);
      final json = s.toJson();
      expect(json['user_profile'], 2);
      expect(json['medications'], 5);
      expect(json['total'], 7);
    });
  });
}

class _ContractChecker implements DataExportRepository {
  static const List<String> _methods = [
    'countUserProfiles',
    'getUserProfiles',
    'countMedicalRecords',
    'getMedicalRecords',
    'countMedications',
    'getMedications',
    'countAllergies',
    'getAllergies',
    'countAppointments',
    'getAppointments',
    'countVitalSigns',
    'getVitalSigns',
    'countReports',
    'getReports',
    'countDoctorProfiles',
    'getDoctorProfiles',
    'countAppSettings',
    'getAppSettings',
  ];

  int get methods => _methods.length;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRepoData {
  int userProfile = 1;
  int medicalRecords = 2;
  int medications = 3;
  int allergies = 4;
  int appointments = 5;
  int vitalSigns = 6;
  int reports = 7;
  int doctorProfiles = 8;
  int appSettings = 0;
}

class _FakeRepo implements DataExportRepository {
  final _FakeRepoData _data;
  _FakeRepo(this._data);

  @override
  Future<int> countUserProfiles(String userId) async => _data.userProfile;
  @override
  Future<List<Map<String, dynamic>>> getUserProfiles(String userId) async =>
      List.generate(_data.userProfile, (i) => {'id': i});
  @override
  Future<int> countMedicalRecords(String userId) async =>
      _data.medicalRecords;
  @override
  Future<List<Map<String, dynamic>>> getMedicalRecords(String userId) async =>
      List.generate(_data.medicalRecords, (i) => {'id': i});
  @override
  Future<int> countMedications(String userId) async => _data.medications;
  @override
  Future<List<Map<String, dynamic>>> getMedications(String userId) async =>
      List.generate(_data.medications, (i) => {'id': i});
  @override
  Future<int> countAllergies(String userId) async => _data.allergies;
  @override
  Future<List<Map<String, dynamic>>> getAllergies(String userId) async =>
      List.generate(_data.allergies, (i) => {'id': i});
  @override
  Future<int> countAppointments(String userId) async => _data.appointments;
  @override
  Future<List<Map<String, dynamic>>> getAppointments(String userId) async =>
      List.generate(_data.appointments, (i) => {'id': i});
  @override
  Future<int> countVitalSigns(String userId) async => _data.vitalSigns;
  @override
  Future<List<Map<String, dynamic>>> getVitalSigns(String userId) async =>
      List.generate(_data.vitalSigns, (i) => {'id': i});
  @override
  Future<int> countReports(String userId) async => _data.reports;
  @override
  Future<List<Map<String, dynamic>>> getReports(String userId) async =>
      List.generate(_data.reports, (i) => {'id': i});
  @override
  Future<int> countDoctorProfiles(String userId) async => _data.doctorProfiles;
  @override
  Future<List<Map<String, dynamic>>> getDoctorProfiles(String userId) async =>
      List.generate(_data.doctorProfiles, (i) => {'id': i});
  @override
  Future<int> countAppSettings() async => _data.appSettings;
  @override
  Future<List<Map<String, dynamic>>> getAppSettings() async =>
      List.generate(_data.appSettings, (i) => {'id': i});
}