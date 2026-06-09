import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../health_sharing/application/sharing_cubit.dart';
import '../../../health_sharing/domain/entities/shared_health_package.dart';

class ShareMedicalDataPage extends StatelessWidget {
  const ShareMedicalDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SharingCubit()..initialize(),
      child: const _ShareMedicalDataContent(),
    );
  }
}

class _ShareMedicalDataContent extends StatefulWidget {
  const _ShareMedicalDataContent();

  @override
  State<_ShareMedicalDataContent> createState() => _ShareMedicalDataContentState();
}

class _ShareMedicalDataContentState extends State<_ShareMedicalDataContent> {
  final Set<DataCategory> _selectedCategories = {};
  TransferMethod _selectedMethod = TransferMethod.nfc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Medical Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: BlocConsumer<SharingCubit, SharingState>(
        listener: (context, state) {
          if (state is SharingComplete) {
            _showSuccessDialog(context, state.result);
          } else if (state is SharingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is SharingScanning ||
              state is SharingConnecting ||
              state is SharingConnected ||
              state is SharingTransferring) {
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
              children: DataCategory.values.map((category) {
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
            Column(
              children: TransferMethod.values.map((method) {
                return RadioListTile<TransferMethod>(
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
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, SharingState state) {
    final canShare = _selectedCategories.isNotEmpty && state is SharingReady;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canShare ? () => _startSharing(context) : null,
        icon: const Icon(Icons.share),
        label: Text(canShare ? 'Share' : 'Select at least one category'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildTransferringUI(SharingState state) {
    String message = 'Transferring...';
    double progress = 0.5;

    if (state is SharingScanning) {
      message = 'Searching for devices...';
      progress = 0.2;
    } else if (state is SharingConnecting) {
      message = 'Connecting...';
      progress = 0.4;
    } else if (state is SharingConnected) {
      message = 'Connected';
      progress = 0.6;
    } else if (state is SharingTransferring) {
      message = state.message;
      progress = state.progress;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => context.read<SharingCubit>().cancelSharing(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _startSharing(BuildContext context) {
    // Create package
    final package = SharedHealthPackage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderNodeId: 'my-node-id',
      recipientNodeId: 'target-node-id',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 3)),
      payload: const EncryptedPayload(
        encryptedData: '',
        iv: '',
        ephemeralPublicKey: '',
        authTag: '',
      ),
      metadata: PackageMetadata(
        packageType: 'selective',
        consentVerified: true,
        includedCategories: _selectedCategories,
        appVersion: '1.0.0',
      ),
      signature: '',
    );

    context.read<SharingCubit>().startSharing(
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
