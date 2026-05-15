// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OrionHealth';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeSubtitle =>
      'Manage your health and consult your smart assistant';

  @override
  String get navHome => 'Home';

  @override
  String get navAppointments => 'Appointments';

  @override
  String get navFiles => 'Files';

  @override
  String get navProfile => 'Profile';
}
