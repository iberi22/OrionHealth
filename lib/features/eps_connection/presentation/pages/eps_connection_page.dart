import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/eps_connection_cubit.dart';
import '../../application/bloc/eps_connection_state.dart';
import '../widgets/eps_connection_status_card.dart';
import '../widgets/eps_qr_scanner_page.dart';
import '../../domain/entities/eps_providers_catalog.dart';
import '../../domain/entities/eps_provider.dart';

import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/theme/app_colors.dart';

class EpsConnectionPage extends StatelessWidget {
  final EpsConnectionCubit? cubit;

  const EpsConnectionPage({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const PageHeader(
                title: 'EPS Connections',
                showBackButton: true,
              ),
              Expanded(
                child: _buildBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // If cubit provided, wrap with BlocProvider
    if (cubit != null) {
      return BlocProvider<EpsConnectionCubit>.value(
        value: cubit!,
        child: _buildContent(context),
      );
    }

    // Fallback: try to find provider in tree (backward compat)
    try {
      context.read<EpsConnectionCubit>();
      return _buildContent(context);
    } catch (_) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'EPS connection not available',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }
  }

  Widget _buildContent(BuildContext context) {
    return BlocConsumer<EpsConnectionCubit, EpsConnectionState>(
      listener: (context, state) {
        if (state is EpsConnectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is EpsConnectionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EpsConnectionLoaded) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.connections.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No EPS providers connected',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else
                ...state.connections.map(
                  (conn) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EpsConnectionStatusCard(
                      connection: conn,
                      onDisconnect: () => context
                          .read<EpsConnectionCubit>()
                          .disconnect(conn.provider.id),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _buildAddConnectionButton(context),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddConnectionButton(BuildContext context) {
    return GlassmorphicCard(
      child: InkWell(
        onTap: () async {
          try {
            final result = await Navigator.push<EPSProviderScanResult>(
              context,
              MaterialPageRoute(builder: (_) => const EpsQrScannerPage()),
            );
            if (result != null && mounted) {
              _handleScanResult(context, result);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al abrir el escáner: $e')),
              );
            }
          }
        },
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, color: AppColors.primary),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Connect via QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleScanResult(BuildContext context, EPSProviderScanResult result) {
    if (result.providerId != null) {
      // Buscar en el catálogo
      final provider = EpsProvidersCatalog.byId(result.providerId!);
      if (provider != null) {
        // Conectar con la EPS escaneada
        try {
          context.read<EpsConnectionCubit>().connect(provider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Conectando con ${provider.name}...')),
          );
          return;
        } catch (_) {}
      }
    }

    if (result.discoveryUrl != null) {
      // Crear provider temporal con la URL escaneada
      final provider = EPSProvider(
        id: result.providerId ?? 'scanned-${DateTime.now().millisecondsSinceEpoch}',
        name: result.providerId ?? 'EPS Escaneada',
        discoveryUrl: result.discoveryUrl!,
        clientId: 'orionhealth',
        redirectUrl: 'orionhealth://callback',
        scopes: const ['openid', 'fhirUser', 'offline_access',
          'patient/Patient.read', 'patient/Observation.read'],
      );
      try {
        context.read<EpsConnectionCubit>().connect(provider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conectando con EPS...')),
        );
        return;
      } catch (_) {}
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código QR no reconocido como EPS válida')),
    );
  }
}
