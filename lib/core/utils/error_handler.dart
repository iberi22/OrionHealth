import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized error handling system for the Orion app
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Stream controller for global error notifications
  final StreamController<AppError> _errorController =
      StreamController<AppError>.broadcast();

  // Public stream for listening to errors
  Stream<AppError> get errorStream => _errorController.stream;

  /// Handle and log errors with context
  static void handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? metadata,
    bool showToUser = true,
  }) {
    final appError = AppError(
      error: error,
      stackTrace: stackTrace,
      context: context ?? 'Unknown',
      severity: severity,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      showToUser: showToUser,
    );

    // Log to console in debug mode
    if (kDebugMode) {
      _logToConsole(appError);
    }

    // Send to error stream for UI handling
    _instance._errorController.add(appError);

    // Keep diagnostics local for the offline-first MVP.
    _logToLocalDiagnostics(appError);
  }

  /// Handle local session errors specifically
  static void handleAuthError(dynamic error, {String? context}) {
    handleError(
      error,
      null,
      context: context ?? 'Local Profile',
      severity: ErrorSeverity.warning,
      showToUser: true,
    );
  }

  /// Handle network errors
  static void handleNetworkError(dynamic error, {String? context}) {
    handleError(
      error,
      null,
      context: context ?? 'Network',
      severity: ErrorSeverity.error,
      metadata: {'type': 'network'},
      showToUser: true,
    );
  }

  /// Handle voice chat errors
  static void handleVoiceChatError(dynamic error, {String? context}) {
    handleError(
      error,
      null,
      context: context ?? 'Voice Chat',
      severity: ErrorSeverity.error,
      metadata: {'type': 'voice_chat'},
      showToUser: true,
    );
  }

  /// Handle memory service errors
  static void handleMemoryError(dynamic error, {String? context}) {
    handleError(
      error,
      null,
      context: context ?? 'Memory Service',
      severity: ErrorSeverity.warning,
      metadata: {'type': 'memory'},
      showToUser: false, // Memory errors are usually not critical for user
    );
  }

  /// Log error to console with formatting
  static void _logToConsole(AppError error) {
    final severityIcon = _getSeverityIcon(error.severity);
    print(
      '$severityIcon [${error.severity.name.toUpperCase()}] ${error.context}',
    );
    print('   Error: ${error.error}');
    if (error.stackTrace != null) {
      print(
        '   Stack: ${error.stackTrace.toString().split('\n').take(3).join('\n')}',
      );
    }
    if (error.metadata.isNotEmpty) {
      print('   Metadata: ${error.metadata}');
    }
    print('   Time: ${error.timestamp}');
    print('---');
  }

  /// Get icon for severity level
  static String _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 'ℹ️';
      case ErrorSeverity.warning:
        return '⚠️';
      case ErrorSeverity.error:
        return '❌';
      case ErrorSeverity.critical:
        return '🚨';
    }
  }

  /// Local diagnostics hook. No remote crash reporter is used by the MVP.
  static void _logToLocalDiagnostics(AppError error) {
    if (kDebugMode && error.severity == ErrorSeverity.critical) {
      print('Local critical diagnostic captured for ${error.context}');
    }
  }

  /// Show error to user via snackbar or dialog
  static void showErrorToUser(BuildContext context, AppError error) {
    if (!error.showToUser) return;

    final message = _getUserFriendlyMessage(error);
    final color = _getSeverityColor(error.severity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getSeverityIconData(error.severity),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        duration: Duration(
          seconds: error.severity == ErrorSeverity.critical ? 10 : 4,
        ),
        action:
            error.severity == ErrorSeverity.critical
                ? SnackBarAction(
                  label: 'Detalles',
                  textColor: Colors.white,
                  onPressed: () => _showErrorDialog(context, error),
                )
                : null,
      ),
    );
  }

  /// Get user-friendly error message
  static String _getUserFriendlyMessage(AppError error) {
    final errorString = error.error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Problema de conexión. Verifica tu internet.';
    }

    // Local profile/session errors
    if (errorString.contains('auth') || errorString.contains('credential')) {
      return 'Error de perfil local. Revisa el estado de la sesion.';
    }

    // Voice chat errors
    if (errorString.contains('microphone') || errorString.contains('audio')) {
      return 'Error con el micrófono. Verifica los permisos.';
    }

    // Memory errors
    if (errorString.contains('memory') || errorString.contains('storage')) {
      return 'Error de almacenamiento. Los datos se guardarán localmente.';
    }

    // Generic error based on severity
    switch (error.severity) {
      case ErrorSeverity.info:
        return 'Información: ${error.error}';
      case ErrorSeverity.warning:
        return 'Advertencia: Algo no funcionó como se esperaba.';
      case ErrorSeverity.error:
        return 'Error: ${error.error}';
      case ErrorSeverity.critical:
        return 'Error crítico: La aplicación encontró un problema grave.';
    }
  }

  /// Get color for severity level
  static Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red[900]!;
    }
  }

  /// Get icon data for severity level
  static IconData _getSeverityIconData(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info;
      case ErrorSeverity.warning:
        return Icons.warning;
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  /// Show detailed error dialog
  static void _showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error en ${error.context}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Severidad: ${error.severity.name}'),
                const SizedBox(height: 8),
                Text('Error: ${error.error}'),
                if (error.metadata.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Detalles: ${error.metadata}'),
                ],
                const SizedBox(height: 8),
                Text('Hora: ${error.timestamp}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  /// Dispose of resources
  void dispose() {
    _errorController.close();
  }
}

/// Error severity levels
enum ErrorSeverity { info, warning, error, critical }

/// Application error model
class AppError {
  final dynamic error;
  final StackTrace? stackTrace;
  final String context;
  final ErrorSeverity severity;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final bool showToUser;

  AppError({
    required this.error,
    this.stackTrace,
    required this.context,
    required this.severity,
    required this.metadata,
    required this.timestamp,
    required this.showToUser,
  });

  @override
  String toString() {
    return 'AppError(context: $context, severity: $severity, error: $error, timestamp: $timestamp)';
  }
}
