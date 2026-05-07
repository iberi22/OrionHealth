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
  final DeviceCapability deviceCapability;
  final bool? connectionVerified;
  final String? connectionError;
  final List<Map<String, dynamic>>? localModelList;

  const LlmSettingsLoaded({
    required this.config,
    required this.deviceCapability,
    this.connectionVerified,
    this.connectionError,
    this.localModelList,
  });

  @override
  List<Object?> get props => [config, deviceCapability, connectionVerified, connectionError, localModelList];

  LlmSettingsLoaded copyWith({
    LlmConfig? config,
    DeviceCapability? deviceCapability,
    bool? connectionVerified,
    String? connectionError,
    List<Map<String, dynamic>>? localModelList,
  }) {
    return LlmSettingsLoaded(
      config: config ?? this.config,
      deviceCapability: deviceCapability ?? this.deviceCapability,
      connectionVerified: connectionVerified ?? this.connectionVerified,
      connectionError: connectionError ?? this.connectionError,
      localModelList: localModelList ?? this.localModelList,
    );
  }
}

class LlmSettingsError extends LlmSettingsState {
  final String message;

  const LlmSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
