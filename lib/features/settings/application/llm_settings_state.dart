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

  const LlmSettingsLoaded({
    required this.config,
    required this.deviceCapability,
  });

  @override
  List<Object?> get props => [config, deviceCapability];

  LlmSettingsLoaded copyWith({
    LlmConfig? config,
    DeviceCapability? deviceCapability,
  }) {
    return LlmSettingsLoaded(
      config: config ?? this.config,
      deviceCapability: deviceCapability ?? this.deviceCapability,
    );
  }
}

class LlmSettingsError extends LlmSettingsState {
  final String message;

  const LlmSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
