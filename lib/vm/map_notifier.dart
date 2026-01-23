import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/utils/location_util.dart';

class MapState {
  final LatLng? userLocation;
  final Store? selectedStore;
  final bool isLocating;

  MapState({
    this.userLocation,
    this.selectedStore,
    this.isLocating = false,
  });

  MapState copyWith({
    LatLng? userLocation,
    Store? selectedStore,
    bool? isLocating,
  }) {
    return MapState(
      userLocation: userLocation ?? this.userLocation,
      selectedStore: selectedStore ?? this.selectedStore,
      isLocating: isLocating ?? this.isLocating,
    );
  }
}

class MapNotifier extends Notifier<MapState> {
  @override
  MapState build() {
    return MapState();
  }

  Future<void> fetchUserLocation() async {
    state = state.copyWith(isLocating: true);

    try {
      final pos = await LocationUtil.getCurrentLocation();
      state = state.copyWith(
        userLocation: LatLng(pos.latitude, pos.longitude),
        isLocating: false,
      );
    } catch (e) {
      state = state.copyWith(isLocating: false);
      rethrow;
    }
  }

  void selectStore(Store? store) {
    state = state.copyWith(selectedStore: store);
  }

  void reset() {
    state = MapState();
  }
}

final mapNotifierProvider =
    NotifierProvider<MapNotifier, MapState>(
      MapNotifier.new,
    );
