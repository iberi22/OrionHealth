import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../data/email_repository.dart';
import '../../appointments/domain/repositories/appointment_repository.dart';
import '../../../../core/di/injection.dart';

class EmailConnectPage extends StatefulWidget {
  const EmailConnectPage({super.key});

  @override
  State<EmailConnectPage> createState() => _EmailConnectPageState();
}

class _EmailConnectPageState extends State<EmailConnectPage> {
  final EmailRepository _emailRepository = EmailRepository();
  final AppointmentRepository _appointmentRepository = getIt<AppointmentRepository>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  bool _isGmailConnected = false;
  bool _isOutlookConnected = false;
  bool _isSyncing = false;
  String? _lastCode;
  String? _pendingProvider;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'orionhealth' && uri.host == 'oauth2redirect') {
        final code = uri.queryParameters['code'];
        if (code != null) {
          setState(() {
            _lastCode = code;
            if (_pendingProvider == 'Gmail') _isGmailConnected = true;
            if (_pendingProvider == 'Outlook') _isOutlookConnected = true;
          });
          _handleSync();
        }
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleConnectGmail() async {
    _pendingProvider = 'Gmail';
    await _emailRepository.connectGmail();
  }

  Future<void> _handleConnectOutlook() async {
    _pendingProvider = 'Outlook';
    await _emailRepository.connectOutlook();
  }

  Future<void> _handleSync() async {
    if (_lastCode == null) return;

    setState(() => _isSyncing = true);
    try {
      final appointments = await _emailRepository.fetchParsedAppointments(
        _pendingProvider ?? "Gmail",
        _lastCode!,
      );

      for (var app in appointments) {
        await _appointmentRepository.saveAppointment(app);
        await _emailRepository.syncToNativeCalendar(app);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sincronización completada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al sincronizar: $e')),
        );
      }
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectar Correo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sincroniza tus citas médicas automáticamente leyendo tus correos.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            _EmailProviderCard(
              name: 'Gmail',
              icon: Icons.email,
              isConnected: _isGmailConnected,
              onConnect: _handleConnectGmail,
            ),
            const SizedBox(height: 16),
            _EmailProviderCard(
              name: 'Outlook',
              icon: Icons.mail_outline,
              isConnected: _isOutlookConnected,
              onConnect: _handleConnectOutlook,
            ),
            const Spacer(),
            if (_isGmailConnected || _isOutlookConnected)
              ElevatedButton.icon(
                onPressed: _isSyncing ? null : _handleSync,
                icon: _isSyncing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync),
                label: Text(_isSyncing ? 'SINCRONIZANDO...' : 'SINCRONIZAR AHORA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _EmailProviderCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isConnected;
  final VoidCallback onConnect;

  const _EmailProviderCard({
    required this.name,
    required this.icon,
    required this.isConnected,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: CyberTheme.secondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    isConnected ? 'Conectado' : 'No conectado',
                    style: TextStyle(color: isConnected ? Colors.green : Colors.grey),
                  ),
                ],
              ),
            ),
            if (!isConnected)
              TextButton(
                onPressed: onConnect,
                child: const Text('CONECTAR'),
              )
            else
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
