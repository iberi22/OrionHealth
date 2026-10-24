// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2026 SouthWest AI Labs

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/audio/audio_recorder_service.dart';

/// Third-party and platform objects that generated factories depend on but that no
/// class registers itself. Without them those factories threw "not registered" on
/// the device (found by the critical-flows E2E).
@module
abstract class PlatformModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer();

  @lazySingleton
  AudioRecorderService get audioRecorderService => AudioRecorderService();

  @lazySingleton
  DeviceCalendarPlugin get deviceCalendarPlugin => DeviceCalendarPlugin();

  /// Only consumer: NfcHandler (health sharing over NFC).
  @lazySingleton
  MethodChannel get nfcChannel => const MethodChannel('orionhealth/nfc');

  /// Remote model, only used when the user enables it; the key comes from the build.
  @lazySingleton
  GenerativeModel get generativeModel => GenerativeModel(
    model: 'gemini-pro',
    apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
  );
}
