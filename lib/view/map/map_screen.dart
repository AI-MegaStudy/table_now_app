import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/utils/location_util.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/map/store_detail_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  final List<Store> storeList;
  const MapScreen({required this.storeList, super.key});

  @override
  ConsumerState<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  LatLng? _userLocation;

  final LatLng _defaultPos = const LatLng(
    37.5665,
    126.9780,
  );
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    debugPrint(' [MapScreen] initState - 위치 가져오기 시작');
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      debugPrint('[MapScreen] _getUserLocation 호출됨');
      final pos = await LocationUtil.getCurrentLocation();
      debugPrint(
        ' [MapScreen] 위치 획득 성공: ${pos.latitude}, ${pos.longitude}',
      );
      if (!mounted) return;

      if (pos.latitude > 1.0 && pos.longitude > 1.0) {
        setState(() {
          _userLocation = LatLng(
            pos.latitude,
            pos.longitude,
          );
        });
        debugPrint(
          ' [MapScreen] _userLocation 설정 완료: $_userLocation',
        );
      }
    } catch (e) {
      debugPrint("위치 획득 실패: $e");
      if (!mounted) return;

      String message = '위치 정보를 가져올 수 없습니다.';

      if (e.toString().contains('비활성화')) {
        message = '위치 서비스를 켜주세요.';
      } else if (e.toString().contains('영구 거부')) {
        message = '설정에서 위치 권한을 허용해주세요.';
      } else if (e.toString().contains('권한 없음')) {
        message = '위치 권한이 필요합니다.';
      }

      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: message,
      );
    }
  }

  void _applyBounds() {
    if (_mapController == null) return;

    final List<LatLng> points = [];

    if (_userLocation != null &&
        _userLocation!.latitude > 1.0) {
      points.add(_userLocation!);
    }

    for (var s in widget.storeList) {
      if (s.store_lat > 1.0 && s.store_lng > 1.0) {
        points.add(LatLng(s.store_lat, s.store_lng));
      }
    }

    if (points.isEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_defaultPos, 14),
      );
      return;
    }

    if (points.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15.5),
      );
    } else {
      final latitudes = points
          .map((p) => p.latitude)
          .toList();
      final longitudes = points
          .map((p) => p.longitude)
          .toList();

      final bounds = LatLngBounds(
        southwest: LatLng(
          latitudes.reduce((a, b) => a < b ? a : b),
          longitudes.reduce((a, b) => a < b ? a : b),
        ),
        northeast: LatLng(
          latitudes.reduce((a, b) => a > b ? a : b),
          longitudes.reduce((a, b) => a > b ? a : b),
        ),
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: p.background,
      drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '지역 매장 지도',
          style: mainAppBarTitleStyle.copyWith(
            color: p.textOnPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: _isLocating
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: p.textOnPrimary,
                    ),
                  )
                : Icon(
                    Icons.refresh_rounded,
                    color: p.textOnPrimary,
                  ),
            onPressed: _isLocating
                ? null
                : () async {
                    setState(() => _isLocating = true);

                    try {
                      await _getUserLocation();
                      if (mounted) _applyBounds();

                      if (mounted) {
                        CustomCommonUtil.showSuccessSnackbar(
                          context: context,
                          title: "매장 위치 로드",
                          message: "주변 매장 위치로 화면을 맞춥니다.",
                        );
                      }
                    } finally {
                      if (mounted)
                        setState(() => _isLocating = false);
                    }
                  },
          ),

          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: p.textOnPrimary,
            ),
            onPressed: () =>
                _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _defaultPos,
          zoom: 12,
        ),
        markers: _buildMarkers(),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: (controller) {
          _mapController = controller;

          Future.delayed(
            const Duration(milliseconds: 600),
            () {
              if (mounted) _applyBounds();
            },
          );
        },
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("user_loc"),
          position: _userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }
    for (var s in widget.storeList) {
      if (s.store_lat > 1.0 && s.store_lng > 1.0) {
        markers.add(
          Marker(
            markerId: MarkerId(s.store_seq.toString()),
            position: LatLng(s.store_lat, s.store_lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            onTap: () => _showDetailSheet(s),
          ),
        );
      }
    }
    return markers;
  }

  Future<void> _showDetailSheet(Store s) async {
    String? distanceString;
    debugPrint(
      ' [MapScreen] _userLocation: $_userLocation',
    );

    if (_userLocation == null) {
      debugPrint(' [MapScreen] 위치가 null이므로 다시 가져오기 시도');
      try {
        final pos = await LocationUtil.getCurrentLocation();
        if (mounted &&
            pos.latitude > 1.0 &&
            pos.longitude > 1.0) {
          setState(() {
            _userLocation = LatLng(
              pos.latitude,
              pos.longitude,
            );
          });
          debugPrint(
            '[MapScreen] 위치 재획득 성공: $_userLocation',
          );
        }
      } catch (e) {
        debugPrint('[MapScreen] 위치 재획득 실패: $e');
      }
    }

    if (_userLocation != null) {
      double meters = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        s.store_lat,
        s.store_lng,
      );
      distanceString = meters >= 1000
          ? "${(meters / 1000).toStringAsFixed(1)}km"
          : "${meters.toInt()}m";
      debugPrint(
        ' [MapScreen] 거리 계산: $meters m -> $distanceString',
      );
    } else {
      debugPrint('[MapScreen] 위치를 가져올 수 없어 거리 계산 안함');
    }

    debugPrint(
      ' [MapScreen] StoreDetailSheet에 전달: distance=$distanceString',
    );
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) =>
          StoreDetailSheet(s, distance: distanceString),
    );
  }
}
