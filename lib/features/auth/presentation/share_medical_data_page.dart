import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/cyber_theme.dart';
import '../infrastructure/services/ble_medical_sharing_service.dart';
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../allergies/domain/repositories/allergy_repository.dart';
import '../../medications/domain/repositories/medication_repository.dart';
import '../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../appointments/domain/repositories/appointment_repository.dart';

/// Página para compartir datos médicos via Bluetooth
class ShareMedicalDataPage extends StatefulWidget {
  const ShareMedicalDataPage({super.key});

  @override
  State<ShareMedicalDataPage> createState() => _ShareMedicalDataPageState();
}

class _ShareMedicalDataPageState extends State<ShareMedicalDataPage> {
  late BleMedicalSharingService _bleService;

  // Datos seleccionados para compartir
  bool _includeProfile = true;
  bool _includeAllergies = true;
  bool _includeMedications = true;
  bool _includeVitals = true;
  bool _includeAppointments = false;

  // Estado de la UI
  bool _isBluetoothAvailable = false;
  List<DiscoveredDevice> _discoveredDevices = [];
  DiscoveredDevice? _selectedDevice;
  double _transferProgress = 0;
  String? _statusMessage;
  bool _isTransferring = false;

  @override
  void initState() {
    super.initState();
    _bleService = GetIt.I<BleMedicalSharingService>();
    _checkBluetooth();
    _setupListeners();
  }

  void _setupListeners() {
    _bleService.stateStream.listen((state) {
      setState(() {
        _isTransferring = state == BleConnectionState.transferring;
        switch (state) {
          case BleConnectionState.scanning:
            _statusMessage = 'Buscando dispositivos...';
            break;
          case BleConnectionState.connecting:
            _statusMessage = 'Conectando...';
            break;
          case BleConnectionState.connected:
            _statusMessage = 'Conectado';
            break;
          case BleConnectionState.transferring:
            _statusMessage = 'Transfiriendo datos...';
            break;
          case BleConnectionState.error:
            _statusMessage = 'Error de conexión';
            break;
          case BleConnectionState.disconnected:
            _statusMessage = null;
            _selectedDevice = null;
            break;
        }
      });
    });

    _bleService.devicesStream.listen((devices) {
      setState(() {
        _discoveredDevices = devices;
      });
    });

    _bleService.progressStream.listen((progress) {
      setState(() {
        _transferProgress = progress;
      });
    });
  }

  Future<void> _checkBluetooth() async {
    final available = await _bleService.isBluetoothAvailable();
    setState(() {
      _isBluetoothAvailable = available;
    });
  }

