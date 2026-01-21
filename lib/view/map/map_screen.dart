import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
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
      GlobalKey<ScaffoldState>(); //
  GoogleMapController? _mapController;

  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final pos = await LocationUtil.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
      });

      _moveToCenter();
    } catch (e) {
      debugPrint("위치 획득 실패: $e");
      _moveToCenter();
    }
  }

  void _moveToCenter() {
    if (_mapController == null) return;

    List<LatLng> points = [];

    if (_userLocation != null) {
      points.add(_userLocation!);
    }

    for (var s in widget.storeList) {
      if (s.store_lat != 0 && s.store_lng != 0) {
        points.add(LatLng(s.store_lat, s.store_lng));
      }
    }

    if (points.isEmpty) return;

    double avgLat =
        points
            .map((p) => p.latitude)
            .reduce((a, b) => a + b) /
        points.length;
    double avgLng =
        points
            .map((p) => p.longitude)
            .reduce((a, b) => a + b) /
        points.length;

    LatLng center = LatLng(avgLat, avgLng);

    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(center, 14.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      key: _scaffoldKey, //<<<<< 스캐폴드 키 지정
      backgroundColor: p.background,
      // drawer: const AppDrawer(),
      drawer: const ProfileDrawer(), //<<<<< 프로필 드로워 세팅
      appBar: CommonAppBar(
        title: Text(
          '지역 매장 지도',
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
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.5665, 126.9780),
          zoom: 12,
        ),
        markers: _buildMarkers(),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: (controller) {
          _mapController = controller;

          Future.delayed(
            const Duration(milliseconds: 500),
            () => _moveToCenter(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _getUserLocation();
          _moveToCenter();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("중심 위치로 이동했습니다."),
              duration: Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: p.primary,
        child: Icon(Icons.my_location, color: Colors.white),
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
      if (s.store_lat != 0 && s.store_lng != 0) {
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

  void _showDetailSheet(Store s) {
    String? distanceString;
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
    }
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
