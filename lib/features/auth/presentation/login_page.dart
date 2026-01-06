import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/cyber_theme.dart';
import '../application/bloc/auth_cubit.dart';

/// Página de login con PIN y opción biométrica
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _obscurePin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeController.forward();
    HapticFeedback.mediumImpact();
  }

  void _onPinSubmit() {
    if (_pinController.text.length >= 4) {
      context.read<AuthCubit>().authenticateWithPin(_pinController.text);
    }
  }

  void _onBiometricTap() {
    context.read<AuthCubit>().authenticateWithBiometric();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPinIncorrect) {
          _shake();
          _pinController.clear();
          if (state.remainingAttempts > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'PIN incorrecto. ${state.remainingAttempts} intentos restantes.',
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
        setState(() {
          _isLoading = state is AuthLoading;
        });
      },
      builder: (context, state) {
        if (state is AuthLocked) {
          return _buildLockedScreen(state);
        }

        final biometricAvailable = state is AuthRequired
            ? state.biometricAvailable
            : false;

        return Scaffold(
          backgroundColor: CyberTheme.backgroundDark,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo y título
                    _buildHeader(),
                    const SizedBox(height: 48),

                    // Campo de PIN
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: _buildPinField(),
                    ),
                    const SizedBox(height: 24),

                    // Botón de login
                    _buildLoginButton(),
                    const SizedBox(height: 24),

                    // Opción biométrica
                    if (biometricAvailable) ...[
                      _buildBiometricButton(),
                      const SizedBox(height: 16),
                    ],

                    // Texto de ayuda
                    _buildHelpText(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [CyberTheme.primary, CyberTheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: CyberTheme.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_hospital,
            size: 50,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'OrionHealth',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu PIN de seguridad',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildPinField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberTheme.secondary.withOpacity(0.3),
          width: 1,
        ),
        color: Colors.white.withOpacity(0.05),
      ),
      child: TextField(
        controller: _pinController,
        focusNode: _pinFocusNode,
        obscureText: _obscurePin,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 6,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 16,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: '• • • •',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 24,
            letterSpacing: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePin ? Icons.visibility_off : Icons.visibility,
              color: CyberTheme.secondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePin = !_obscurePin;
              });
            },
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _onPinSubmit(),
        onChanged: (value) {
          // Auto-submit cuando se completa el PIN de 4 dígitos
          if (value.length == 4) {
            _onPinSubmit();
          }
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onPinSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: CyberTheme.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Text(
                'DESBLOQUEAR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return TextButton.icon(
      onPressed: _isLoading ? null : _onBiometricTap,
      icon: const Icon(Icons.fingerprint, size: 28),
      label: const Text('Usar biométrico'),
      style: TextButton.styleFrom(
        foregroundColor: CyberTheme.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildHelpText() {
    return Text(
      'Tus datos médicos están protegidos\ncon encriptación de grado militar',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
    );
  }

  Widget _buildLockedScreen(AuthLocked state) {
    return Scaffold(
      backgroundColor: CyberTheme.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.2),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Cuenta Bloqueada',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Demasiados intentos fallidos.\nInténtalo de nuevo en ${state.remainingMinutes} minuto${state.remainingMinutes == 1 ? '' : 's'}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(
                        '${state.failedAttempts} intentos fallidos',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
