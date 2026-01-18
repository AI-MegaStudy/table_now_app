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
  bool _boundsSet = false;

  @override
  Widget build(BuildContext context) {
    final asyncStore = ref.watch(storeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('매장 지도'), elevation: 0),
      body: asyncStore.when(
        data: (storeList) {
          final markers = storeList.map((store) {
            return Marker(
              markerId: MarkerId(store.store_seq.toString()),
              position: LatLng(store.store_lat, store.store_lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
              onTap: () => _showStoreDetail(context, store),
            );
          }).toSet();

          return GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;

              // layout 이후에 bounds 적용
              if (!_boundsSet) {
                _boundsSet = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _fitBounds(storeList);
                });
              }
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.5665, 126.9780),
              zoom: 12,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
        error: (err, stack) => Center(child: Text("데이터 로드 실패: $err")),
      ),
    );
  }

  void _fitBounds(List<Store> stores) async {
    if (_mapController == null || stores.isEmpty) return;

    final positions = stores
        .map((s) => LatLng(s.store_lat, s.store_lng))
        .toList();

    // 만약 한 개만 있을 때
    if (positions.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: positions.first, zoom: 15),
        ),
      );
      return;
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  void _showStoreDetail(BuildContext context, Store store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    store.store_description ?? "식당 이름 없음",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.restaurant, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoRow(
              Icons.location_on_outlined,
              store.store_address ?? '주소 없음',
            ),
            _buildInfoRow(Icons.phone_outlined, store.store_phone ?? '전화 없음'),
            _buildInfoRow(
              Icons.access_time_outlined,
              "${store.store_open_time ?? ''} - ${store.store_close_time ?? ''}",
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