  Future<void> _enableBluetooth() async {
    final success = await _bleService.requestEnableBluetooth();
    if (success) {
      await _checkBluetooth();
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _discoveredDevices = [];
    });
    await _bleService.startScan();
  }

  Future<void> _stopScan() async {
    await _bleService.stopScan();
  }

  Future<void> _connectToDevice(DiscoveredDevice device) async {
    final success = await _bleService.connectToDevice(device);
    if (success) {
      setState(() {
        _selectedDevice = device;
      });
    } else {
      _showError('No se pudo conectar al dispositivo');
    }
  }

  Future<void> _shareData() async {
    if (_selectedDevice == null) {
      _showError('Selecciona un dispositivo primero');
      return;
    }

    // Recopilar datos seleccionados
    final data = await _collectSelectedData();
    if (data == null) {
      _showError('Error recopilando datos');
      return;
    }

    // Obtener perfil del usuario
    final profileRepo = GetIt.I<UserProfileRepository>();
    final profile = await profileRepo.getUserProfile();

    final package = MedicalDataPackage(
      patientId: profile?.uniqueId ?? 'UNKNOWN',
      patientName: profile?.name ?? 'Paciente',
      timestamp: DateTime.now(),
      data: data,
    );

    final result = await _bleService.sendMedicalData(package);

    if (result.success) {
      _showSuccess(
        'Datos enviados correctamente\n'
        '${result.bytesTransferred} bytes transferidos',
      );
    } else {
      _showError(result.errorMessage ?? 'Error desconocido');
    }
  }

  Future<Map<String, dynamic>?> _collectSelectedData() async {
    try {
      final data = <String, dynamic>{};

      if (_includeProfile) {
        final profileRepo = GetIt.I<UserProfileRepository>();
        final profile = await profileRepo.getUserProfile();
        if (profile != null) {
          data['profile'] = {
            'name': profile.name,
            'age': profile.age,
            'bloodType': profile.bloodType,
            'weight': profile.weight,
            'height': profile.height,
          };
        }
      }

      if (_includeAllergies) {
        final allergyRepo = GetIt.I<AllergyRepository>();
        final allergies = await allergyRepo.getAllergies();
        data['allergies'] = allergies
            .map(
              (a) => {
                'name': a.name,
                'severity': a.severity.name,
                'reaction': a.reaction,
                'isCritical': a.isCritical,
              },
            )
            .toList();
      }

      if (_includeMedications) {
        final medRepo = GetIt.I<MedicationRepository>();
        final medications = await medRepo.getAllMedications();
        data['medications'] = medications
            .map(
              (m) => {
                'name': m.name,
                'dosage': m.dosage,
                'frequency': m.frequency.name,
                'status': m.status.name,
              },
            )
            .toList();
      }

      if (_includeVitals) {
        final vitalsRepo = GetIt.I<VitalSignRepository>();
        final vitalsMap = await vitalsRepo.getLatestVitals();
        data['vitals'] = vitalsMap.entries
            .where((e) => e.value != null)
            .map(
              (e) => {
                'type': e.key.name,
                'value': e.value!.value,
                'unit': e.value!.unit,
                'timestamp': e.value!.recordedAt?.toIso8601String(),
              },
            )
            .toList();
      }

      if (_includeAppointments) {
        final apptRepo = GetIt.I<AppointmentRepository>();
        final appointments = await apptRepo.getAllAppointments();
        data['appointments'] = appointments
            .map(
              (a) => {
                'doctorName': a.doctorName,
                'specialty': a.specialty,
                'dateTime': a.dateTime?.toIso8601String(),
                'status': a.status.name,
                'notes': a.notes,
              },
            )
            .toList();
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: CyberTheme.primary),
    );
  }

  @override
  void dispose() {
    _bleService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Compartir Datos Médicos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isBluetoothAvailable
            ? _buildMainContent()
            : _buildBluetoothDisabledContent(),
      ),
    );
  }

  Widget _buildBluetoothDisabledContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Bluetooth Desactivado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Activa el Bluetooth para compartir\ntus datos médicos de forma segura',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _enableBluetooth,
              icon: const Icon(Icons.bluetooth),
              label: const Text('ACTIVAR BLUETOOTH'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberTheme.secondary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de seguridad
          _buildSecurityInfo(),
          const SizedBox(height: 24),

          // Selección de datos a compartir
          _buildDataSelection(),
          const SizedBox(height: 24),

          // Dispositivos encontrados
          _buildDevicesList(),
          const SizedBox(height: 24),

          // Progreso de transferencia
          if (_isTransferring) _buildTransferProgress(),

          // Botones de acción
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            CyberTheme.secondary.withOpacity(0.1),
            CyberTheme.primary.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: CyberTheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CyberTheme.secondary.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.shield,
              color: CyberTheme.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transferencia Segura',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus datos se encriptan con AES-256 antes de enviarse via Bluetooth',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos a Compartir',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDataToggle(
          'Perfil del Paciente',
          'Nombre, edad, tipo de sangre',
          Icons.person,
          _includeProfile,
          (v) => setState(() => _includeProfile = v),
        ),
        _buildDataToggle(
          'Alergias',
          'Lista de alergias y reacciones',
          Icons.warning_amber,
          _includeAllergies,
          (v) => setState(() => _includeAllergies = v),
          critical: true,
        ),
        _buildDataToggle(
          'Medicamentos',
          'Medicación actual y dosis',
          Icons.medication,
          _includeMedications,
          (v) => setState(() => _includeMedications = v),
        ),
        _buildDataToggle(
          'Signos Vitales',
          'Historial de mediciones',
          Icons.favorite,
          _includeVitals,
          (v) => setState(() => _includeVitals = v),
        ),
        _buildDataToggle(
          'Citas Médicas',
          'Historial de consultas',
          Icons.calendar_today,
          _includeAppointments,
          (v) => setState(() => _includeAppointments = v),
        ),
      ],
    );
  }

  Widget _buildDataToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    bool critical = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: critical && value
            ? Border.all(color: Colors.orange.withOpacity(0.5))
            : null,
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(
              icon,
              color: critical ? Colors.orange : CyberTheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white)),
            if (critical) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CRÍTICO',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
        activeColor: CyberTheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildDevicesList() {
    final state = _bleService.currentState;
    final isScanning = state == BleConnectionState.scanning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dispositivos Cercanos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: isScanning ? _stopScan : _startScan,
              icon: Icon(isScanning ? Icons.stop : Icons.search, size: 18),
              label: Text(isScanning ? 'Detener' : 'Buscar'),
              style: TextButton.styleFrom(
                foregroundColor: CyberTheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_statusMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _statusMessage!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.05),
          ),
          child: _discoveredDevices.isEmpty
              ? _buildEmptyDevicesList(isScanning)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _discoveredDevices.length,
                  itemBuilder: (context, index) {
                    final device = _discoveredDevices[index];
                    final isSelected = _selectedDevice?.id == device.id;
                    return _buildDeviceTile(device, isSelected);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyDevicesList(bool isScanning) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isScanning)
              const CircularProgressIndicator(
                color: CyberTheme.secondary,
                strokeWidth: 2,
              )
            else
              Icon(
                Icons.bluetooth_searching,
                size: 40,
                color: Colors.white.withOpacity(0.3),
              ),
            const SizedBox(height: 12),
            Text(
              isScanning
                  ? 'Buscando dispositivos...'
                  : 'Presiona "Buscar" para encontrar\ndispositivos cercanos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(DiscoveredDevice device, bool isSelected) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? CyberTheme.primary.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          Icons.smartphone,
          color: isSelected ? CyberTheme.primary : Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        device.name,
        style: TextStyle(
          color: isSelected ? CyberTheme.primary : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        'Señal: ${_getSignalStrength(device.rssi)}',
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: CyberTheme.primary)
          : null,
      onTap: () => _connectToDevice(device),
    );
  }

  String _getSignalStrength(int rssi) {
    if (rssi >= -50) return 'Excelente';
    if (rssi >= -60) return 'Buena';
    if (rssi >= -70) return 'Moderada';
    return 'Débil';
  }

  Widget _buildTransferProgress() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: CyberTheme.primary.withOpacity(0.1),
        border: Border.all(color: CyberTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CyberTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Transfiriendo datos...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(_transferProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: CyberTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _transferProgress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(CyberTheme.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasDataSelected =
        _includeProfile ||
        _includeAllergies ||
        _includeMedications ||
        _includeVitals ||
        _includeAppointments;

    final canShare =
        _selectedDevice != null && hasDataSelected && !_isTransferring;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: canShare ? _shareData : null,
        icon: const Icon(Icons.share),
        label: const Text('COMPARTIR DATOS'),
        style: ElevatedButton.styleFrom(
          backgroundColor: CyberTheme.primary,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white.withOpacity(0.1),
          disabledForegroundColor: Colors.white.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
