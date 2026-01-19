import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:url_launcher/url_launcher.dart'; // 길찾기 외부 앱 호출용
import 'package:table_now_app/model/store.dart';

class NavigatorScreen extends ConsumerStatefulWidget {
  final Store store;
  const NavigatorScreen({required this.store, super.key});

  @override
  ConsumerState<NavigatorScreen> createState() =>
      _BookingLocationScreenState();
}

class _BookingLocationScreenState
    extends ConsumerState<NavigatorScreen> {
  GoogleMapController? _mapController;

  // 길찾기 외부 앱 호출 함수
  Future<void> _openMapDirections() async {
    final s = widget.store;
    // Google Maps 길찾기 URL (웹/앱 공용)
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${s.store_lat},${s.store_lng}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint("지도를 열 수 없습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = widget.store;
    final storeLocation = LatLng(s.store_lat, s.store_lng);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "매장 위치 확인",
          style: TextStyle(
            // color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: storeLocation,
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(
                    s.store_seq.toString(),
                  ),
                  position: storeLocation,
                  infoWindow: InfoWindow(
                    title: s.store_description,
                  ),
                ),
              },
              onMapCreated: (controller) =>
                  _mapController = controller,
              myLocationEnabled: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    s.store_description ?? "매장 정보",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    s.store_address ?? "주소 정보 없음",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  // const spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _openMapDirections,
                      icon: Icon(Icons.near_me),
                      label: Text("Google 지도로 길찾기"),
                      style: OutlinedButton.styleFrom(
                        //    foregroundColor: Colors.blue,
                        //foregroundColor: Colors.orange,
                        foregroundColor: p.primary,
                        side: const BorderSide(
                          //color: Colors.blue,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        //
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("위치 확인 및 다음 단계"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
ConsumerStatefulWidget
동적제어 & ref객체
공통 팔레트 구글맵
 */
