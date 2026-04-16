import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/bloc/auth_cubit.dart';
import '../application/bloc/auth_state.dart';

class SetupPinPage extends StatefulWidget {
  const SetupPinPage({super.key});

  @override
  State<SetupPinPage> createState() => _SetupPinPageState();
}

class _SetupPinPageState extends State<SetupPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isConfirming = false;
  String? _error;

  void _onNumberPressed(String number) {
    setState(() {
      _error = null;
      final controller = _isConfirming ? _confirmPinController : _pinController;
      if (controller.text.length < 6) {
        controller.text += number;
      }

      if (controller.text.length >= 4) {
        // Auto-advance or finish if matched
        if (!_isConfirming && controller.text.length == 6) {
          // You might want a "Next" button instead of auto-advance for variable length
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      final controller = _isConfirming ? _confirmPinController : _pinController;
      if (controller.text.isNotEmpty) {
        controller.text = controller.text.substring(0, controller.text.length - 1);
      }
    });
  }

  void _proceed() {
    if (_pinController.text.length < 4) {
      setState(() {
        _error = 'El PIN debe tener al menos 4 dígitos';
      });
      return;
    }

    if (!_isConfirming) {
      setState(() {
        _isConfirming = true;
      });
    } else {
      if (_pinController.text == _confirmPinController.text) {
        context.read<AuthCubit>().setupPin(_pinController.text);
      } else {
        setState(() {
          _error = 'Los PINs no coinciden';
          _confirmPinController.clear();
        });
      }
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
              const SizedBox(height: 40),
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _isConfirming ? 'Confirma tu PIN' : 'Configura tu PIN',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming
                    ? 'Introduce el PIN de nuevo para confirmar'
                    : 'El PIN protegerá tus datos médicos',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final controller = _isConfirming ? _confirmPinController : _pinController;
                  final isFilled = index < controller.text.length;
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
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const Spacer(),
              _buildKeyboard(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(_isConfirming ? 'CONFIRMAR' : 'CONTINUAR'),
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
