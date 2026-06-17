import 'package:equatable/equatable.dart';
import '../domain/entities/allergy.dart';

abstract class AllergiesState extends Equatable {
  const AllergiesState();

  @override
  List<Object?> get props => [];
}

class AllergiesInitial extends AllergiesState {
  const AllergiesInitial();
}

class AllergiesLoading extends AllergiesState {
  const AllergiesLoading();
}

class AllergiesLoaded extends AllergiesState {
  final List<Allergy> allergies;

  const AllergiesLoaded(this.allergies);

  @override
  List<Object?> get props => [allergies];
}

class AllergiesError extends AllergiesState {
  final String message;

  const AllergiesError(this.message);

  @override
  List<Object?> get props => [message];
}
