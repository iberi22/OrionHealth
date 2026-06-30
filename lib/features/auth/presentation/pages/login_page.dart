import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/auth_cubit.dart';
import '../../application/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();
  bool _obscurePin = true;

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'OrionHealth',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 48),
                  if (state.status == AuthStatus.loading)
                    const CircularProgressIndicator()
                  else
                    _buildAuthForm(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthForm(BuildContext context, AuthState state) {
    if (!state.isPinSet) {
      return _buildPinSetup(context);
    }

    return Column(
      children: [
        TextField(
          controller: _pinController,
          focusNode: _pinFocusNode,
          obscureText: _obscurePin,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            labelText: 'Enter pin',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePin = !_obscurePin),
            ),
          ),
          onSubmitted: (pin) => _submitPin(context, pin),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _submitPin(context, _pinController.text),
          child: const Text('Login'),
        ),
        if (state.isBiometricAvailable) ...[
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => context.read<AuthCubit>().verifyBiometric(),
            icon: const Icon(Icons.fingerprint),
            label: const Text('Use Biometric'),
          ),
        ],
      ],
    );
  }

  Widget _buildPinSetup(BuildContext context) {
    return Column(
      children: [
        Text(
          'Set up your pin',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text('pin must be 4-6 digits'),
        const SizedBox(height: 24),
        TextField(
          controller: _pinController,
          obscureText: _obscurePin,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            labelText: 'New pin',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePin = !_obscurePin),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final pin = _pinController.text;
            if (pin.length >= 4) {
              context.read<AuthCubit>().setPin(pin);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('pin must be at least 4 digits')),
              );
            }
          },
          child: const Text('Set pin'),
        ),
      ],
    );
  }

  void _submitPin(BuildContext context, String pin) {
    if (pin.length >= 4) {
      context.read<AuthCubit>().submitPin(pin);
      _pinController.clear();
    }
  }
}
