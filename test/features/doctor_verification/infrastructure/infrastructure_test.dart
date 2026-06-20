import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/infrastructure.dart';

void main() {
  group('Infrastructure Exports Smoke Test', () {
    test('should export all required classes', () {
      // Data sources
      expect(LicenseRegistryLocalDataSource, isNotNull);

      // Models
      expect(DoctorProfileModel, isNotNull);
      expect(DoctorRatingModel, isNotNull);
      expect(SecondOpinionRequestModel, isNotNull);
      expect(SecondOpinionResponseModel, isNotNull);
      expect(VouchModel, isNotNull);

      // Repositories
      expect(IsarDoctorProfileRepository, isNotNull);
      expect(IsarRatingRepository, isNotNull);
      expect(IsarSecondOpinionRepository, isNotNull);
      expect(IsarVouchRepository, isNotNull);
    });
  });
}
