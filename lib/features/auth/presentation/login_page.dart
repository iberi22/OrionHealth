import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/bloc/auth_cubit.dart';
import '../application/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().loginWithBiometrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLocked) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Acceso Bloqueado', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Inténtalo de nuevo a las ${state.lockoutUntil.hour}:${state.lockoutUntil.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.green),
                const SizedBox(height: 32),
                const Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: 'Introduce tu pin',
                    border: const OutlineInputBorder(),
                    errorText: state is AuthUnauthenticated ? state.errorMessage : null,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  onSubmitted: (value) {
                    if (value.length >= 4) {
                      context.read<AuthCubit>().loginWithPin(value);
                      _pinController.clear();
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_pinController.text.length >= 4) {
                      context.read<AuthCubit>().loginWithPin(_pinController.text);
                      _pinController.clear();
                    }
                  },
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(Icons.fingerprint, size: 48),
                  onPressed: () => context.read<AuthCubit>().loginWithBiometrics(),
                ),
                const Text('Usar biometría'),
              ],
            ),
          );
        },
      ),
    );
  }
}
