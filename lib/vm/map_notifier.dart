import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 1. 매장 모델
class Store {
  final String name;
  final LatLng location;

  Store({required this.name, required this.location});
}

// 2. 지역 모델
class Region {
  final String name;
  final List<Store> stores;

  Region({required this.name, required this.stores});
}

// 3. 앱 상태 모델 (불변성 유지)
class AppState {
  final List<Region> regions;
  final Region? selectedRegion; // 추가: 현재 선택된 지역
  final Store? selectedStore; // 현재 선택된 매장

  AppState({
    required this.regions,
    this.selectedRegion,
    this.selectedStore,
  });

  AppState copyWith({
    List<Region>? regions,
    Region? selectedRegion,
    Store? selectedStore,
  }) {
    return AppState(
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      selectedStore: selectedStore ?? this.selectedStore,
    );
  }
}

// 4. Notifier (StateNotifier보다 현대적인 방식)
class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    // 초기 데이터 설정
    return AppState(
      regions: [
        Region(
          name: '서울',
          stores: [
            Store(
              name: '강남점',
              location: const LatLng(37.498, 127.027),
            ),
            Store(
              name: '홍대점',
              location: const LatLng(37.556, 126.923),
            ),
          ],
        ),
        Region(
          name: '부산',
          stores: [
            Store(
              name: '해운대점',
              location: const LatLng(35.159, 129.163),
            ),
            Store(
              name: '서면점',
              location: const LatLng(35.155, 129.059),
            ),
          ],
        ),
      ],
    );
  }

  // 지역 선택 (데이터를 필터링하는 대신 선택된 포인터만 변경)
  void selectRegion(Region region) {
    state = state.copyWith(
      selectedRegion: region,
      selectedStore: null, // 지역이 바뀌면 선택된 매장 초기화
    );
  }

  // 매장 선택
  void selectStore(Store store) {
    state = state.copyWith(selectedStore: store);
  }
}

// 5. Provider 설정
final appStateProvider =
    NotifierProvider<AppStateNotifier, AppState>(() {
      return AppStateNotifier();
    });
