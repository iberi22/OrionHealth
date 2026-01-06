import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../application/bloc/auth_cubit.dart';
import 'login_page.dart';
import 'setup_pin_page.dart';

/// Widget que controla el flujo de autenticación de la app
/// Muestra login, setup o el contenido principal según el estado
class AuthGate extends StatefulWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  late AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = GetIt.I<AuthCubit>();
    WidgetsBinding.instance.addObserver(this);

    // Verificar estado de auth al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authCubit.checkAuthStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App va al background - iniciar timeout
        break;
      case AppLifecycleState.resumed:
        // App vuelve al foreground - verificar timeout
        _authCubit.checkSessionTimeout();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _authCubit,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // Registrar actividad cuando la UI se construye
          if (state is AuthAuthenticated) {
            _authCubit.recordActivity();
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildContent(state),
          );
        },
      ),
    );
  }

  Widget _buildContent(AuthState state) {
    if (state is AuthInitial || state is AuthLoading) {
      return _buildLoadingScreen();
    }

    if (state is AuthSetupRequired) {
      return const SetupPinPage();
    }

    if (state is AuthRequired ||
        state is AuthPinIncorrect ||
        state is AuthLocked ||
        state is AuthBiometricLocked) {
      return const LoginPage();
    }

    if (state is AuthAuthenticated) {
      return widget.child;
    }

    if (state is AuthError) {
      return _buildErrorScreen(state.message);
    }

    return _buildLoadingScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FF85), Color(0xFF00E0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF85).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_hospital,
                size: 40,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Color(0xFF00E0FF)),
            const SizedBox(height: 16),
            Text(
              'Cargando...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error de Autenticación',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _authCubit.checkAuthStatus();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
