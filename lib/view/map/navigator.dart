import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/drawer.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/map/web_view.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;

  Future<void> _openMapDirections() async {
    final s = widget.store;

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
      key: _scaffoldKey,
      backgroundColor: p.background,
      // drawer: const AppDrawer(),
      drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '매장위치 확인',
          style: mainAppBarTitleStyle.copyWith(
            color: p.textOnPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: p.textOnPrimary,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
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
                      color: p.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    s.store_address ?? "주소 정보 없음",
                    style: TextStyle(
                      color: p.primary,
                      fontSize: 14,
                    ),
                  ),
                  // const spacer(),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _openMapDirections,
                      icon: Icon(Icons.near_me),
                      label: Text("Google 지도로 길찾기"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: p.primary,
                        side: const BorderSide(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NavigationScreen(store: s),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("실시간 경로 추적"),
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
