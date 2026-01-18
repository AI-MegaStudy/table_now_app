import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/vm/store_notifire.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;

  // 지도가 생성된 후 모든 매장이 보이도록 카메라 조정
  void _onMapCreated(GoogleMapController controller, List<Store> stores) {
    _mapController = controller;
    if (stores.isNotEmpty) {
      // 렌더링이 완료된 후 카메라를 이동시키기 위해 약간의 지연을 줍니다.
      Future.delayed(const Duration(milliseconds: 400), () {
        _fitToScreen(stores);
      });
    }
  }

  // 모든 매장 마커가 화면 안에 들어오게 영역을 계산하여 이동
  void _fitToScreen(List<Store> stores) {
    if (_mapController == null || stores.isEmpty) return;

    // 한국 좌표(위도 33~39, 경도 124~132)를 벗어난 데이터는 제외 (태평양 방지)
    final validStores = stores
        .where((s) => s.store_lat > 30 && s.store_lng > 120)
        .toList();
    if (validStores.isEmpty) return;

    double minLat = validStores.first.store_lat;
    double maxLat = validStores.first.store_lat;
    double minLng = validStores.first.store_lng;
    double maxLng = validStores.first.store_lng;

    for (var s in validStores) {
      if (s.store_lat < minLat) minLat = s.store_lat;
      if (s.store_lat > maxLat) maxLat = s.store_lat;
      if (s.store_lng < minLng) minLng = s.store_lng;
      if (s.store_lng > maxLng) maxLng = s.store_lng;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80.0, // 화면 가장자리 여백
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. ViewModel 감시 (AsyncNotifier 방식)
    final asyncStore = ref.watch(storeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('매장 지도'), elevation: 0),
      body: asyncStore.when(
        // [A] 데이터 로드 완료
        data: (storeList) {
          // if (regions.isEmpty ||
          //     regions[0].stores.isEmpty) {
          //   return const Center(
          //     child: Text("표시할 매장 데이터가 없습니다."),
          //   );
          // }

          //final stores = storeList[0].store_description;

          // 2. 마커 세트 생성
          final Set<Marker> markers = storeList.map((store) {
            return Marker(
              markerId: MarkerId(store.store_seq.toString()),
              position: LatLng(store.store_lat, store.store_lng),
              onTap: () => _showStoreDetail(context, store),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
              infoWindow: InfoWindow(title: store.store_description),
            );
          }).toSet();

          // 3. 구글 맵 렌더링
          return GoogleMap(
            onMapCreated: (controller) => _onMapCreated(controller, storeList),
            initialCameraPosition: CameraPosition(
              // 데이터가 있을 때 첫 번째 매장 위치를 초기값으로 설정
              target: LatLng(storeList[0].store_lat, storeList[0].store_lng),
              zoom: 14.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          );
        },
        // [B] 로딩 중
        loading: () => Center(child: CircularProgressIndicator()),
        // [C] 에러 발생
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text("데이터 로드 실패: $err"),
              ElevatedButton(
                onPressed: () => ref.refresh(storeNotifierProvider),
                child: Text("다시 시도"),
              ),
            ],
          ),
        ),
      ),
      // 현재 모든 매장을 다시 한 화면에 모아보는 플로팅 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          asyncStore.whenData((stores) => _fitToScreen(stores));
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.center_focus_strong),
      ),
    );
  }

  // 매장 상세 정보 바텀 시트
  void _showStoreDetail(BuildContext context, Store store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    store.store_description ?? "식당 이름 없음",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.restaurant, color: Colors.orange),
              ],
            ),
            SizedBox(height: 15),
            _buildInfoRow(Icons.location_on_outlined, store.store_address),
            _buildInfoRow(Icons.phone_outlined, store.store_phone),
            _buildInfoRow(
              Icons.access_time_outlined,
              "${store.store_open_time ?? '09:00'} - ${store.store_close_time ?? '22:00'}",
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 예약 페이지 이동 등 추가 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "예약하기",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
