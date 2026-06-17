// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_health_summary_usecase.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetHealthSummaryUseCase _getHealthSummaryUseCase;
  final HomeRepository _homeRepository;

  HomeCubit(
    this._getHealthSummaryUseCase,
    this._homeRepository,
  ) : super(const HomeState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final summary = await _getHealthSummaryUseCase();
      final modules = await _homeRepository.getHomeModules();
      emit(state.copyWith(
        status: HomeStatus.loaded,
        healthSummary: summary,
        modules: modules,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh() => loadDashboard();
}
