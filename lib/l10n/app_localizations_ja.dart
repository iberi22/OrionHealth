// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'OrionHealth';

  @override
  String get home => 'ホーム';

  @override
  String get reports => 'レポート';

  @override
  String get records => '記録';

  @override
  String get profile => 'プロフィール';

  @override
  String get homeTitle => 'ホーム';

  @override
  String get homeSubtitle => 'あなたの健康を管理し、インテリジェントアシスタントに相談してください';

  @override
  String get profileTitle => 'ユーザープロフィール';

  @override
  String get personalInfo => '個人情報';

  @override
  String get fullName => '氏名';

  @override
  String get birthDate => '生年月日';

  @override
  String get contactNumber => '連絡先番号';

  @override
  String get bleDataExchange => 'BLEデータ交換';

  @override
  String get shareMyData => 'データを共有する';

  @override
  String get receiveData => 'データを受信する';

  @override
  String get appPreferences => 'アプリの設定';

  @override
  String get pushNotifications => 'プッシュ通知';

  @override
  String get theme => 'テーマ';

  @override
  String get llmSettings => 'LLM設定';

  @override
  String get aboutOrionHealth => 'OrionHealthについて';

  @override
  String get privacySecurity => 'プライバシーとセキュリティ';

  @override
  String get saveChanges => '変更を保存';

  @override
  String get logOut => 'ログアウト';

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
