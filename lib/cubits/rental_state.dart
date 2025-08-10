part of 'rental_cubit.dart';

enum RentalStatus { initial, loading, loaded, failure }

class RentalState extends Equatable {
  final RentalStatus status;
  final String? errorMessage;
  final List<Map<String, dynamic>> rentals;

  const RentalState({required this.status, this.errorMessage, this.rentals = const []});

  const RentalState.initial() : this(status: RentalStatus.initial);

  RentalState copyWith({RentalStatus? status, String? errorMessage, List<Map<String, dynamic>>? rentals}) {
    return RentalState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      rentals: rentals ?? this.rentals,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, rentals];
}
