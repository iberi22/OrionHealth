import 'package:flutter/material.dart';
import '../../../ble_sharing/domain/ble_sharing_service.dart';

class VitalsMonitorPage extends StatefulWidget {
  const VitalsMonitorPage({super.key});

  @override
  State<VitalsMonitorPage> createState() => _VitalsMonitorPageState();
}

class _VitalsMonitorPageState extends State<VitalsMonitorPage> {
  final BleSharingService _bleService = BleSharingService();
  List<BleDevice> _devices = [];
  bool _isScanning = false;
  String? _statusMessage;
  int? _heartRate;

  @override
  void initState() {
    super.initState();
    _bleService.initialize();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Searching for medical devices...';
    });

    final results = await _bleService.scanForDevices();
    
    setState(() {
      _devices = results;
      _isScanning = false;
      _statusMessage = results.isEmpty ? 'No devices found' : 'Select a device to connect';
    });
  }

  Future<void> _connectToDevice(BleDevice device) async {
    setState(() => _statusMessage = 'Connecting to ${device.name}...');
    final success = await _bleService.connect(device.id);
    
    if (success) {
      setState(() => _statusMessage = 'Connected to ${device.name}');
      _startDataStream(device.id);
    } else {
      setState(() => _statusMessage = 'Connection failed');
    }
  }

  void _startDataStream(String deviceId) {
    _bleService.startMedicalDataStream(deviceId);
    // In a real app, we would listen to a stream from the service
    // For now, we simulate the UI update
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _heartRate = 60 + (DateTime.now().second % 20); // Simulated real-time fluctuation
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Vitals Monitor', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: Column(
          children: [
            _buildLivePulseCard(),
            Expanded(
              child: _devices.isEmpty 
                ? _buildEmptyState() 
                : _buildDeviceList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? null : _startScan,
        label: Text(_isScanning ? 'Scanning...' : 'Search Devices'),
        icon: _isScanning 
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.bluetooth_searching),
        backgroundColor: const Color(0xFF38BDF8),
      ),
    );
  }

  Widget _buildLivePulseCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HEART RATE', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  SizedBox(height: 4),
                  Text('Real-time BLE Sync', style: TextStyle(color: Colors.white60, fontSize: 14)),
                ],
              ),
              Icon(Icons.favorite, color: Colors.redAccent.withOpacity(0.8), size: 32),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _heartRate?.toString() ?? '--',
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2),
              ),
              const SizedBox(width: 8),
              const Text('BPM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white30)),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _statusMessage ?? 'Device offline',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, italic: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text('Connect a clinical device\nto see live vitals', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF38BDF8).withOpacity(0.1),
              child: const Icon(Icons.bluetooth, color: Color(0xFF38BDF8)),
            ),
            title: Text(device.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(device.type, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            trailing: TextButton(
              onPressed: () => _connectToDevice(device),
              child: const Text('CONNECT'),
            ),
          ),
        );
      },
    );
  }
}

class Timer {
  static void periodic(Duration duration, void Function(Timer timer) callback) {
    // Stub for simulation
  }
  void cancel() {}
}
