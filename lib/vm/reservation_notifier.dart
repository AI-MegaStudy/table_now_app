import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

class Reservation {
  final String reservationNumber;
  final String storeName;
  final DateTime dateTime;

  Reservation({
    required this.reservationNumber,
    required this.storeName,
    required this.dateTime,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservationNumber: json['reservation_number'],
      storeName: json['store_name'],
      dateTime: DateTime.parse(json['date_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservation_number': reservationNumber,
      'store_name': storeName,
      'date_time': dateTime.toIso8601String(),
    };
  }
}

class ReservationState {
  final Reservation? reservation;
  final bool isLoading;
  final String? errorMessage;

  ReservationState({
    this.reservation,
    this.isLoading = false,
    this.errorMessage,
  });

  ReservationState copyWith({
    Reservation? reservation,
    bool? isLoading,
    String? errorMessage,
    bool removeReservation = false,
    bool removeErrorMessage = false,
  }) {
    return ReservationState(
      reservation:
          removeReservation ? null : (reservation ?? this.reservation),
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          removeErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ReservationNotifier extends Notifier<ReservationState> {
  final GetStorage _storage = GetStorage();
  static const String _storageKey = 'reservation';

  @override
  ReservationState build() {
    try {
      final data = _storage.read<Map<String, dynamic>>(_storageKey);
      if (data != null) {
        return ReservationState(
          reservation: Reservation.fromJson(data),
        );
      }
      return ReservationState();
    } catch (e) {
      return ReservationState();
    }
  }

  Future<void> setReservation(Reservation reservation) async {
    try {
      state = state.copyWith(isLoading: true);
      await _storage.write(_storageKey, reservation.toJson());
      state = state.copyWith(
        reservation: reservation,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '예약 정보 저장 실패',
      );
    }
  }

  void clear() {
    _storage.remove(_storageKey);
    state = state.copyWith(
      removeReservation: true,
      removeErrorMessage: true,
    );
  }
}

final reservationNotifierProvider =
    NotifierProvider<ReservationNotifier, ReservationState>(
  ReservationNotifier.new,
);
