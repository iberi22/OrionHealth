import 'package:medical_standards/medical_standards.dart';
import '../../domain/entities/medical_insight.dart';

/// Analyzes vital signs against clinical guidelines
import "package:injectable/injectable.dart";
class VitalSignAnalyzer {
@lazySingleton
  /// Analyze blood pressure reading
  Future<VitalSignInterpretation> analyzeBloodPressure({
    required double systolic,
    required double diastolic,
    int? age,
  }) async {
    final result = _getBpStatus(systolic, diastolic);
    final guideline = await ClinicalGuidelines.findByCode('AHA-2017');

    return VitalSignInterpretation(
      vitalType: 'blood_pressure',
      value: '$systolic/$diastolic',
      unit: 'mmHg',
      category: result.category.name,
      severity: result.severity,
      recommendations: result.recommendations,
      guideline: guideline,
    );
  }

  _BpResult _getBpStatus(double systolic, double diastolic) {
    if (systolic >= 180 || diastolic >= 120) {
      return const _BpResult(
        BpCategory.crisis,
        InsightSeverity.critical,
        ['Hypertensive crisis - seek immediate care', 'Call 911 or emergency services'],
      );
    }
    if (systolic >= 140 || diastolic >= 90) {
      return const _BpResult(
        BpCategory.stage2,
        InsightSeverity.alert,
        ['Stage 2 hypertension - consult physician', 'Consider medication adjustment', 'Reduce sodium intake'],
      );
    }
    if (systolic >= 130 || diastolic >= 80) {
      return const _BpResult(
        BpCategory.stage1,
        InsightSeverity.warning,
        ['Stage 1 hypertension - lifestyle modifications', 'Increase physical activity', 'DASH diet recommended'],
      );
    }
    if (systolic >= 120 && diastolic < 80) {
      return const _BpResult(
        BpCategory.elevated,
        InsightSeverity.info,
        ['Elevated blood pressure', 'Lifestyle changes recommended'],
      );
    }
    return const _BpResult(
      BpCategory.normal,
      InsightSeverity.info,
      ['Blood pressure within normal range'],
    );
  }

  /// Analyze heart rate
  VitalSignInterpretation analyzeHeartRate({
    required double rate,
    bool isResting = true,
  }) {
    final status = isResting ? _getRestingHrStatus(rate) : _getActiveHrStatus(rate);

    return VitalSignInterpretation(
      vitalType: 'heart_rate',
      value: rate.toString(),
      unit: 'bpm',
      category: status.category,
      severity: status.severity,
      recommendations: _heartRateRecommendations(status.category),
      guideline: null,
    );
  }

  _HrStatus _getRestingHrStatus(double rate) {
    if (rate < 40) return const _HrStatus('bradycardia', InsightSeverity.alert);
    if (rate < 60) return const _HrStatus('low-normal', InsightSeverity.info);
    if (rate <= 100) return const _HrStatus('normal', InsightSeverity.info);
    if (rate <= 150) return const _HrStatus('elevated', InsightSeverity.warning);
    return const _HrStatus('tachycardia', InsightSeverity.alert);
  }

  _HrStatus _getActiveHrStatus(double rate) {
    if (rate < 100) return const _HrStatus('inadequate response', InsightSeverity.warning);
    if (rate <= 200) return const _HrStatus('normal response', InsightSeverity.info);
    return const _HrStatus('excessive response', InsightSeverity.alert);
  }

  /// Analyze oxygen saturation
  VitalSignInterpretation analyzeOxygenSaturation({
    required double spo2,
  }) {
    final result = _getSpo2Status(spo2);

    return VitalSignInterpretation(
      vitalType: 'oxygen_saturation',
      value: spo2.toString(),
      unit: '%',
      category: result.category,
      severity: result.severity,
      recommendations: result.recommendations,
      guideline: null,
    );
  }

  _StatusResult _getSpo2Status(double spo2) {
    if (spo2 < 90) {
      return const _StatusResult('severe hypoxemia', InsightSeverity.critical, ['Severe hypoxemia - emergency care needed']);
    }
    if (spo2 < 94) {
      return const _StatusResult('hypoxemia', InsightSeverity.alert, ['Low oxygen - consult physician']);
    }
    if (spo2 < 96) {
      return const _StatusResult('mild hypoxemia', InsightSeverity.warning, ['Monitor closely']);
    }
    return const _StatusResult('normal', InsightSeverity.info, ['Oxygen saturation normal']);
  }

