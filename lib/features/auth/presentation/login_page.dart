import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/bloc/auth_cubit.dart';
import '../application/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  final bool isBiometricsAvailable;
  final String? error;

  const LoginPage({
    super.key,
    this.isBiometricsAvailable = false,
    this.error,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pinController = TextEditingController();

  void _onNumberPressed(String number) {
    if (_pinController.text.length < 6) {
      setState(() {
        _pinController.text += number;
      });

      if (_pinController.text.length >= 4) {
        // We could auto-submit here if we had a fixed length PIN,
        // but let's use a submit button or a specific length.
        if (_pinController.text.length == 6) {
           _login();
        }
      }
    }
  }

  void _onDelete() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
      });
    }
  }

  void _login() {
    if (_pinController.text.length >= 4) {
      context.read<AuthCubit>().loginWithPin(_pinController.text);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isBiometricsAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthCubit>().loginWithBiometrics();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Icon(
                Icons.security,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Bienvenido de nuevo',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Introduce tu PIN para acceder',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final isFilled = index < _pinController.text.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }),
              ),
              if (widget.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const Spacer(),
              _buildKeyboard(),
              const SizedBox(height: 24),
              if (widget.isBiometricsAvailable)
                TextButton.icon(
                  onPressed: () => context.read<AuthCubit>().loginWithBiometrics(),
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('USAR BIOMETRÍA'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var j = 1; j <= 3; j++)
                  _buildKey((i * 3 + j).toString()),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 64),
            _buildKey('0'),
            IconButton(
              onPressed: _onDelete,
              icon: const Icon(Icons.backspace_outlined),
              iconSize: 32,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String label) {
    return InkWell(
      onTap: () => _onNumberPressed(label),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
