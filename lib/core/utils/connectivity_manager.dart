import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'cache_manager.dart';
import '../../features/sync/domain/services/sync_service.dart';

/// Manages network connectivity and offline capabilities
class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;
  ConnectivityManager._internal();

  final Connectivity _connectivity = Connectivity();

  // Stream controllers
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  // Current connectivity status
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  // Subscription to connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Public getters
  ConnectivityStatus get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus == ConnectivityStatus.connected;
  bool get isOffline => _currentStatus == ConnectivityStatus.disconnected;
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateStatus,
        onError: (error) {
          if (kDebugMode) {
            print(
              'ConnectivityManager: Error listening to connectivity changes - $error',
            );
          }
        },
      );

      if (kDebugMode) {
        print(
          'ConnectivityManager: Initialized with status ${_currentStatus.name}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('ConnectivityManager: Error during initialization - $e');
      }
      _currentStatus = ConnectivityStatus.unknown;
    }
  }

  /// Update connectivity status based on connectivity result
  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    final newStatus =
        hasConnection
            ? ConnectivityStatus.connected
            : ConnectivityStatus.disconnected;

    if (newStatus != _currentStatus) {
      final previousStatus = _currentStatus;
      _currentStatus = newStatus;

      _statusController.add(_currentStatus);

      if (kDebugMode) {
        print(
          'ConnectivityManager: Status changed from ${previousStatus.name} to ${_currentStatus.name}',
        );
      }

      // Trigger callbacks for status changes
      _handleStatusChange(previousStatus, _currentStatus);
    }
  }

  /// Handle connectivity status changes
  void _handleStatusChange(
    ConnectivityStatus previous,
    ConnectivityStatus current,
  ) {
    if (previous == ConnectivityStatus.disconnected &&
        current == ConnectivityStatus.connected) {
      _onConnectionRestored();
    } else if (previous == ConnectivityStatus.connected &&
        current == ConnectivityStatus.disconnected) {
      _onConnectionLost();
    }
  }

  /// Called when connection is restored
  void _onConnectionRestored() {
    if (kDebugMode) {
      print('ConnectivityManager: Connection restored');
    }

    // Trigger sync operations, retry failed requests, etc.
    triggerDataSync();
  }

  /// Called when connection is lost
  void _onConnectionLost() {
    if (kDebugMode) {
      print('ConnectivityManager: Connection lost - switching to offline mode');
    }

    // Enable offline mode, cache data, etc.
    enableOfflineMode();
  }

  /// Trigger data synchronization when connection is restored
  @visibleForTesting
  void triggerDataSync() {
    try {
      // 1. Sync clinical data via SyncService
      GetIt.instance<SyncService>().performFullSync().catchError((e) {
        if (kDebugMode) {
          print('ConnectivityManager: Error during data sync - $e');
        }
      });

      // 2. Ensure CacheManager is ready
      CacheManager().initialize().catchError((e) {
        if (kDebugMode) {
          print('ConnectivityManager: Error initializing CacheManager - $e');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('ConnectivityManager: Failed to trigger data sync - $e');
      }
    }
  }

  /// Enable offline mode functionality
  @visibleForTesting
  void enableOfflineMode() {
    try {
      // Ensure CacheManager is initialized for offline access
      CacheManager().initialize().catchError((e) {
        if (kDebugMode) {
          print(
            'ConnectivityManager: Error initializing CacheManager in offline mode - $e',
          );
        }
      });

      if (kDebugMode) {
        print('ConnectivityManager: Offline mode enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ConnectivityManager: Failed to enable offline mode - $e');
      }
    }
  }

  /// Check if a specific operation requires internet
  bool requiresInternet(String operation) {
    final internetRequiredOperations = {
      'ai_chat',
      'voice_transcription',
      'user_authentication',
      'data_sync',
      'memory_backup',
    };

    return internetRequiredOperations.contains(operation);
  }

  /// Execute operation with connectivity check
  Future<T> executeWithConnectivity<T>(
    String operation,
    Future<T> Function() onlineTask,
    Future<T> Function()? offlineTask,
  ) async {
    if (isOnline || !requiresInternet(operation)) {
      try {
        return await onlineTask();
      } catch (e) {
        // If online task fails and we have offline fallback, try it
        if (offlineTask != null) {
          if (kDebugMode) {
            print(
              'ConnectivityManager: Online task failed, trying offline fallback for $operation',
            );
          }
          return await offlineTask();
        }
        rethrow;
      }
    } else {
      // We're offline
      if (offlineTask != null) {
        if (kDebugMode) {
          print('ConnectivityManager: Executing offline task for $operation');
        }
        return await offlineTask();
      } else {
        throw ConnectivityException(
          'Operation $operation requires internet connection',
        );
      }
    }
  }

  /// Get connectivity status description
  String getStatusDescription() {
    switch (_currentStatus) {
      case ConnectivityStatus.connected:
        return 'Conectado a internet';
      case ConnectivityStatus.disconnected:
        return 'Sin conexión a internet';
      case ConnectivityStatus.unknown:
        return 'Estado de conexión desconocido';
    }
  }

  /// Get connectivity icon
  String getStatusIcon() {
    switch (_currentStatus) {
      case ConnectivityStatus.connected:
        return '🌐';
      case ConnectivityStatus.disconnected:
        return '📵';
      case ConnectivityStatus.unknown:
        return '❓';
    }
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}

/// Connectivity status enumeration
enum ConnectivityStatus { connected, disconnected, unknown }

/// Exception thrown when connectivity is required but not available
class ConnectivityException implements Exception {
  final String message;

  ConnectivityException(this.message);

  @override
  String toString() => 'ConnectivityException: $message';
}

/// Widget to show connectivity status
class ConnectivityIndicator extends StatelessWidget {
  final Widget child;
  final bool showWhenOnline;

  const ConnectivityIndicator({
    super.key,
    required this.child,
    this.showWhenOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: ConnectivityManager().statusStream,
      initialData: ConnectivityManager().currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.unknown;
        final shouldShow =
            status == ConnectivityStatus.disconnected ||
            (showWhenOnline && status == ConnectivityStatus.connected);

        return Column(
          children: [
            if (shouldShow)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color:
                    status == ConnectivityStatus.connected
                        ? Colors.green[600]
                        : Colors.red[600],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ConnectivityManager().getStatusIcon(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ConnectivityManager().getStatusDescription(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
