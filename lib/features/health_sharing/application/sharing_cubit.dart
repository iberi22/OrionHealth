import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../domain/entities/shared_health_package.dart';
import '../infrastructure/ble_sharing_service.dart';
import '../../auth/infrastructure/services/encryption_service.dart';

abstract class SharingState extends Equatable {
  const SharingState();
  @override
  List<Object?> get props => [];
}

class SharingInitial extends SharingState {}

class SharingScanning extends SharingState {
  final List<ScanResult> devices;
  const SharingScanning(this.devices);
  @override
  List<Object?> get props => [devices];
}

class SharingConnecting extends SharingState {
  final String deviceName;
  const SharingConnecting(this.deviceName);
  @override
  List<Object?> get props => [deviceName];
}

class SharingTransferring extends SharingState {
  final double progress;
  const SharingTransferring(this.progress);
  @override
  List<Object?> get props => [progress];
}

class SharingSuccess extends SharingState {
  final String message;
  const SharingSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class SharingFailure extends SharingState {
  final String error;
  const SharingFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class SharingReceived extends SharingState {
  final SharedHealthPackage package;
  const SharingReceived(this.package);
  @override
  List<Object?> get props => [package];
}

@injectable
class SharingCubit extends Cubit<SharingState> {
  final BleSharingService _bleService;
  final EncryptionService _encryptionService;

  SharingCubit(this._bleService, this._encryptionService) : super(SharingInitial());

  void startScanning() {
    emit(const SharingScanning([]));
    _bleService.scanForDevices().listen((results) {
      emit(SharingScanning(results));
    }).onError((e) {
      emit(SharingFailure(e.toString()));
    });
  }

  Future<void> shareData(BluetoothDevice device, SharedHealthPackage package) async {
    try {
      emit(SharingConnecting(device.platformName.isEmpty ? device.remoteId.toString() : device.platformName));

      // 1. Generate session key
      final sessionKey = await _encryptionService.generateShareSessionKey();

      // 2. Encrypt data
      final jsonData = jsonEncode(package.toJson());
      final encryptedData = await _encryptionService.encryptForSharing(jsonData, sessionKey);

      // 3. Send via BLE
      emit(const SharingTransferring(0.5));
      await _bleService.sendData(device, encryptedData);

      emit(const SharingSuccess("Datos enviados exitosamente"));
    } catch (e) {
      emit(SharingFailure(e.toString()));
    }
  }

  void startListening() {
    // This would be the receiving side
    _bleService.receiveData().listen((encryptedData) async {
      try {
        // In a real scenario, the session key would be received via QR or similar
        // For this implementation, we assume we have it or use a known one for demo
        // For now, let's assume it's unencrypted or we have the key
        // String decryptedData = await _encryptionService.decryptSharedData(encryptedData, sessionKey);

        final decoded = jsonDecode(encryptedData);
        final package = SharedHealthPackage.fromJson(decoded);
        emit(SharingReceived(package));
      } catch (e) {
        emit(SharingFailure("Error al recibir datos: $e"));
      }
    });
  }

  void reset() {
    emit(SharingInitial());
  }
}
