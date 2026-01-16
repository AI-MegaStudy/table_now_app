import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_now_app/vm/map_notifier.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    // 비동기 함수지만 await 없이 호출하여 메인 렌더링을 방해하지 않게 합니다.
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      // 권한 체크 로직 추가 (안정성)
      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position =
          await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(
          () => _currentLocation = LatLng(
            position.latitude,
            position.longitude,
          ),
        );
      }
    } catch (e) {
      debugPrint("위치 획득 실패: $e");
    }
  }

  // 매장 리스트의 중심 좌표를 계산하는 로직
  LatLng _calculateCenter(List<Store> stores) {
    if (stores.isEmpty)
      return const LatLng(37.56, 126.97); // 기본 서울시청

    double lat = 0;
    double lng = 0;
    for (var store in stores) {
      lat += store.location.latitude;
      lng += store.location.longitude;
    }
    return LatLng(lat / stores.length, lng / stores.length);
  }

  @override
  Widget build(BuildContext context) {
    final selectedRegion = ref.watch(
      appStateProvider.select((s) => s.selectedRegion),
    );

    if (selectedRegion == null)
      return const Scaffold(
        body: Center(child: Text('지역 선택 필요')),
      );

    final Set<Marker> markers = selectedRegion.stores.map((
      store,
    ) {
      return Marker(
        markerId: MarkerId(store.name),
        position: store.location,
        // [중요] 핀을 눌렀을 때 팝업 실행
        onTap: () => _showStoreDetail(context, store),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        ),
      );
    }).toSet();

    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('me'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedRegion.name} 지도'),
      ),
      body: GoogleMap(
        // [수정] 첫 번째 매장이 아닌 전체 매장의 중앙으로 초기 위치 설정
        initialCameraPosition: CameraPosition(
          target: _calculateCenter(selectedRegion.stores),
          zoom: 12.0, // 여러 지점이 보이도록 줌을 살짝 낮춤
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  void _showStoreDetail(BuildContext context, Store store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, //<<<<,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.restaurant,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                Icons.location_on_outlined,
                "매장 주소 데이터 필요",
              ),
              _buildInfoRow(
                Icons.phone_outlined,
                "02-1234-5678",
              ),
              _buildInfoRow(
                Icons.access_time_outlined,
                "11:00 - 22:00",
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {}, // 예약 화면 이동 로직
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    "이 매장 예약하기",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
