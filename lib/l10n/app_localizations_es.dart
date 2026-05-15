// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OrionHealth';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get homeSubtitle =>
      'Gestiona tu salud y consulta tu asistente inteligente';

  @override
  String get navHome => 'Inicio';

  @override
  String get navAppointments => 'Citas';

  @override
  String get navFiles => 'Archivos';

  @override
  String get navProfile => 'Perfil';
}
