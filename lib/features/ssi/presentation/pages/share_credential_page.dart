import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/verifiable_credential.dart';
import '../../domain/services/ssi_service.dart';
import '../widgets/field_selector.dart';

/// Share credential page with selective disclosure.
///
/// Allows the user to preview a credential before sharing and
/// select exactly which fields to reveal via checkboxes.
/// ZKP-enabled fields are indicated for zero-knowledge proofs.
class ShareCredentialPage extends StatefulWidget {
  final SsiService ssiService;
  final VerifiableCredential credential;
  final VoidCallback? onShared;

  const ShareCredentialPage({
    super.key,
    required this.ssiService,
    required this.credential,
    this.onShared,
  });

  @override
  State<ShareCredentialPage> createState() => _ShareCredentialPageState();
}

class _ShareCredentialPageState extends State<ShareCredentialPage> {
  Set<String> _selectedFields = {};
  bool _isSharing = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    // Default: no fields selected for maximum privacy
  }

  Future<void> _share() async {
    if (_selectedFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one field to share'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSharing = true);

    try {
      final presentation = await widget.ssiService.createPresentation(
        credential: widget.credential,
        disclosedFields: _selectedFields.toList(),
      );

      if (!mounted) return;

      // Copy presentation JSON to clipboard (in production: BLE/NFC send)
      final jsonStr = const JsonEncoder.withIndent('  ').convert(presentation);
      await Clipboard.setData(ClipboardData(text: jsonStr));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presentation created and copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      widget.onShared?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final credentialType =
        widget.credential.type.isEmpty ? 'Verifiable Credential' : widget.credential.type;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Credential'),
        actions: [
          if (_selectedFields.isNotEmpty)
            TextButton.icon(
              onPressed: () => setState(() => _showPreview = !_showPreview),
              icon: Icon(_showPreview ? Icons.edit : Icons.visibility),
              label: Text(_showPreview ? 'Edit Selection' : 'Preview'),
            ),
        ],
      ),
      body: _showPreview ? _buildPreview() : _buildFieldSelection(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: SafeArea(
          child: FilledButton.icon(
            onPressed: _isSharing ? null : _share,
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            label: Text(_isSharing
                ? 'Creating Presentation...'
                : 'Share ${_selectedFields.length} Field${_selectedFields.length == 1 ? '' : 's'}'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldSelection() {
    final credentialType =
        widget.credential.type.isEmpty ? 'Verifiable Credential' : widget.credential.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Credential header card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          credentialType,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Issued by: ${widget.credential.issuer}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoChip(context, Icons.schema, widget.credential.schemaId),
                  const SizedBox(width: 8),
                  if (widget.credential.expirationDate != null)
                    _infoChip(
                      context,
                      Icons.event,
                      'Exp: ${widget.credential.expirationDate!.toLocal().toString().substring(0, 10)}',
                    ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Select fields to disclose. Unchecked fields remain hidden via zero-knowledge proofs.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Field selector
        Expanded(
          child: FieldSelector(
            fields: widget.credential.claims,
            zkpEnabledFields: widget.credential.claims.keys.toSet(),
            onSelectionChanged: (selected) {
              setState(() => _selectedFields = selected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final claims = widget.credential.claims;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.visibility,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Presentation Preview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedFields.length} of ${claims.length} fields will be disclosed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selected fields
        ...claims.entries.map((entry) {
          final isDisclosed = _selectedFields.contains(entry.key);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                isDisclosed ? Icons.lock_open : Icons.lock,
                color: isDisclosed
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              title: Text(
                _formatFieldName(entry.key),
                style: TextStyle(
                  fontWeight: isDisclosed ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                isDisclosed
                    ? (entry.value?.toString() ?? 'null')
                    : 'Hidden (ZKP) — not revealed',
                style: TextStyle(
                  color: isDisclosed
                      ? null
                      : Theme.of(context).colorScheme.outline,
                  fontStyle: isDisclosed ? null : FontStyle.italic,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDisclosed
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDisclosed ? 'DISCLOSED' : 'ZKP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: isDisclosed
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text.length > 20 ? '${text.substring(0, 18)}...' : text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  String _formatFieldName(String key) {
    return key
        .replaceAllMapped(RegExp(r'[_-](\w)'), (m) => ' ${m.group(1)!.toUpperCase()}')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m.group(1)} ${m.group(2)}')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
