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
  Marker? _selectedMarker; // 선택된 마커 저장

  void _onMapCreated(GoogleMapController controller, List<Store> stores) {
    _mapController = controller;
    if (stores.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 400), () {
        _fitToScreen(stores);
      });
    }
  }

  void _fitToScreen(List<Store> stores) {
    if (_mapController == null || stores.isEmpty) return;

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
        80.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncStore = ref.watch(storeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('매장 지도'), elevation: 0),
      body: asyncStore.when(
        data: (storeList) {
          // 마커 생성
          final Set<Marker> markers = storeList.map((store) {
            return Marker(
              markerId: MarkerId(store.store_seq.toString()),
              position: LatLng(store.store_lat, store.store_lng),
              onTap: () {
                setState(() {
                  _selectedMarker = Marker(
                    markerId: MarkerId(store.store_seq.toString()),
                    position: LatLng(store.store_lat, store.store_lng),
                  );
                });
                _showStoreDetail(context, store);
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
              infoWindow: InfoWindow(title: store.store_description),
            );
          }).toSet();

          return GoogleMap(
            onMapCreated: (controller) => _onMapCreated(controller, storeList),
            initialCameraPosition: CameraPosition(
              target: LatLng(storeList[0].store_lat, storeList[0].store_lng),
              zoom: 14.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          asyncStore.whenData((stores) => _fitToScreen(stores));
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.center_focus_strong),
      ),
    );
  }

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
            _buildInfoRow(
              Icons.location_on_outlined,
              store.store_address ?? '',
            ),
            _buildInfoRow(Icons.phone_outlined, store.store_phone ?? ''),
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
                  // 예약 페이지 이동 로직 추가 가능
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
