import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/di/injection.dart';
import '../application/email_citas_cubit.dart';
import '../application/email_citas_state.dart';

class EmailConnectPage extends StatefulWidget {
  const EmailConnectPage({super.key});

  @override
  State<EmailConnectPage> createState() => _EmailConnectPageState();
}

class _EmailConnectPageState extends State<EmailConnectPage> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  late final EmailCitasCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<EmailCitasCubit>();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _cubit.handleOAuthRedirect(uri);
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<EmailCitasCubit, EmailCitasState>(
        listener: (context, state) {
          if (state is EmailCitasSyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sincronización completada')),
            );
          } else if (state is EmailCitasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Conectar Correo'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<EmailCitasCubit, EmailCitasState>(
              builder: (context, state) {
                final bool isGmailConnected = state is EmailCitasConnected && state.isGmailConnected;
                final bool isOutlookConnected = state is EmailCitasConnected && state.isOutlookConnected;
                final bool isLoading = state is EmailCitasLoading;

                return Column(
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
                      isConnected: isGmailConnected,
                      onConnect: () => _cubit.connectGmail(),
                    ),
                    const SizedBox(height: 16),
                    _EmailProviderCard(
                      name: 'Outlook',
                      icon: Icons.mail_outline,
                      isConnected: isOutlookConnected,
                      onConnect: () => _cubit.connectOutlook(),
                    ),
                    const Spacer(),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (isGmailConnected || isOutlookConnected)
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _cubit.manualSync(),
                        icon: const Icon(Icons.sync),
                        label: const Text('SINCRONIZAR AHORA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CyberTheme.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
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
