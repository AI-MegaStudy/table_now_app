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
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(
        () => _currentLocation = LatLng(
          position.latitude,
          position.longitude,
        ),
      );
    }
  }

  void _showStoreDetail(BuildContext context, Store store) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent, // 배경 투명 (커스텀 디자인용)
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용만큼만 높이 차지
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
                  Icon(
                    Icons.restaurant,
                    color: Colors.orange,
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildInfoRow(
                Icons.location_on_outlined,
                "서울 강남구 강남대로 지하 396",
              ), // 실제 데이터 연동 필요
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
                  onPressed: () {}, // 예약 로직 추가
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    //  shape: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "이 매장 예약하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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

  @override
  Widget build(BuildContext context) {
    final selectedRegion = ref.watch(
      appStateProvider.select((s) => s.selectedRegion),
    );

    if (selectedRegion == null)
      return Scaffold(
        body: Center(child: Text('지역을 선택해주세요')),
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
        title: Text('${selectedRegion.name} 지점 지도'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selectedRegion.stores.isNotEmpty
              ? selectedRegion.stores.first.location
              : const LatLng(37.56, 126.97),
          zoom: 13,
        ),
        markers: markers,
        myLocationEnabled: true,
      ),
    );
  }
}
