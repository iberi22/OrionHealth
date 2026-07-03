import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/about_info.dart';
import '../domain/usecases/check_updates.dart';
import '../domain/usecases/get_app_info.dart';

abstract class AboutState extends Equatable {
  const AboutState();

  @override
  List<Object?> get props => [];
}

class AboutInitial extends AboutState {
  const AboutInitial();
}

class AboutLoading extends AboutState {
  const AboutLoading();
}

class AboutLoaded extends AboutState {
  final AboutInfo aboutInfo;

  const AboutLoaded(this.aboutInfo);

  @override
  List<Object?> get props => [aboutInfo];
}

class AboutError extends AboutState {
  final String message;

  const AboutError(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class AboutCubit extends Cubit<AboutState> {
  final GetAppInfo _getAppInfo;
  final CheckUpdates _checkUpdates;

  AboutCubit(
    this._getAppInfo,
    this._checkUpdates,
  ) : super(const AboutInitial());

  Future<void> loadAboutInfo() async {
    emit(const AboutLoading());
    try {
      final info = await _getAppInfo.execute();
      emit(AboutLoaded(info));
    } catch (e) {
      emit(AboutError(e.toString()));
    }
  }

  Future<bool> checkForUpdates() async {
    try {
      return await _checkUpdates.execute();
    } catch (_) {
      return false;
    }
  }
}
