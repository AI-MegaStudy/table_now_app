import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// 현재 위치 정보를 담는 모델 클래스
class CurrentLocation {
  /// 위도
  final double latitude;

  /// 경도
  final double longitude;

  /// 위치 정보가 로드되었는지 여부
  final bool isLoaded;

  CurrentLocation({
    required this.latitude,
    required this.longitude,
    required this.isLoaded,
  });

  /// 초기값 (위치 정보 없음)
  factory CurrentLocation.initial() {
    return CurrentLocation(
      latitude: 0.0,
      longitude: 0.0,
      isLoaded: false,
    );
  }
}

/// 현재 위치를 관리하는 Notifier 클래스
/// 위치 권한 요청 및 현재 위치 가져오기 기능 제공
class LocationNotifier extends Notifier<CurrentLocation> {
  @override
  CurrentLocation build() {
    return CurrentLocation.initial();
  }

  /// 위치 권한이 허용되어 있는지 확인
  /// 이미 권한이 허용된 경우 재요청하지 않음
  Future<bool> _checkLocationPermission() async {
    // 위치 서비스가 활성화되어 있는지 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화된 경우 예외 발생 (자동으로 설정 앱을 열지 않음)
      throw Exception('위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 활성화해주세요.');
    }

    // 위치 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();
    
    // 권한이 이미 허용된 경우 (whileInUse 또는 always) - 재요청하지 않음
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }
    
    // 권한이 영구적으로 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      // 설정 앱으로 이동할 수 있도록 안내
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.');
    }

    // 권한이 거부된 경우에만 요청
    if (permission == LocationPermission.denied) {
      // 권한 요청
      permission = await Geolocator.requestPermission();
      
      // 여전히 거부된 경우
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.');
      }
      
      // 영구적으로 거부된 경우
      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.');
      }
    }

    // 권한이 허용된 경우
    return true;
  }

  /// 현재 위치 가져오기
  /// 이미 위치가 로드된 경우 재요청하지 않음
  Future<void> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      // 이미 위치가 로드되었고 강제 새로고침이 아닌 경우 스킵
      if (!forceRefresh && state.isLoaded) {
        return;
      }

      // 위치 권한 확인
      await _checkLocationPermission();

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 상태 업데이트
      state = CurrentLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        isLoaded: true,
      );
    } catch (e) {
      // 에러 발생 시 상태 초기화
      state = CurrentLocation.initial();
      rethrow;
    }
  }

  /// 위치 정보 초기화
  void resetLocation() {
    state = CurrentLocation.initial();
  }
}

/// LocationNotifier를 제공하는 Provider
final locationProvider =
    NotifierProvider<LocationNotifier, CurrentLocation>(
  LocationNotifier.new,
);
