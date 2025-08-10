import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

part 'rental_state.dart';

class RentalCubit extends Cubit<RentalState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  RentalCubit() : super(const RentalState.initial());

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  Future<void> loadRentals() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: RentalStatus.failure, errorMessage: 'Not authenticated'));
      return;
    }

    emit(state.copyWith(status: RentalStatus.loading));

    _sub?.cancel();
    _sub = _db
        .collection('rentals')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final items = snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      emit(state.copyWith(status: RentalStatus.loaded, rentals: items, errorMessage: null));
    }, onError: (e) {
      emit(state.copyWith(status: RentalStatus.failure, errorMessage: e.toString()));
    });
  }

  Future<void> createRental({
    required int movieId,
    required String title,
    String? posterPath,
    required int days,
    double pricePerDay = 5000,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: RentalStatus.failure, errorMessage: 'Not authenticated'));
      return;
    }
    emit(state.copyWith(status: RentalStatus.loading));

    final now = Timestamp.now();
    final end = Timestamp.fromDate(now.toDate().add(Duration(days: days)));
    final data = {
      'userId': user.uid,
      'movieId': movieId,
      'movieTitle': title,
      'posterPath': posterPath,
      'startAt': now,
      'endAt': end,
      'pricePerDay': pricePerDay,
      'days': days,
      'status': 'active',
      'createdAt': now,
    };
    try {
      await _db.collection('rentals').add(data);
      emit(state.copyWith(status: RentalStatus.loaded));
    } catch (e) {
      emit(state.copyWith(status: RentalStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> deleteRental(String rentalId) async {
    try {
      await _db.collection('rentals').doc(rentalId).delete();
    } catch (e) {
      emit(state.copyWith(status: RentalStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> renewRental({
    required String rentalId,
    required int days,
    double? pricePerDay,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: RentalStatus.failure, errorMessage: 'Not authenticated'));
      return;
    }
    try {
      emit(state.copyWith(status: RentalStatus.loading));
      final now = Timestamp.now();
      final end = Timestamp.fromDate(now.toDate().add(Duration(days: days)));
      final data = <String, dynamic>{
        'startAt': now,
        'endAt': end,
        'days': days,
        'status': 'active',
        if (pricePerDay != null) 'pricePerDay': pricePerDay,
      };
      await _db.collection('rentals').doc(rentalId).update(data);
      emit(state.copyWith(status: RentalStatus.loaded));
    } catch (e) {
      emit(state.copyWith(status: RentalStatus.failure, errorMessage: e.toString()));
    }
  }
}
