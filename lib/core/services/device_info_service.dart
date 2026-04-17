import 'package:flutter/services.dart';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SystemInfo {
  final double totalRamGb;
  final String model;
  final String manufacturer;
  final String gpuRenderer;

  SystemInfo({
    required this.totalRamGb,
    required this.model,
    required this.manufacturer,
    required this.gpuRenderer,
  });
}

@lazySingleton
class DeviceInfoService {
  static const _channel = MethodChannel('com.orionhealth/aicore');
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<SystemInfo> getSystemInfo() async {
    if (Platform.isAndroid) {
      try {
        final Map<dynamic, dynamic>? info =
            await _channel.invokeMethod<Map<dynamic, dynamic>>('getSystemInfo');

        if (info != null) {
          return SystemInfo(
            totalRamGb: info['totalRamGb'] ?? 0.0,
            model: info['model'] ?? 'Unknown',
            manufacturer: info['manufacturer'] ?? 'Unknown',
            gpuRenderer: info['glEsVersion'] ?? 'Unknown',
          );
        }
      } catch (e) {
        print('Error getting native system info: $e');
      }
    }

    // Fallback using device_info_plus and reasonable defaults
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return SystemInfo(
        totalRamGb: 0, // Cannot get RAM easily via device_info_plus
        model: androidInfo.model,
        manufacturer: androidInfo.manufacturer,
        gpuRenderer: 'Unknown',
      );
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return SystemInfo(
        totalRamGb: 0,
        model: iosInfo.model,
        manufacturer: 'Apple',
        gpuRenderer: 'Unknown',
      );
    }

    return SystemInfo(
      totalRamGb: 0,
      model: Platform.operatingSystem,
      manufacturer: 'Unknown',
      gpuRenderer: 'Unknown',
    );
  }

  String getModelRecommendation(double ramGb) {
    if (ramGb <= 0) return 'Se recomienda un modelo ligero (Gemma 2B) para dispositivos con RAM limitada.';
    if (ramGb < 4) {
      return 'Gemma 2B recomendado (Dispositivo con RAM limitada: ${ramGb.toStringAsFixed(1)}GB)';
    } else if (ramGb < 8) {
      return 'Gemma 2B o 7B recomendado (RAM media: ${ramGb.toStringAsFixed(1)}GB)';
    } else {
      return 'Gemma 7B o superior recomendado (Excelente capacidad: ${ramGb.toStringAsFixed(1)}GB)';
    }
  }
}
