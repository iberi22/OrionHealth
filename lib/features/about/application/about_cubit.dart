import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/about_info.dart';
import '../domain/repositories/i_about_repository.dart';

abstract class AboutState extends Equatable {
  const AboutState();

  @override
  List<Object?> get props => [];
}

class AboutInitial extends AboutState {}

class AboutLoading extends AboutState {}

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
  final IAboutRepository _repository;

  AboutCubit(this._repository) : super(AboutInitial());

  Future<void> loadAboutInfo() async {
    emit(AboutLoading());
    try {
      final info = await _repository.getAboutInfo();
      emit(AboutLoaded(info));
    } catch (e) {
      emit(AboutError(e.toString()));
    }
  }
}
