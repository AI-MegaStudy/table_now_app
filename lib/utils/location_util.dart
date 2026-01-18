import 'package:geolocator/geolocator.dart';

class LocationUtil {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("위치 서비스 비활성화");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("위치 권한 없음");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("위치 영구 거부");
    }

    return Geolocator.getCurrentPosition();
  }
}
