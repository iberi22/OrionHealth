import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import '../services/aicore_service.dart';
import 'dart:io';

enum DeviceProfile {
  light,     // Under 4GB RAM
  medium,    // 4-6GB RAM
  highEnd    // 6GB+ RAM
}

enum ModelRecommendation {
  model2B,
  model7B,
  model9B,
  cloudOnly
}

@lazySingleton
class DeviceCapabilityService {
  final AicoreService _aicoreService;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  DeviceCapabilityService(this._aicoreService);

  Future<DeviceHardwareInfo> getDeviceCapabilities() async {
    double totalRamGb = 0;
    String? abi;
    String? gpu;

    final info = await _aicoreService.getHardwareInfo();
    if (info != null) {
      final int totalRamBytes = info['totalRam'] ?? 0;
      totalRamGb = totalRamBytes / (1024 * 1024 * 1024);
      abi = info['supportedAbis'];
    }

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      // Heuristic for GPU: if it's a high-end SOC, we assume decent GPU
      // In a real app, we might use a specialized plugin for GPU detection
      gpu = "${androidInfo.hardware} / ${androidInfo.board}";
    } else if (totalRamGb == 0) {
      // Fallback for non-android if we couldn't get hardware info
      totalRamGb = 4.0;
    }

    final profile = _calculateProfile(totalRamGb);
    final recommendation = _calculateRecommendation(profile, abi);

    return DeviceHardwareInfo(
      totalRamGb: totalRamGb,
      profile: profile,
      recommendation: recommendation,
      abi: abi ?? 'unknown',
      gpu: gpu ?? 'unknown',
    );
  }

  DeviceProfile _calculateProfile(double ramGb) {
    if (ramGb < 4.0) return DeviceProfile.light;
    if (ramGb <= 6.0) return DeviceProfile.medium;
    return DeviceProfile.highEnd;
  }

  ModelRecommendation _calculateRecommendation(DeviceProfile profile, String? abi) {
    // Recommendation based on profile and ABI (64-bit preferred for larger models)
    final is64Bit = abi?.contains('arm64-v8a') ?? false;

    switch (profile) {
      case DeviceProfile.light:
        return ModelRecommendation.model2B;
      case DeviceProfile.medium:
        return is64Bit ? ModelRecommendation.model7B : ModelRecommendation.model2B;
      case DeviceProfile.highEnd:
        return is64Bit ? ModelRecommendation.model9B : ModelRecommendation.model7B;
    }
  }
}

class DeviceHardwareInfo {
  final double totalRamGb;
  final DeviceProfile profile;
  final ModelRecommendation recommendation;
  final String abi;
  final String gpu;

  DeviceHardwareInfo({
    required this.totalRamGb,
    required this.profile,
    required this.recommendation,
    required this.abi,
    required this.gpu,
  });

  String get profileName {
    switch (profile) {
      case DeviceProfile.light: return "Light";
      case DeviceProfile.medium: return "Medium";
      case DeviceProfile.highEnd: return "High-end";
    }
  }

  String get recommendationName {
    switch (recommendation) {
      case ModelRecommendation.model2B: return "2B";
      case ModelRecommendation.model7B: return "7B";
      case ModelRecommendation.model9B: return "9B";
      case ModelRecommendation.cloudOnly: return "Cloud Only";
    }
  }
}
