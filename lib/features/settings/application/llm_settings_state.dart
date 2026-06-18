part of 'llm_settings_cubit.dart';

abstract class LlmSettingsState extends Equatable {
  const LlmSettingsState();

  @override
  List<Object?> get props => [];
}

class LlmSettingsInitial extends LlmSettingsState {}

class LlmSettingsLoading extends LlmSettingsState {}

class LlmSettingsLoaded extends LlmSettingsState {
  final LlmConfig config;
  final AppSettings appSettings;
  final DeviceCapability deviceCapability;
  final Set<String> installedModels;
  final Map<String, double> downloadProgress;
  final bool? connectionVerified;
  final String? connectionError;
  final String? exportData;

  const LlmSettingsLoaded({
    required this.config,
    required this.appSettings,
    required this.deviceCapability,
    this.installedModels = const {},
    this.downloadProgress = const {},
    this.connectionVerified,
    this.connectionError,
    this.exportData,
  });

  LlmSettingsLoaded copyWith({
    LlmConfig? config,
    AppSettings? appSettings,
    DeviceCapability? deviceCapability,
    Set<String>? installedModels,
    Map<String, double>? downloadProgress,
    bool? connectionVerified,
    String? connectionError,
    String? exportData,
  }) {
    return LlmSettingsLoaded(
      config: config ?? this.config,
      appSettings: appSettings ?? this.appSettings,
      deviceCapability: deviceCapability ?? this.deviceCapability,
      installedModels: installedModels ?? this.installedModels,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      connectionVerified: connectionVerified ?? this.connectionVerified,
      connectionError: connectionError ?? this.connectionError,
      exportData: exportData ?? this.exportData,
    );
  }

  @override
  List<Object?> get props => [
        config,
        appSettings,
        deviceCapability,
        installedModels,
        downloadProgress,
        connectionVerified,
        connectionError,
        exportData,
      ];
}

class LlmSettingsError extends LlmSettingsState {
  final String message;

  const LlmSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
