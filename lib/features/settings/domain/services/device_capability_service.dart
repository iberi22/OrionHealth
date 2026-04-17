import 'dart:io';
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

  const DeviceCapability({
    required this.tier,
    required this.totalMemoryMb,
    required this.availableMemoryMb,
    required this.processorCount,
    required this.supportsGeminiCloud,
    required this.recommendedModel,
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

/// Service to determine device capability for LLM operations.
///
/// Uses device specs to recommend appropriate model (cloud vs local).
@lazySingleton
class DeviceCapabilityService {
  /// Detect device capability and return recommendation
  Future<DeviceCapability> detectCapability() async {
    // Get system info (placeholder for actual device detection)
    final memoryMb = _getTotalMemoryMb();
    final processorCount = _getProcessorCount();
    final tier = _calculateTier(memoryMb, processorCount);

    return DeviceCapability(
      tier: tier,
      totalMemoryMb: memoryMb,
      availableMemoryMb: _getAvailableMemoryMb(),
      processorCount: processorCount,
      supportsGeminiCloud: true, // All devices support cloud
      recommendedModel: _getRecommendedModel(tier),
    );
  }

  int _getTotalMemoryMb() {
    try {
      // On actual device, use platform channels or device_info_plus
      // For now, return a reasonable default based on platform
      if (Platform.isAndroid) {
        return 4096; // Default Android mid-range
      } else if (Platform.isIOS) {
        return 6144; // Default iOS device
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return 8192; // Desktop typically has more memory
      }
      return 4096;
    } catch (e) {
      return 4096;
    }
  }

  int _getAvailableMemoryMb() {
    try {
      // Placeholder - actual implementation would check real available memory
      final total = _getTotalMemoryMb();
      return (total * 0.4).round(); // Assume 40% available
    } catch (e) {
      return 2048;
    }
  }

  int _getProcessorCount() {
    try {
      return Platform.numberOfProcessors;
    } catch (e) {
      return 4;
    }
  }

  DeviceCapabilityTier _calculateTier(int memoryMb, int processorCount) {
    if (memoryMb >= 8192 && processorCount >= 4) {
      return DeviceCapabilityTier.high;
    } else if (memoryMb >= 4096 && processorCount >= 2) {
      return DeviceCapabilityTier.medium;
    } else {
      return DeviceCapabilityTier.low;
    }
  }

  String _getRecommendedModel(DeviceCapabilityTier tier) {
    switch (tier) {
      case DeviceCapabilityTier.high:
        return 'gemini-2.5-flash';
      case DeviceCapabilityTier.medium:
        return 'gemini-2.0-flash';
      case DeviceCapabilityTier.low:
        return 'gemini-2.0-flash-lite';
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
