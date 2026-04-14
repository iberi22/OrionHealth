import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/cyber_theme.dart';
import '../infrastructure/services/ble_medical_sharing_service.dart';

/// Página para recibir datos médicos via Bluetooth (modo médico)
class ReceiveMedicalDataPage extends StatefulWidget {
  const ReceiveMedicalDataPage({super.key});

  @override
  State<ReceiveMedicalDataPage> createState() => _ReceiveMedicalDataPageState();
}

class _ReceiveMedicalDataPageState extends State<ReceiveMedicalDataPage> {
  late BleMedicalSharingService _bleService;

  bool _isBluetoothAvailable = false;
  List<DiscoveredDevice> _discoveredDevices = [];
  DiscoveredDevice? _selectedDevice;
  double _transferProgress = 0;
  String? _statusMessage;
  bool _isTransferring = false;
  MedicalDataPackage? _receivedData;

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
        _statusMessage = switch (state) {
          BleConnectionState.scanning => 'Buscando pacientes...',
          BleConnectionState.connecting => 'Conectando...',
          BleConnectionState.connected => 'Conectado - Esperando datos',
          BleConnectionState.transferring => 'Recibiendo datos...',
          BleConnectionState.error => 'Error de conexión',
          BleConnectionState.disconnected => null,
        };
        if (state == BleConnectionState.disconnected) {
          _selectedDevice = null;
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
      _receivedData = null;
    });
    await _bleService.startScan();
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

  Future<void> _receiveData() async {
    if (_selectedDevice == null) {
      _showError('Selecciona un paciente primero');
      return;
    }

    final result = await _bleService.receiveMedicalData();

    if (result.success && result.data != null) {
      try {
        final jsonData = jsonDecode(result.data!);
        setState(() {
          _receivedData = MedicalDataPackage.fromJson(jsonData);
        });
        _showSuccess('Datos recibidos correctamente');
      } catch (e) {
        _showError('Error procesando datos recibidos');
      }
    } else {
      _showError(result.errorMessage ?? 'Error desconocido');
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
        title: const Text('Recibir Datos del Paciente'),
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
              'Activa el Bluetooth para recibir\ndatos médicos de pacientes',
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
          // Información del modo
          _buildModeInfo(),
          const SizedBox(height: 24),

          // Si hay datos recibidos, mostrarlos
          if (_receivedData != null) ...[
            _buildReceivedDataView(),
            const SizedBox(height: 24),
          ],

          // Lista de dispositivos
          if (_receivedData == null) ...[
            _buildDevicesList(),
            const SizedBox(height: 24),

            // Progreso
            if (_isTransferring) _buildTransferProgress(),

            // Botón de recibir
            _buildActionButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildModeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            CyberTheme.secondary.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modo Médico',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recibe datos médicos encriptados de tus pacientes de forma segura',
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
              'Pacientes Cercanos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: isScanning ? () => _bleService.stopScan() : _startScan,
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
                Icons.person_search,
                size: 40,
                color: Colors.white.withOpacity(0.3),
              ),
            const SizedBox(height: 12),
            Text(
              isScanning
                  ? 'Buscando pacientes...'
                  : 'Presiona "Buscar" para encontrar\npacientes cercanos',
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
          Icons.person,
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
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: CyberTheme.primary)
          : null,
      onTap: () => _connectToDevice(device),
    );
  }

  Widget _buildTransferProgress() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recibiendo datos...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(_transferProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.blue,
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
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final canReceive = _selectedDevice != null && !_isTransferring;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: canReceive ? _receiveData : null,
        icon: const Icon(Icons.download),
        label: const Text('RECIBIR DATOS'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withOpacity(0.1),
          disabledForegroundColor: Colors.white.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedDataView() {
    final data = _receivedData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del paciente
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                CyberTheme.primary.withOpacity(0.1),
                CyberTheme.secondary.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: CyberTheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CyberTheme.primary.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.person,
                  color: CyberTheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.patientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${data.patientId}',
                      style: TextStyle(
                        color: CyberTheme.secondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Recibido: ${_formatDateTime(data.timestamp)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _receivedData = null;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Datos recibidos
        if (data.data['profile'] != null)
          _buildDataSection(
            'Perfil',
            Icons.person,
            _formatProfile(data.data['profile']),
          ),
        if (data.data['allergies'] != null)
          _buildDataSection(
            'Alergias',
            Icons.warning_amber,
            _formatAllergies(data.data['allergies']),
            critical: true,
          ),
        if (data.data['medications'] != null)
          _buildDataSection(
            'Medicamentos',
            Icons.medication,
            _formatMedications(data.data['medications']),
          ),
        if (data.data['vitals'] != null)
          _buildDataSection(
            'Signos Vitales',
            Icons.favorite,
            _formatVitals(data.data['vitals']),
          ),
        if (data.data['appointments'] != null)
          _buildDataSection(
            'Citas',
            Icons.calendar_today,
            _formatAppointments(data.data['appointments']),
          ),

        const SizedBox(height: 16),

        // Botón para nueva recepción
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _receivedData = null;
              });
              _startScan();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('RECIBIR OTRO PACIENTE'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CyberTheme.secondary,
              side: const BorderSide(color: CyberTheme.secondary),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection(
    String title,
    IconData icon,
    String content, {
    bool critical = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: critical
            ? Border.all(color: Colors.orange.withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: critical ? Colors.orange : CyberTheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: critical ? Colors.orange : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (critical) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '⚠️ CRÍTICO',
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
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatProfile(Map<String, dynamic> profile) {
    final lines = <String>[];
    if (profile['name'] != null) lines.add('Nombre: ${profile['name']}');
    if (profile['age'] != null) lines.add('Edad: ${profile['age']} años');
    if (profile['bloodType'] != null)
      lines.add('Tipo de sangre: ${profile['bloodType']}');
    if (profile['weight'] != null) lines.add('Peso: ${profile['weight']} kg');
    if (profile['height'] != null) lines.add('Altura: ${profile['height']} cm');
    return lines.join('\n');
  }

  String _formatAllergies(List<dynamic> allergies) {
    if (allergies.isEmpty) return 'Sin alergias registradas';
    return allergies
        .map((a) {
          final severity = a['isCritical'] == true
              ? '⚠️ CRÍTICA'
              : a['severity'];
          return '• ${a['name']} ($severity)\n  Reacción: ${a['reaction']}';
        })
        .join('\n\n');
  }

  String _formatMedications(List<dynamic> medications) {
    if (medications.isEmpty) return 'Sin medicamentos registrados';
    return medications
        .map((m) {
          return '• ${m['name']}\n  Dosis: ${m['dosage']}\n  Frecuencia: ${m['frequency']}';
        })
        .join('\n\n');
  }

  String _formatVitals(List<dynamic> vitals) {
    if (vitals.isEmpty) return 'Sin signos vitales registrados';
    // Mostrar solo los últimos 5
    final recent = vitals.take(5);
    return recent
        .map((v) {
          return '• ${v['type']}: ${v['value']} ${v['unit']}';
        })
        .join('\n');
  }

  String _formatAppointments(List<dynamic> appointments) {
    if (appointments.isEmpty) return 'Sin citas registradas';
    return appointments
        .take(3)
        .map((a) {
          final dt = DateTime.parse(a['dateTime']);
          return '• ${a['doctorName']} (${a['specialty']})\n  ${_formatDateTime(dt)} - ${a['status']}';
        })
        .join('\n\n');
  }
}
