import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_now_app/model/store.dart'; // Store 모델 임포트 확인
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/location_util.dart';

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

  // 실시간 경로 추적 관련 상태
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;
  final List<LatLng> _routePoints = [];
  final Set<Polyline> _polylines = {};

  @override
  void dispose() {
    // 페이지를 나갈 때 위치 구독을 반드시 해제합니다.
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // 경로 추적 토글 (시작/중지)
  Future<void> _toggleTracking() async {
    if (_isTracking) {
      // 추적 중지
      await _positionStream?.cancel();
      setState(() {
        _isTracking = false;
      });
    } else {
      // 추적 시작
      try {
        // 1. 권한 체크 (기존 작성하신 LocationUtil 활용)
        await LocationUtil.getCurrentLocation();

        // 2. 초기화
        setState(() {
          _routePoints.clear();
          _polylines.clear();
          _isTracking = true;
        });

        // 3. 실시간 위치 스트림 구독 시작
        _positionStream =
            Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 5, // 5미터 이동 시마다 호출
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
                      points: List.of(
                        _routePoints,
                      ), // 안정적인 리스트 복사
                      color: Colors.blueAccent,
                      width: 6,
                      jointType: JointType.round,
                      startCap: Cap.roundCap,
                      endCap: Cap.roundCap,
                    ),
                  );
                });

                // 카메라를 사용자 위치로 부드럽게 이동
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
    final store = widget.store; // widget을 통해 store 접근

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "실시간 경로 추적",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: p.primary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
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
                target: LatLng(
                  store.store_lat,
                  store.store_lng,
                ), // 매장 위치를 초기값으로 설정
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
                  //  // store.store_description, // 매장 이름 표시
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: p.primary,
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  Text(
                    _isTracking
                        ? "경로를 실시간으로 기록 중입니다..."
                        : "버튼을 눌러 방문 경로 기록을 시작하세요",
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        style: const TextStyle(
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
