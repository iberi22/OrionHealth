import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';

/// Device capability tiers
enum DeviceCapabilityTier { low, medium, high }

/// Device capability information
class DeviceCapability {
  final DeviceCapabilityTier tier;
  final int totalMemoryMb;
  final int availableMemoryMb;
  final int processorCount;
  final bool supportsGeminiCloud;
  final String recommendedModel;

  /// Device model name (e.g., 'Pixel 8', 'iPhone 15 Pro')
  final String? deviceModel;

  /// Whether the device has GPU acceleration
  final bool hasGpu;

  /// Operating system (e.g., 'android', 'ios', 'windows')
  final String os;

  const DeviceCapability({
    required this.tier,
    required this.totalMemoryMb,
    required this.availableMemoryMb,
    required this.processorCount,
    required this.supportsGeminiCloud,
    required this.recommendedModel,
    this.deviceModel,
    this.hasGpu = false,
    this.os = 'unknown',
  });

  String get tierLabel {
    switch (tier) {
      case DeviceCapabilityTier.low:
        return 'Baja';
      case DeviceCapabilityTier.medium:
        return 'Media';
      case DeviceCapabilityTier.high:
        return 'Alta';
    }
  }

  String get tierEmoji {
    switch (tier) {
      case DeviceCapabilityTier.low:
        return '📱';
      case DeviceCapabilityTier.medium:
        return '💻';
      case DeviceCapabilityTier.high:
        return '🚀';
    }
  }
}

/// Local model definition with device requirements
class LocalModelDefinition {
  final String id;
  final String name;
  final String size;
  final String minRam;
  final bool requiresGpu;

  const LocalModelDefinition({
    required this.id,
    required this.name,
    required this.size,
    required this.minRam,
    this.requiresGpu = false,
  });

  /// Parse minRam string to MB for comparison
  int get minRamMb {
    final cleaned = minRam.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(cleaned) ?? 0;
    if (minRam.contains('GB')) return value * 1024;
    return value;
  }
}

/// Available local models ordered by size (smallest first)
const List<LocalModelDefinition> availableLocalModelDefs = [
  LocalModelDefinition(id: 'smolLM-135m', name: 'SmolLM 135M', size: '135MB', minRam: '1GB'),
  LocalModelDefinition(id: 'gemma-3-270m', name: 'Gemma 3 270M', size: '270MB', minRam: '2GB'),
  LocalModelDefinition(id: 'qwen3-0.6b', name: 'Qwen3 0.6B', size: '600MB', minRam: '3GB'),
  LocalModelDefinition(id: 'deepseek-r1', name: 'DeepSeek R1', size: '1.7GB', minRam: '4GB'),
  LocalModelDefinition(id: 'gemma-4-e2b', name: 'Gemma 4 E2B', size: '2.4GB', minRam: '6GB', requiresGpu: true),
  LocalModelDefinition(id: 'phi-4-mini', name: 'Phi-4 Mini', size: '3.9GB', minRam: '6GB'),
];

