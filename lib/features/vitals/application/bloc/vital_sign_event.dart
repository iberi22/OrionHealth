part of 'vital_sign_bloc.dart';

abstract class VitalSignEvent {}

class LoadVitalSigns extends VitalSignEvent {}

class LoadLatestVitals extends VitalSignEvent {}

class SaveVitalSign extends VitalSignEvent {
  final VitalSign vitalSign;
  SaveVitalSign(this.vitalSign);
}

class SaveVitalSigns extends VitalSignEvent {
  final List<VitalSign> vitalSigns;
  SaveVitalSigns(this.vitalSigns);
}
