// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import '../domain/entities/home_health_summary.dart';
import '../domain/entities/home_module.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final HomeHealthSummary? healthSummary;
  final List<HomeModule> modules;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.healthSummary,
    this.modules = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    HomeHealthSummary? healthSummary,
    List<HomeModule>? modules,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      healthSummary: healthSummary ?? this.healthSummary,
      modules: modules ?? this.modules,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, healthSummary, modules, errorMessage];
}
