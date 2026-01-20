import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/store.dart'; // Store 모델 임포트 확인
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/utils/location_util.dart';
import 'package:table_now_app/view/drawer/drawer.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  final Store store;
  const NavigationScreen({required this.store, super.key});

  @override
  ConsumerState<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState
    extends ConsumerState<NavigationScreen> {
  GoogleMapController? _mapController;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); //

  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;
  final List<LatLng> _routePoints = [];
  final Set<Polyline> _polylines = {};

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await _positionStream?.cancel();
      setState(() {
        _isTracking = false;
      });
    } else {
      try {
        await LocationUtil.getCurrentLocation();

        setState(() {
          _routePoints.clear();
          _polylines.clear();
          _isTracking = true;
        });

        _positionStream =
            Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 5,
              ),
            ).listen((Position position) {
              final newPos = LatLng(
                position.latitude,
                position.longitude,
              );

              if (mounted) {
                setState(() {
                  _routePoints.add(newPos);
                  _polylines.add(
                    Polyline(
                      polylineId: const PolylineId(
                        "user_route",
                      ),
                      points: List.of(_routePoints),
                      color: Colors.blueAccent,
                      width: 6,
                      jointType: JointType.round,
                      startCap: Cap.roundCap,
                      endCap: Cap.roundCap,
                    ),
                  );
                });

                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(newPos),
                );
              }
            });
      } catch (e) {
        debugPrint("위치 추적 시작 실패: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("위치 정보를 가져올 수 없습니다: $e"),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final store = widget.store;

    return Scaffold(
      key: _scaffoldKey, //<<<<< 스캐폴드 키 지정
      backgroundColor: p.background,
      drawer: const AppDrawer(), //<<<<< 프로필 드로워 세팅
      // drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '실시간 경로 추적',
          style: mainAppBarTitleStyle.copyWith(
            color: p.textPrimary,
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
                target: LatLng(
                  store.store_lat,
                  store.store_lng,
                ),
                zoom: 16,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
              markers: {
                Marker(
                  markerId: MarkerId(
                    store.store_seq.toString(),
                  ),
                  position: LatLng(
                    store.store_lat,
                    store.store_lng,
                  ),
                  infoWindow: InfoWindow(
                    title: store.store_description,
                  ),
                  icon:
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange,
                      ),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: p.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //    store.store_description, // 매장 이름 표시
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: p.primary,
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  Text(
                    _isTracking
                        ? "경로를 실시간으로 기록 중입니다..."
                        : "버튼을 눌러 방문 경로 기록을 시작하세요",
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 220,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _toggleTracking,
                      icon: Icon(
                        _isTracking
                            ? Icons.stop_circle
                            : Icons.play_circle_filled,
                      ),
                      label: Text(
                        _isTracking ? '기록 중지' : '기록 시작',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTracking
                            ? Colors.redAccent
                            : Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
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
