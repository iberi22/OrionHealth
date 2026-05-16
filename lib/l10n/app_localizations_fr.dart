// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'OrionHealth';

  @override
  String get home => 'Accueil';

  @override
  String get reports => 'Rapports';

  @override
  String get records => 'Dossiers';

  @override
  String get profile => 'Profil';

  @override
  String get homeTitle => 'Accueil';

  @override
  String get homeSubtitle =>
      'Gérez votre santé et consultez votre assistant intelligent';

  @override
  String get profileTitle => 'Profil Utilisateur';

  @override
  String get personalInfo => 'Informations Personnelles';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get birthDate => 'Date de Naissance';

  @override
  String get contactNumber => 'Numéro de Contact';

  @override
  String get bleDataExchange => 'Échange de Données BLE';

  @override
  String get shareMyData => 'Partager mes Données';

  @override
  String get receiveData => 'Recevoir des Données';

  @override
  String get appPreferences => 'Préférences de l\'App';

  @override
  String get pushNotifications => 'Notifications Push';

  @override
  String get theme => 'Thème';

  @override
  String get llmSettings => 'Paramètres LLM';

  @override
  String get aboutOrionHealth => 'À propos d\'OrionHealth';

  @override
  String get privacySecurity => 'Confidentialité et Sécurité';

  @override
  String get saveChanges => 'Enregistrer les Modifications';

  @override
  String get logOut => 'Déconnexion';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get sendHistoryToDoctor => 'Send history to doctor';

  @override
  String get receiverMode => 'Receiver mode (Doctor)';

  @override
  String get aiModelPreferences => 'AI model and preferences';

  @override
  String get ourMissionVision => 'Our mission and vision';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get allowCloudApi => 'Allow cloud API calls';

  @override
  String get anonymizationActive => 'Active anonymization if ON';

  @override
  String get changePassword => 'Change Password';
}
