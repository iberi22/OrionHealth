import 'package:health/health.dart';
import 'package:injectable/injectable.dart';
import '../../../vitals/domain/entities/vital_sign.dart';
import '../../application/health_import_state.dart';

@lazySingleton
class HealthDataImportService {
  Health? _healthClient;
  bool _configured = false;

  static final List<HealthDataType> _desiredDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.HEIGHT,
    HealthDataType.WEIGHT,
    HealthDataType.BLOOD_OXYGEN,
  ];

  static final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<Health> _getHealthClient() async {
    _healthClient ??= Health();
    if (!_configured) {
      await _healthClient!.configure();
      _configured = true;
    }
    return _healthClient!;
  }

  Future<List<HealthDataSource>> getAvailableSources() async {
    final health = await _getHealthClient();
    final List<HealthDataSource> available = [];

    try {
      final hasPermissions = await health.hasPermissions(_desiredDataTypes);
      if (hasPermissions == true) {
        available.add(HealthDataSource.googleFit);
      }
    } catch (_) {
      // Permissions check failed
    }

    // Always offer Google Fit as an option (Health Connect on Android)
    if (!available.contains(HealthDataSource.googleFit)) {
      available.add(HealthDataSource.googleFit);
    }

    return available;
  }

  Future<bool> requestAuthorization(HealthDataSource source) async {
    final health = await _getHealthClient();
    return await health.requestAuthorization(
      _desiredDataTypes,
      permissions: _permissions,
    );
  }

  Future<List<HealthDataPoint>> _fetchData(HealthDataType type) async {
    final health = await _getHealthClient();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    return await health.getHealthDataFromTypes(
      types: [type],
      startTime: thirtyDaysAgo,
      endTime: now,
    );
  }

  Future<List<HealthDataPoint>> fetchSteps() => _fetchData(HealthDataType.STEPS);
  Future<List<HealthDataPoint>> fetchDistance() => _fetchData(HealthDataType.DISTANCE_WALKING_RUNNING);
  Future<List<HealthDataPoint>> fetchHeartRate() => _fetchData(HealthDataType.HEART_RATE);
  Future<List<HealthDataPoint>> fetchSleep() => _fetchData(HealthDataType.SLEEP_SESSION);
  Future<List<HealthDataPoint>> fetchBloodGlucose() => _fetchData(HealthDataType.BLOOD_GLUCOSE);

  Future<List<HealthDataPoint>> fetchBloodPressure() async {
    final health = await _getHealthClient();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final systolicData = await health.getHealthDataFromTypes(
      types: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
      startTime: thirtyDaysAgo,
      endTime: now,
    );
    final diastolicData = await health.getHealthDataFromTypes(
      types: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
      startTime: thirtyDaysAgo,
      endTime: now,
    );
    
    return [...systolicData, ...diastolicData];
  }

  Future<List<HealthDataPoint>> fetchHeight() => _fetchData(HealthDataType.HEIGHT);
  Future<List<HealthDataPoint>> fetchWeight() => _fetchData(HealthDataType.WEIGHT);
  Future<List<HealthDataPoint>> fetchOxygenSaturation() => _fetchData(HealthDataType.BLOOD_OXYGEN);

  Future<List<VitalSign>> convertToVitalSigns(
    List<HealthDataPoint> healthData,
    HealthDataSource source,
  ) async {
    final List<VitalSign> vitalSigns = [];
    for (final data in healthData) {
      final vitalSign = _mapHealthDataToVitalSign(data, source);
      if (vitalSign != null) {
        vitalSigns.add(vitalSign);
      }
    }
    return vitalSigns;
  }

  VitalSign? _mapHealthDataToVitalSign(
    HealthDataPoint data,
    HealthDataSource source,
  ) {
    final sourceString = source.sourceKey;
    
    // Extract numeric value from HealthDataPoint
    double? extractValue(HealthDataPoint dp) {
      if (dp.value is NumericHealthValue) {
        final numeric = dp.value as NumericHealthValue;
        return numeric.numericValue.toDouble();
      }
      return null;
    }

    final value = extractValue(data);
    if (value == null) return null;

    switch (data.type) {
      case HealthDataType.STEPS:
        return VitalSign(
          type: VitalSignType.steps,
          value: value,
          unit: 'steps',
          dateTime: data.dateFrom,
          source: sourceString,
        );

      case HealthDataType.DISTANCE_WALKING_RUNNING:
        // Distance is in meters; store as active minutes proxy with notes
        return VitalSign(
          type: VitalSignType.steps,
          value: value / 1000, // Convert to km
          unit: 'km',
          dateTime: data.dateFrom,
          source: sourceString,
          notes: 'Distance walked/run',
        );

      case HealthDataType.HEART_RATE:
        return VitalSign(
          type: VitalSignType.heartRate,
          value: value,
          unit: 'bpm',
          dateTime: data.dateFrom,
          source: sourceString,
        );

      case HealthDataType.SLEEP_SESSION:
        return VitalSign(
          type: VitalSignType.sleep,
          value: value,
          unit: 'min',
          dateTime: data.dateFrom,
          source: sourceString,
        );

      case HealthDataType.BLOOD_GLUCOSE:
        return VitalSign(
          type: VitalSignType.bloodGlucose,
          value: value,
          unit: 'mg/dL',
          dateTime: data.dateFrom,
          source: sourceString,
        );

      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        return VitalSign(
          type: VitalSignType.bloodPressureSystolic,
          value: value,
          unit: 'mmHg',
          dateTime: data.dateFrom,
          source: sourceString,
        );

      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return VitalSign(
          type: VitalSignType.bloodPressureDiastolic,
          value: value,
          unit: 'mmHg',
          dateTime: data.dateFrom,
          source: sourceString,
        );

      case HealthDataType.HEIGHT:
        // Height comes in meters, convert to cm
        return VitalSign(
          type: VitalSignType.temperature,
          value: value * 100,
          unit: 'cm',
          dateTime: data.dateFrom,
          source: sourceString,
          notes: 'Height',
        );

      case HealthDataType.WEIGHT:
        return VitalSign(
          type: VitalSignType.temperature,
          value: value,
          unit: 'kg',
          dateTime: data.dateFrom,
          source: sourceString,
          notes: 'Weight',
        );

      case HealthDataType.BLOOD_OXYGEN:
        return VitalSign(
          type: VitalSignType.oxygenSaturation,
          value: value,
          unit: '%',
          dateTime: data.dateFrom,
          source: sourceString,
        );

      default:
        return null;
    }
  }
}
