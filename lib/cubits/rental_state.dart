part of 'rental_cubit.dart';

enum RentalStatus { initial, loading, loaded, failure }

class RentalState extends Equatable {
  final RentalStatus status;
  final String? errorMessage;

  const RentalState({required this.status, this.errorMessage});

  const RentalState.initial() : this(status: RentalStatus.initial);

  RentalState copyWith({RentalStatus? status, String? errorMessage}) {
    return RentalState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
