import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/eps_connection_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class EpsConnectButton extends StatelessWidget {
  const EpsConnectButton({super.key});

  @override
  Widget build(BuildContext context) {
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

        if (state is EpsConnectionConnected) {
          return GlassmorphicCard(
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Conectado con IHCE', style: TextStyle(color: Colors.white)),
              subtitle: Text('ID Paciente: ${state.patientId}', style: const TextStyle(color: Colors.white70)),
              trailing: TextButton(
                onPressed: () => context.read<EpsConnectionCubit>().disconnect(),
                child: const Text('Desconectar', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          );
        }

        return GlassmorphicCard(
          child: InkWell(
            onTap: () => context.read<EpsConnectionCubit>().connect(),
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
      },
    );
  }
}
