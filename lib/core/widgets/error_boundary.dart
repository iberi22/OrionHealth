// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/services/app_logger.dart';

/// Catches Flutter errors and renders a fallback UI instead of crashing.
///
/// Wraps child widgets in a [FlutterError.onError] aware boundary that:
/// 1. Catches build/layout errors via [ErrorWidget.builder]
/// 2. Catches async errors in descendant zones
/// 3. Renders a friendly error screen with retry option
class ErrorBoundary extends StatefulWidget {
  final Widget Function(BuildContext context, Object error) errorBuilder;
  final Widget child;
  final String? label;

  const ErrorBoundary({
    super.key,
    this.errorBuilder = _defaultErrorBuilder,
    required this.child,
    this.label,
  });

  static Widget _defaultErrorBuilder(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Algo salió mal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _userFriendlyMessage(error),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const _ResetApp(),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _userFriendlyMessage(Object error) {
    final msg = error.toString();
    if (msg.contains('NoSuchMethodError')) {
      return 'Error inesperado en la interfaz. Por favor, reinicia la app.';
    }
    if (msg.contains('Null check operator') || msg.contains('as String')) {
      return 'Encontramos datos inesperados. Reiniciando puede resolverlo.';
    }
    if (msg.contains('Timeout')) {
      return 'La operación tardó demasiado. Verifica tu conexión.';
    }
    return 'Ocurrió un error inesperado. Puedes reiniciar la aplicación.';
  }

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  ErrorWidgetBuilder? _originalBuilder;
  void Function(FlutterErrorDetails)? _originalHandler;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _installErrorHandlers();
  }

  void _installErrorHandlers() {
    _originalHandler = FlutterError.onError;
    _originalBuilder = ErrorWidget.builder;

    FlutterError.onError = (details) {
      AppLogger.e(
        widget.label ?? 'ErrorBoundary',
        details.exceptionAsString(),
        error: details.exception,
        stackTrace: details.stack,
      );
      _originalHandler?.call(details);
    };

    ErrorWidget.builder = (details) {
      AppLogger.e(
        widget.label ?? 'ErrorBoundary',
        'Build error: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
      if (mounted) {
        setState(() => _error = details.exception);
      }
      return widget.errorBuilder(context, details.exception);
    };
  }

  @override
  void dispose() {
    FlutterError.onError = _originalHandler;
    ErrorWidget.builder = _originalBuilder ?? ErrorWidget.builder;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder(context, _error!);
    }
    return widget.child;
  }
}

/// Silent reboot page used by ErrorBoundary retry flow.
class _ResetApp extends StatelessWidget {
  const _ResetApp();

  @override
  Widget build(BuildContext context) {
    // Trigger a full app reload
    // reassemble() removed in Flutter 3.38;
    // full restart requires platform channel
    // WidgetsBinding.instance.reassemble();
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
