import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/cyber_theme.dart';
import '../application/bloc/auth_cubit.dart';

/// Página de configuración inicial del PIN
class SetupPinPage extends StatefulWidget {
  const SetupPinPage({super.key});

  @override
  State<SetupPinPage> createState() => _SetupPinPageState();
}

class _SetupPinPageState extends State<SetupPinPage> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _pinFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  int _currentStep = 0; // 0: crear PIN, 1: confirmar PIN
  bool _obscurePin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _onPinComplete(String pin) {
    if (pin.length >= 4) {
      if (_currentStep == 0) {
        // Avanzar a confirmación
        setState(() {
          _currentStep = 1;
          _errorMessage = null;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          _confirmFocusNode.requestFocus();
        });
      } else {
        // Verificar que coincidan
        if (_pinController.text == _confirmPinController.text) {
          _setupPin();
        } else {
          setState(() {
            _errorMessage = 'Los PINs no coinciden';
            _confirmPinController.clear();
          });
          HapticFeedback.mediumImpact();
        }
      }
    }
  }

  void _setupPin() {
    setState(() {
      _isLoading = true;
    });
    context.read<AuthCubit>().setupPin(_pinController.text);
  }

  void _goBack() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
        _confirmPinController.clear();
        _errorMessage = null;
      });
      _pinFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        setState(() {
          _isLoading = state is AuthLoading;
        });

        if (state is AuthError) {
          setState(() {
            _errorMessage = state.message;
          });
        }
      },
      child: Scaffold(
        backgroundColor: CyberTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _currentStep == 1
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _goBack,
                )
              : null,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono y título
                  _buildHeader(),
                  const SizedBox(height: 48),

                  // Indicador de pasos
                  _buildStepIndicator(),
                  const SizedBox(height: 32),

                  // Campo de PIN
                  if (_currentStep == 0) _buildPinField(),
                  if (_currentStep == 1) _buildConfirmPinField(),

                  // Mensaje de error
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(),
                  ],

                  const SizedBox(height: 32),

                  // Instrucciones
                  _buildInstructions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [CyberTheme.secondary, CyberTheme.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            _currentStep == 0 ? Icons.lock_outline : Icons.lock,
            size: 40,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _currentStep == 0 ? 'Crear PIN de Seguridad' : 'Confirmar PIN',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentStep == 0
              ? 'Protege tus datos médicos con un PIN'
              : 'Ingresa el PIN nuevamente',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot(0),
        Container(
          width: 40,
          height: 2,
          color: _currentStep >= 1
              ? CyberTheme.primary
              : Colors.white.withOpacity(0.3),
        ),
        _buildStepDot(1),
      ],
    );
  }

  Widget _buildStepDot(int step) {
    final isActive = _currentStep >= step;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? CyberTheme.primary : Colors.transparent,
        border: Border.all(
          color: isActive ? CyberTheme.primary : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildPinField() {
    return _buildPinInput(
      controller: _pinController,
      focusNode: _pinFocusNode,
      label: 'Ingresa un PIN de 4-6 dígitos',
      onChanged: (value) {
        setState(() {
          _errorMessage = null;
        });
        if (value.length == 4) {
          _onPinComplete(value);
        }
      },
      onSubmitted: (_) => _onPinComplete(_pinController.text),
    );
  }

  Widget _buildConfirmPinField() {
    return _buildPinInput(
      controller: _confirmPinController,
      focusNode: _confirmFocusNode,
      label: 'Confirma tu PIN',
      onChanged: (value) {
        setState(() {
          _errorMessage = null;
        });
        if (value.length == _pinController.text.length) {
          _onPinComplete(value);
        }
      },
      onSubmitted: (_) => _onPinComplete(_confirmPinController.text),
    );
  }

  Widget _buildPinInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _errorMessage != null
                  ? Colors.red
                  : CyberTheme.secondary.withOpacity(0.3),
              width: 1,
            ),
            color: Colors.white.withOpacity(0.05),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            autofocus: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              letterSpacing: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '• • • •',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 32,
                letterSpacing: 20,
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
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        if (_isLoading) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(color: CyberTheme.secondary),
        ],
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: CyberTheme.secondary.withOpacity(0.1),
        border: Border.all(color: CyberTheme.secondary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: CyberTheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Seguridad de datos médicos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Encriptación AES-256 de grado militar\n'
            '• PIN almacenado con hash Argon2id\n'
            '• Datos médicos protegidos localmente\n'
            '• Sin envío a servidores externos',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
