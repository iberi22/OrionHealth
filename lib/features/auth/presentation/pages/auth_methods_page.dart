import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/auth_cubit.dart';
import '../../application/bloc/auth_state.dart';

class AuthMethodsPage extends StatelessWidget {
  const AuthMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos de Autenticación'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Elige cómo quieres proteger tu billetera de salud.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('PIN de Seguridad'),
                  subtitle: const Text('Configura un código numérico'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to PIN setup
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Autenticación Biométrica'),
                  subtitle: const Text('Usa tu huella o rostro'),
                  trailing: Switch(
                    value: false, // This would come from state
                    onChanged: (value) {
                      // Toggle biometrics
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Seguridad Avanzada',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Historial de Accesos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
