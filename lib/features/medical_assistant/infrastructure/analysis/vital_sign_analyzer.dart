import 'package:medical_standards/medical_standards.dart';
import '../../domain/entities/medical_insight.dart';

/// Analyzes vital signs against clinical guidelines
class VitalSignAnalyzer {
  /// Analyze blood pressure reading
  Future<VitalSignInterpretation> analyzeBloodPressure({
    required double systolic,
    required double diastolic,
    int? age,
  }) async {
    BpCategory category = BpCategory.normal;
    InsightSeverity severity = InsightSeverity.info;
    final recommendations = <String>[];

    if (systolic >= 180 || diastolic >= 120) {
      category = BpCategory.crisis;
      severity = InsightSeverity.critical;
      recommendations.add('Hypertensive crisis - seek immediate care');
      recommendations.add('Call 911 or emergency services');
    } else if (systolic >= 140 || diastolic >= 90) {
      category = BpCategory.stage2;
      severity = InsightSeverity.alert;
      recommendations.add('Stage 2 hypertension - consult physician');
      recommendations.add('Consider medication adjustment');
      recommendations.add('Reduce sodium intake');
    } else if (systolic >= 130 || diastolic >= 80) {
      category = BpCategory.stage1;
      severity = InsightSeverity.warning;
      recommendations.add('Stage 1 hypertension - lifestyle modifications');
      recommendations.add('Increase physical activity');
      recommendations.add('DASH diet recommended');
    } else if (systolic >= 120 && diastolic < 80) {
      category = BpCategory.elevated;
      severity = InsightSeverity.info;
      recommendations.add('Elevated blood pressure');
      recommendations.add('Lifestyle changes recommended');
    } else {
      category = BpCategory.normal;
      severity = InsightSeverity.info;
      recommendations.add('Blood pressure within normal range');
    }

    final guideline = await ClinicalGuidelines.findByCode('AHA-2017');

    return VitalSignInterpretation(
      vitalType: 'blood_pressure',
      value: '$systolic/$diastolic',
      unit: 'mmHg',
      category: category.name,
      severity: severity,
      recommendations: recommendations,
      guideline: guideline,
    );
  }

  /// Analyze heart rate
  VitalSignInterpretation analyzeHeartRate({
    required double rate,
    bool isResting = true,
  }) {
    InsightSeverity severity = InsightSeverity.info;
    String category = 'normal';

    if (isResting) {
      if (rate < 40) {
        severity = InsightSeverity.alert;
        category = 'bradycardia';
      } else if (rate < 60) {
        severity = InsightSeverity.info;
        category = 'low-normal';
      } else if (rate <= 100) {
        severity = InsightSeverity.info;
        category = 'normal';
      } else if (rate <= 150) {
        severity = InsightSeverity.warning;
        category = 'elevated';
      } else {
        severity = InsightSeverity.alert;
        category = 'tachycardia';
      }
    } else {
      if (rate < 100) {
        severity = InsightSeverity.warning;
        category = 'inadequate response';
      } else if (rate <= 200) {
        severity = InsightSeverity.info;
        category = 'normal response';
      } else {
        severity = InsightSeverity.alert;
        category = 'excessive response';
      }
    }

    return VitalSignInterpretation(
      vitalType: 'heart_rate',
      value: rate.toString(),
      unit: 'bpm',
      category: category,
      severity: severity,
      recommendations: _heartRateRecommendations(category),
      guideline: null,
    );
  }

  /// Analyze oxygen saturation
  VitalSignInterpretation analyzeOxygenSaturation({
    required double spo2,
  }) {
    InsightSeverity severity;
    String category;
    final recommendations = <String>[];

    if (spo2 < 90) {
      severity = InsightSeverity.critical;
      category = 'severe hypoxemia';
      recommendations.add('Severe hypoxemia - emergency care needed');
    } else if (spo2 < 94) {
      severity = InsightSeverity.alert;
      category = 'hypoxemia';
      recommendations.add('Low oxygen - consult physician');
    } else if (spo2 < 96) {
      severity = InsightSeverity.warning;
      category = 'mild hypoxemia';
      recommendations.add('Monitor closely');
    } else {
      severity = InsightSeverity.info;
      category = 'normal';
      recommendations.add('Oxygen saturation normal');
    }

    return VitalSignInterpretation(
      vitalType: 'oxygen_saturation',
      value: spo2.toString(),
      unit: '%',
      category: category,
      severity: severity,
      recommendations: recommendations,
      guideline: null,
    );
  }

  /// Analyze temperature
  VitalSignInterpretation analyzeTemperature({
    required double temp,
    String unit = 'C',
  }) {
    // Convert to Celsius if needed
    double tempC = temp;
    if (unit == 'F') {
      tempC = (temp - 32) * 5 / 9;
    }

    InsightSeverity severity;
    String category;
    final recommendations = <String>[];

    if (tempC < 35.0) {
      severity = InsightSeverity.alert;
      category = 'hypothermia';
      recommendations.add('Low body temperature');
    } else if (tempC < 36.5) {
      severity = InsightSeverity.info;
      category = 'low-normal';
    } else if (tempC <= 37.5) {
      severity = InsightSeverity.info;
      category = 'normal';
      recommendations.add('Temperature normal');
    } else if (tempC <= 38.0) {
      severity = InsightSeverity.info;
      category = 'mild elevated';
      recommendations.add('Low-grade fever - monitor');
    } else if (tempC <= 39.5) {
      severity = InsightSeverity.warning;
      category = 'fever';
      recommendations.add('Fever - stay hydrated');
    } else {
      severity = InsightSeverity.alert;
      category = 'high fever';
      recommendations.add('High fever - consider antipyretics');
      if (tempC > 40.0) {
        recommendations.add('Very high fever - seek medical attention');
      }
    }

    return VitalSignInterpretation(
      vitalType: 'temperature',
      value: '${temp.toStringAsFixed(1)}°$unit',
      unit: '°$unit',
      category: category,
      severity: severity,
      recommendations: recommendations,
      guideline: null,
    );
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
