import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_now_app/utils/location_util.dart';
import 'package:table_now_app/view/map/store_detail_sheet.dart';
import 'package:table_now_app/view/map/storebooking.dart';
import '../../../model/store.dart';

class MapScreen extends ConsumerStatefulWidget {
  final List<Store> storeList;

  const MapScreen({required this.storeList, super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  bool _boundsApplied = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final pos = await LocationUtil.getCurrentLocation();
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      debugPrint("위치 권한/위치 정보 접근 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeList = widget.storeList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("지역 매장 지도"),
        backgroundColor: Colors.amberAccent,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.5665, 126.9780), // 기본은 서울
          zoom: 12,
        ),
        markers: _buildMarkers(storeList),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;

          // 지도 렌더 후 bounds 적용
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(milliseconds: 300));
            _applyBounds(storeList);
          });
        },
      ),
    );
  }

  Set<Marker> _buildMarkers(List<Store> storeList) {
    final markers = <Marker>{};

    // 내 위치 마커
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

    // 매장 마커
    for (var s in storeList) {
      // 유효한 좌표만 표시
      if (s.store_lat != 0 && s.store_lng != 0) {
        markers.add(
          Marker(
            markerId: MarkerId(s.store_seq.toString()),
            position: LatLng(s.store_lat, s.store_lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (_) => StoreDetailSheet(s),
            ),
          ),
        );
      }
    }

    return markers;
  }

  void _applyBounds(List<Store> storeList) async {
    if (_mapController == null || _boundsApplied) return;

    final points = <LatLng>[];

    if (_userLocation != null) {
      points.add(_userLocation!);
    }

    for (var s in storeList) {
      if (s.store_lat != 0 && s.store_lng != 0) {
        points.add(LatLng(s.store_lat, s.store_lng));
      }
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      _boundsApplied = true;
      return;
    }

    final latitudes = points.map((e) => e.latitude).toList();
    final longitudes = points.map((e) => e.longitude).toList();

    double minLat = latitudes.reduce((a, b) => a < b ? a : b);
    double maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    double minLng = longitudes.reduce((a, b) => a < b ? a : b);
    double maxLng = longitudes.reduce((a, b) => a > b ? a : b);

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    _boundsApplied = true;
  }
}
