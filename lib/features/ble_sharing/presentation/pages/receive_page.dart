import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/ble_sharing_service.dart';
import '../../application/ble_sharing_cubit.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BleSharingCubit()..initialize(),
      child: const _ReceivePageContent(),
    );
  }
}

class _ReceivePageContent extends StatefulWidget {
  const _ReceivePageContent();

  @override
  State<_ReceivePageContent> createState() => _ReceivePageContentState();
}

class _ReceivePageContentState extends State<_ReceivePageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BleSharingCubit>().startListening(MedicalTransferMethod.nfc);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Medical Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: BlocConsumer<BleSharingCubit, BleSharingState>(
        listener: (context, state) {
          if (state is BleSharingReceiving && state.package != null) {
            _showPreviewDialog(context, state.package!);
          } else if (state is BleSharingComplete) {
            _showSuccessDialog(context, state.result);
          } else if (state is BleSharingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildWaitingUI(state);
        },
      ),
    );
  }

  Widget _buildWaitingUI(BleSharingState state) {
    String message = 'Waiting for data...';
    IconData icon = Icons.wifi;
    Color color = Colors.blue;

    if (state is BleSharingScanning) {
      switch (state.method) {
        case MedicalTransferMethod.nfc:
          message = 'Tap devices to receive...';
          icon = Icons.nfc;
          break;
        case MedicalTransferMethod.ble:
          message = 'Searching Bluetooth devices...';
          icon = Icons.bluetooth;
          break;
        case MedicalTransferMethod.wifi:
          message = 'Waiting for WiFi connection...';
          icon = Icons.wifi;
          break;
      }
    } else if (state is BleSharingConnected) {
      message = 'Connection established';
      color = Colors.orange;
    } else if (state is BleSharingTransferring) {
      message = state.message;
      color = Colors.blue;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80, color: color),
          ),
          const SizedBox(height: 32),
          Text(
            message,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Data will be received encrypted\nand stored in your health wallet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 48),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, MedicalSharePackage package) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Data Received'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${package.senderNodeId}'),
            Text('Size: ${package.payload.cipherText.length} bytes'),
            Text(
              'Expires: ${package.timeRemaining.inMinutes}m ${package.timeRemaining.inSeconds % 60}s',
            ),
            const Divider(),
            const Text(
              'Categories:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...package.metadata.includedCategories.map(
              (c) => Text('• ${c.displayName}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BleSharingCubit>().rejectIncomingPackage();
            },
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BleSharingCubit>().acceptIncomingPackage();
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, SharingResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Import Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${result.bytesTransferred} bytes imported'),
            Text('Time: ${result.transferTime.inSeconds}s'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
