import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/ble_sharing_service.dart';
import 'ble_sharing_cubit.dart';

class SharePage extends StatelessWidget {
  const SharePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BleSharingCubit()..initialize(),
      child: const _SharePageContent(),
    );
  }
}

class _SharePageContent extends StatefulWidget {
  const _SharePageContent();

  @override
  State<_SharePageContent> createState() => _SharePageContentState();
}

class _SharePageContentState extends State<_SharePageContent> {
  final Set<MedicalDataCategory> _selectedCategories = {};
  MedicalTransferMethod _selectedMethod = MedicalTransferMethod.nfc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Data Share'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: BlocConsumer<BleSharingCubit, BleSharingState>(
        listener: (context, state) {
          if (state is BleSharingComplete) {
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
          if (state is BleSharingScanning ||
              state is BleSharingConnecting ||
              state is BleSharingConnected) {
            return _buildTransferringUI(state);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySelector(),
                const SizedBox(height: 24),
                _buildMethodSelector(),
                const SizedBox(height: 24),
                _buildShareButton(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select data to share',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MedicalDataCategory.values.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              '${_selectedCategories.length} categories selected',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transfer method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...MedicalTransferMethod.values.map((method) {
              return RadioListTile<MedicalTransferMethod>(
                title: Text(method.displayName),
                subtitle: Text(method.description),
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMethod = value);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, BleSharingState state) {
    final canShare = _selectedCategories.isNotEmpty && state is BleSharingReady;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canShare ? () => _startSharing(context) : null,
        icon: const Icon(Icons.share),
        label: Text(canShare ? 'Share' : 'Select at least one category'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
      ),
    );
  }

  Widget _buildTransferringUI(BleSharingState state) {
    String message = 'Transferring...';
    double progress = 0.5;

    if (state is BleSharingScanning) {
      message = 'Searching for devices...';
      progress = 0.2;
    } else if (state is BleSharingConnecting) {
      message = 'Connecting...';
      progress = 0.4;
    } else if (state is BleSharingConnected) {
      message = 'Connected';
      progress = 0.6;
    } else if (state is BleSharingTransferring) {
      message = state.message;
      progress = state.progress;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(message, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => context.read<BleSharingCubit>().cancelSharing(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _startSharing(BuildContext context) {
    final package = MedicalSharePackage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderNodeId: 'my-node-id',
      recipientNodeId: 'target-node-id',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 3)),
      payload: const EncryptedMedicalPayload(
        cipherText: '',
        iv: '',
        authTag: '',
      ),
      metadata: MedicalShareMetadata(
        packageType: 'selective',
        consentVerified: true,
        includedCategories: _selectedCategories,
        appVersion: '1.0.0',
      ),
      signature: '',
    );

    context.read<BleSharingCubit>().startSharing(
      method: _selectedMethod,
      package: package,
    );
  }

  void _showSuccessDialog(BuildContext context, SharingResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Shared successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${result.bytesTransferred} bytes transferred'),
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
