import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'rental_state.dart';

class RentalCubit extends Cubit<RentalState> {
  RentalCubit() : super(const RentalState.initial());

  Future<void> loadRentals() async {
    emit(state.copyWith(status: RentalStatus.loading));
    await Future.delayed(const Duration(milliseconds: 800));
    emit(state.copyWith(status: RentalStatus.loaded));
  }

  Future<void> createRental() async {
    emit(state.copyWith(status: RentalStatus.loading));
    await Future.delayed(const Duration(milliseconds: 800));
    emit(state.copyWith(status: RentalStatus.loaded));
  }
}