  /// Analyze temperature
  VitalSignInterpretation analyzeTemperature({
    required double temp,
    String unit = 'C',
  }) {
    double tempC = unit == 'F' ? (temp - 32) * 5 / 9 : temp;
    final result = _getTempStatus(tempC);

    return VitalSignInterpretation(
      vitalType: 'temperature',
      value: '${temp.toStringAsFixed(1)}°$unit',
      unit: '°$unit',
      category: result.category,
      severity: result.severity,
      recommendations: result.recommendations,
      guideline: null,
    );
  }

  _StatusResult _getTempStatus(double tempC) {
    if (tempC < 35.0) return const _StatusResult('hypothermia', InsightSeverity.alert, ['Low body temperature']);
    if (tempC < 36.5) return const _StatusResult('low-normal', InsightSeverity.info, []);
    if (tempC <= 37.5) return const _StatusResult('normal', InsightSeverity.info, ['Temperature normal']);
    if (tempC <= 38.0) return const _StatusResult('mild elevated', InsightSeverity.info, ['Low-grade fever - monitor']);
    if (tempC <= 39.5) return const _StatusResult('fever', InsightSeverity.warning, ['Fever - stay hydrated']);
    return const _StatusResult('high fever', InsightSeverity.alert, ['High fever - consider antipyretics', 'Very high fever - seek medical attention']);
  }

  /// Generate insights from vital sign interpretations
  List<MedicalInsight> generateInsights(List<VitalSignInterpretation> interpretations) {
    return interpretations.map((i) => MedicalInsight(
      id: 'vital-${i.vitalType}-${DateTime.now().millisecondsSinceEpoch}',
      title: '${_vitalDisplayName(i.vitalType)} Analysis',
      description: '${_vitalDisplayName(i.vitalType)}: ${i.value} ${i.unit} — ${i.category}',
      severity: i.severity,
      category: InsightCategory.vitalSignAnalysis,
      guidelineReference: i.guideline?.code,
      recommendations: i.recommendations,
      generatedAt: DateTime.now(),
      evidence: {'category': i.category, 'vitalType': i.vitalType},
    )).toList();
  }

  List<String> _heartRateRecommendations(String category) {
    switch (category) {
      case 'bradycardia':
        return ['Consult cardiologist', 'May need pacemaker evaluation'];
      case 'tachycardia':
        return ['Rule out arrhythmia', 'Reduce caffeine/alcohol', 'Stress management'];
      case 'inadequate response':
        return ['Consider fitness improvement', 'Cardiac evaluation recommended'];
      default:
        return ['Continue regular monitoring'];
    }
  }

  String _vitalDisplayName(String vitalType) {
    switch (vitalType) {
      case 'blood_pressure':
        return 'Blood Pressure';
      case 'heart_rate':
        return 'Heart Rate';
      case 'oxygen_saturation':
        return 'Oxygen Saturation';
      case 'temperature':
        return 'Temperature';
      default:
        return vitalType;
    }
  }
}

class _BpResult {
  final BpCategory category;
  final InsightSeverity severity;
  final List<String> recommendations;
  const _BpResult(this.category, this.severity, this.recommendations);
}

class _HrStatus {
  final String category;
  final InsightSeverity severity;
  const _HrStatus(this.category, this.severity);
}

class _StatusResult {
  final String category;
  final InsightSeverity severity;
  final List<String> recommendations;
  const _StatusResult(this.category, this.severity, this.recommendations);
}

/// Blood pressure categories per AHA guidelines
enum BpCategory { normal, elevated, stage1, stage2, crisis }

/// Vital sign interpretation result
class VitalSignInterpretation {
  final String vitalType;
  final String value;
  final String unit;
  final String category;
  final InsightSeverity severity;
  final List<String> recommendations;
  final ClinicalGuidelineReference? guideline;

  const VitalSignInterpretation({
    required this.vitalType,
    required this.value,
    required this.unit,
    required this.category,
    required this.severity,
    required this.recommendations,
    this.guideline,
  });
}
