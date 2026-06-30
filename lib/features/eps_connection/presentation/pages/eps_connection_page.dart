import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/eps_connection_cubit.dart';
import '../../application/bloc/eps_connection_state.dart';
import '../widgets/eps_connection_status_card.dart';

import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/theme/app_colors.dart';

class EpsConnectionPage extends StatelessWidget {
  const EpsConnectionPage({super.key});

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
                child: BlocConsumer<EpsConnectionCubit, EpsConnectionState>(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddConnectionButton(BuildContext context) {
    return GlassmorphicCard(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR scanner coming soon')),
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                'Connect via QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
