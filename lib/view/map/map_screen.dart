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
      GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  LatLng? _userLocation;

  final LatLng _defaultPos = const LatLng(
    37.5665,
    126.9780,
  );
  final bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final pos = await LocationUtil.getCurrentLocation();
      if (!mounted) return;

      if (pos.latitude > 1.0 && pos.longitude > 1.0) {
        setState(() {
          _userLocation = LatLng(
            pos.latitude,
            pos.longitude,
          );
        });
      }
    } catch (e) {
      debugPrint("위치 획득 실패: $e");
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
            icon: Icon(
              Icons.account_circle,
              color: p.textOnPrimary,
            ),
            onPressed: () =>
                _scaffoldKey.currentState?.openDrawer(),
          ),

          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: p.textOnPrimary,
            ),
            onPressed: () async {
              await _getUserLocation();

              if (mounted) _applyBounds();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("주변 매장 위치로 화면을 맞춥니다."),
                  duration: Duration(seconds: 1),
                ),
              );
            },
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
      /* floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _getUserLocation();

          if (mounted) _applyBounds();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("주변 매장 위치로 화면을 맞춥니다."),
              duration: Duration(seconds: 1),
            ),
          );
        },

        backgroundColor: p.primary,
        child: Icon(Icons.my_location, color: Colors.white),
      ),*/
    );
  }

  /* CustomCommonUtil.showSuccessSnackbar(
              context: context,
              title: '로그인 성공',
              message: '$customerName님, 환영합니다!',
            ); */

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