/// Service to determine device capability for LLM operations.
///
/// Uses real device info via device_info_plus to estimate:
/// - Memory (RAM)
/// - Processor count
/// - GPU capability (based on device model/year)
/// - Recommended local model
///
/// Falls back to hardcoded defaults if device info is unavailable.
@lazySingleton
class DeviceCapabilityService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Detect device capability and return recommendation
  Future<DeviceCapability> detectCapability() async {
    final deviceInfo = await _getDeviceInfo();
    final memoryMb = _getTotalMemoryMb();
    final processorCount = _getProcessorCount();
    final gpuAvailable = _estimateGpuCapability(deviceInfo);
    final os = _getOs();
    final tier = _calculateTier(memoryMb, processorCount, gpuAvailable);

    return DeviceCapability(
      tier: tier,
      totalMemoryMb: memoryMb,
      availableMemoryMb: _calculateAvailableMemoryMb(memoryMb),
      processorCount: processorCount,
      supportsGeminiCloud: true,
      recommendedModel: _getRecommendedModel(tier),
      deviceModel: deviceInfo,
      hasGpu: gpuAvailable,
      os: os,
    );
  }

  int _calculateAvailableMemoryMb(int totalMemoryMb) {
    try {
      return (totalMemoryMb * 0.4).round(); // Assume 40% available
    } catch (e) {
      return 2048;
    }
  }

  /// Get the best local model for the current device.
  ///
  /// Returns the largest model the device can run, or the smallest
  /// if device is very constrained. Returns null if no model can run.
  String? getRecommendedLocalModel() {
    final memoryMb = _getTotalMemoryMb();
    final gpuAvailable = _estimateGpuCapability(null);

    // Filter models by requirements, pick the largest feasible one
    LocalModelDefinition? best;

    for (final model in availableLocalModelDefs) {
      if (model.requiresGpu && !gpuAvailable) continue;
      if (memoryMb >= model.minRamMb) {
        best = model; // Models are ordered by size, so last feasible is best
      }
    }

    return best?.id;
  }

  /// Check if the device can run a specific model.
  bool canRunModel(String modelId) {
    final memoryMb = _getTotalMemoryMb();
    final gpuAvailable = _estimateGpuCapability(null);

    final def = availableLocalModelDefs.where((m) => m.id == modelId).firstOrNull;
    if (def == null) return false;
    if (def.requiresGpu && !gpuAvailable) return false;
    return memoryMb >= def.minRamMb;
  }

  /// Get device model string from device_info_plus
  Future<String?> _getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.model} (${androidInfo.brand})';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return '${iosInfo.model} (${iosInfo.name})';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return 'Windows ${windowsInfo.productName}';
      }
    } catch (_) {}
    return null;
  }

  /// Get a summary of device info for display/logging.
  Future<String?> _getDeviceInfo() async {
    return _getDeviceModel();
  }

  /// Estimate total RAM in MB.
  int _getTotalMemoryMb() {
    try {
      if (Platform.isAndroid) {
        // Android can be detected from /proc/meminfo
        final memInfo = File('/proc/meminfo');
        if (memInfo.existsSync()) {
          final lines = memInfo.readAsStringSync();
          final match = RegExp(r'MemTotal:\s+(\d+)').firstMatch(lines);
          if (match != null) {
            final kb = int.tryParse(match.group(1)!) ?? 0;
            return kb ~/ 1024; // Convert KB to MB
          }
        }
        // Fallback: assume mid-range Android
        return 4096;
      } else if (Platform.isIOS) {
        // iOS typically has 4-8GB depending on device
        return 6144;
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return 8192;
      }
      return 4096;
    } catch (e) {
      return 4096;
    }
  }


  int _getProcessorCount() {
    try {
      return Platform.numberOfProcessors;
    } catch (e) {
      return 4;
    }
  }

  String _getOs() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// Estimate GPU capability based on device model/year.
  ///
  /// Returns true if the device likely has GPU acceleration for LLM inference.
  /// This is a heuristic based on device model strings and known GPU capabilities.
  bool _estimateGpuCapability(String? deviceInfo) {
    try {
      // Desktop always has GPU
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return true;
      }

      // Mobile GPU detection based on device model/SoC
      if (Platform.isAndroid) {
        // Modern flagship Android devices (2023+) likely have GPU NPU support
        return _getTotalMemoryMb() >= 8192;
      }

      if (Platform.isIOS) {
        // iOS devices with A13+ (iPhone 11+) have Neural Engine
        return _getTotalMemoryMb() >= 4096;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  DeviceCapabilityTier _calculateTier(int memoryMb, int processorCount, bool gpuAvailable) {
    if ((memoryMb >= 8192 && processorCount >= 4) || gpuAvailable) {
      return DeviceCapabilityTier.high;
    } else if (memoryMb >= 4096 && processorCount >= 2) {
      return DeviceCapabilityTier.medium;
    } else {
      return DeviceCapabilityTier.low;
    }
  }

  String _getRecommendedModel(DeviceCapabilityTier tier) {
    final recommendedLocal = getRecommendedLocalModel();
    if (recommendedLocal != null) {
      return recommendedLocal;
    }

    // Fallback based on tier if no local model found
    switch (tier) {
      case DeviceCapabilityTier.high:
        return 'phi-4-mini';
      case DeviceCapabilityTier.medium:
        return 'deepseek-r1';
      case DeviceCapabilityTier.low:
        return 'smolLM-135m';
    }
  }

  /// Get capability badge color based on tier
  static String getBadgeColor(DeviceCapabilityTier tier) {
    switch (tier) {
      case DeviceCapabilityTier.low:
        return '⚠️ Baja capacidad - Se recomienda modelo lite';
      case DeviceCapabilityTier.medium:
        return '✅ Capacidad media - Modelo estándar recomendado';
      case DeviceCapabilityTier.high:
        return '🚀 Alta capacidad - Puedes usar modelo completo';
    }
  }
}
