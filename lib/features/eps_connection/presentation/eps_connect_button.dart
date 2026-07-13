import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/bloc/eps_connection_cubit.dart';
import '../application/bloc/eps_connection_state.dart';
import 'pages/eps_connection_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

/// Botón de conexión EPS que funciona con o sin BlocProvider.
///
/// Si se pasa un [cubit] explícito, se usa directamente.
/// Si se omite, busca un [BlocProvider] en el árbol de widgets.
class EpsConnectButton extends StatelessWidget {
  final EpsConnectionCubit? cubit;

  const EpsConnectButton({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    // Modo con cubit explícito: no depende de BlocProvider en el árbol
    if (cubit != null) {
      return _buildContent(context, cubit!);
    }

    // Modo con BlocProvider en el árbol (backward compat)
    try {
      final resolved = context.read<EpsConnectionCubit>();
      return _buildContent(context, resolved);
    } catch (_) {
      // Fallback sin provider: UI de 'Conectar' sin cubit
      return _buildFallback(context, null);
    }
  }

  Widget _buildContent(BuildContext context, EpsConnectionCubit cubit) {
    return BlocProvider<EpsConnectionCubit>.value(
      value: cubit,
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

          if (state is EpsConnectionLoaded && state.connections.isNotEmpty) {
            final conn = state.connections.first;
            return GlassmorphicCard(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Conectado con IHCE', style: TextStyle(color: Colors.white)),
                subtitle: Text('ID Paciente: ${conn.patientId}', style: const TextStyle(color: Colors.white70)),
                trailing: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EpsConnectionPage(cubit: cubit)),
                  ),
                  child: const Text('Ver Detalles', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            );
          }

          return _buildFallback(context, cubit);
        },
      ),
    );
  }

  Widget _buildFallback(BuildContext context, EpsConnectionCubit? cubit) {
    return GlassmorphicCard(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EpsConnectionPage(cubit: cubit)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.link, color: AppColors.primary),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conectar con mi EPS',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Sincroniza tus datos desde IHCE via OAuth',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
