import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';

/// Device performance profile based on total RAM.
enum DeviceProfile {
  /// Less than 4 GB RAM — minimal on-device ML, prefer cloud.
  light,

  /// 4–6 GB RAM — balanced local/cloud.
  medium,

  /// More than 6 GB RAM — full on-device ML enabled.
  high,
}

/// Recommended inference mode based on available RAM.
enum ModelRecommendation {
  /// Under 2 GB — cloud inference only.
  cloudOnly,

  /// 2–4 GB — lightweight local models.
  light,

  /// 4–6 GB — standard local models.
  medium,

  /// 6 GB+ — full heavyweight local models.
  heavy,
}

/// Device capability information.
class DeviceCapabilities {
  final int totalRamBytes;
  final String androidAbi;
  final DeviceProfile profile;
  final ModelRecommendation recommendation;

  const DeviceCapabilities({
    required this.totalRamBytes,
    required this.androidAbi,
    required this.profile,
    required this.recommendation,
  });

  double get totalRamGb => totalRamBytes / (1024 * 1024 * 1024);

  @override
  String toString() =>
      'DeviceCapabilities(totalRamGb=${totalRamGb.toStringAsFixed(1)}GB, '
      'androidAbi=$androidAbi, profile=$profile, recommendation=$recommendation)';
}

@lazySingleton
class DeviceCapabilityService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Detects total device RAM in bytes.
  ///
  /// On Android uses ActivityManager.MemoryInfo.totalMem.
  /// Falls back to parsing /proc/meminfo on failure.
  Future<int> _detectTotalRam() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await _deviceInfo.androidInfo;
        // androidInfo.physicalRamSize is the total RAM from ActivityManager.
        return androidInfo.physicalRamSize;
      } catch (_) {
        return _parseMeminfo();
      }
    }
    // For non-Android platforms, return a default mid-range value.
    return 4 * 1024 * 1024 * 1024; // 4 GB default
  }

  /// Parses /proc/meminfo to extract total memory as fallback.
  int _parseMeminfo() {
    try {
      final file = File('/proc/meminfo');
      if (!file.existsSync()) return 4 * 1024 * 1024 * 1024;
      final lines = file.readAsLinesSync();
      // First line: "MemTotal:       16384084 kB"
      if (lines.isEmpty) return 4 * 1024 * 1024 * 1024;
      final match = RegExp(r'^MemTotal:\s+(\d+)\s+kB').firstMatch(lines.first);
      if (match == null) return 4 * 1024 * 1024 * 1024;
      final kb = int.parse(match.group(1)!);
      return kb * 1024;
    } catch (_) {
      return 4 * 1024 * 1024 * 1024;
    }
  }

  /// Detects the primary Android ABI (e.g. 'arm64-v8a', 'armeabi-v7a').
  Future<String> _detectAndroidAbi() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await _deviceInfo.androidInfo;
        // supportedAbis is a list; use the first (preferred) one.
        if (androidInfo.supportedAbis.isNotEmpty) {
          return androidInfo.supportedAbis.first;
        }
      } catch (_) {}
    }
    return 'unknown';
  }

  DeviceProfile _ramToProfile(int totalRamBytes) {
    final gb = totalRamBytes / (1024 * 1024 * 1024);
    if (gb < 4) return DeviceProfile.light;
    if (gb <= 6) return DeviceProfile.medium;
    return DeviceProfile.high;
  }

  ModelRecommendation _ramToRecommendation(int totalRamBytes) {
    final gb = totalRamBytes / (1024 * 1024 * 1024);
    if (gb < 2) return ModelRecommendation.cloudOnly;
    if (gb < 4) return ModelRecommendation.light;
    if (gb <= 6) return ModelRecommendation.medium;
    return ModelRecommendation.heavy;
  }

  /// Returns the full device capability report.
  ///
  /// Results are cached after the first call.
  Future<DeviceCapabilities> getCapabilities() async {
    final ram = await _detectTotalRam();
    final abi = await _detectAndroidAbi();

    return DeviceCapabilities(
      totalRamBytes: ram,
      androidAbi: abi,
      profile: _ramToProfile(ram),
      recommendation: _ramToRecommendation(ram),
    );
  }

  /// Convenience getter that returns only the device profile.
  Future<DeviceProfile> getProfile() async {
    final caps = await getCapabilities();
    return caps.profile;
  }

  /// Convenience getter that returns only the model recommendation.
  Future<ModelRecommendation> getRecommendation() async {
    final caps = await getCapabilities();
    return caps.recommendation;
  }
}
