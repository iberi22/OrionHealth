import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/bloc/auth_cubit.dart';
import '../application/bloc/auth_state.dart';
import 'login_page.dart';
import 'setup_pin_page.dart';

class AuthGate extends StatelessWidget {
  final Widget authenticatedChild;

  const AuthGate({
    super.key,
    required this.authenticatedChild,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          context.read<AuthCubit>().checkAuthStatus();
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthNoPinSet) {
          return const SetupPinPage();
        }

        if (state is AuthUnauthenticated) {
          return LoginPage(
            isBiometricsAvailable: state.isBiometricsAvailable,
            error: state.error,
          );
        }

        if (state is AuthLocked) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_clock, size: 80, color: Colors.red),
                    const SizedBox(height: 24),
                    Text(
                      'Demasiados intentos fallidos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Por seguridad, el acceso ha sido bloqueado temporalmente.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reintenta en: ${state.remainingSeconds} segundos',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return authenticatedChild;
        }

        if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<AuthCubit>().checkAuthStatus(),
                    child: const Text('REINTENTAR'),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Estado de autenticación desconocido')),
        );
      },
    );
  }
}
