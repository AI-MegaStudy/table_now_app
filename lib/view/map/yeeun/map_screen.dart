import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/map/store_detail_sheet.dart';
import 'package:table_now_app/vm/map_notifier.dart';

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

  final LatLng _defaultPos = const LatLng(
    37.5665,
    126.9780,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocation();
    });
  }

  Future<void> _requestLocation() async {
    try {
      await ref
          .read(mapNotifierProvider.notifier)
          .fetchUserLocation();

      if (!mounted) return;
      _applyBounds();
    } catch (e) {
      if (!mounted) return;
      // CustomCommonUtil.showErrorSnackbar(
      //   context: context,
      //   message: "위치 정보를 가져올 수 없습니다.",
      // );
    }
  }

  void _applyBounds() {
    if (_mapController == null) return;

    final userLoc = ref
        .read(mapNotifierProvider)
        .userLocation;
    final List<LatLng> points = [];

    if (userLoc != null) points.add(userLoc);

    for (var s in widget.storeList) {
      if (s.store_lat != 0.0 && s.store_lng != 0.0) {
        points.add(LatLng(s.store_lat, s.store_lng));
      }
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15.5),
      );
    } else {
      final bounds = _calculateBounds(points);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    final lats = points.map((p) => p.latitude).toList();
    final lngs = points.map((p) => p.longitude).toList();
    return LatLngBounds(
      southwest: LatLng(
        lats.reduce((a, b) => a < b ? a : b),
        lngs.reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        lats.reduce((a, b) => a > b ? a : b),
        lngs.reduce((a, b) => a > b ? a : b),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final mapState = ref.watch(mapNotifierProvider);

    return Scaffold(
      key: _scaffoldKey,
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
            icon: mapState.isLocating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: p.textOnPrimary,
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: p.textOnPrimary,
                  ),
            onPressed: mapState.isLocating
                ? null
                : _requestLocation,
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

        markers: _buildMarkers(mapState.userLocation),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: (controller) {
          _mapController = controller;

          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              if (mounted) _applyBounds();
            },
          );
        },
      ),
    );
  }

  Set<Marker> _buildMarkers(LatLng? userLoc) {
    return widget.storeList.map((s) {
      return Marker(
        markerId: MarkerId(s.store_seq.toString()),
        position: LatLng(s.store_lat, s.store_lng),
        onTap: () => _showDetailSheet(s, userLoc),
      );
    }).toSet();
  }

  void _showDetailSheet(Store s, LatLng? userLoc) {
    String? distanceString;
    if (userLoc != null) {
      distanceString = CustomCommonUtil.calculateDistance(
        userLoc,
        LatLng(s.store_lat, s.store_lng),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          StoreDetailSheet(s, distance: distanceString),
    );
  }
}

class CustomCommonUtil {
  static String calculateDistance(
    LatLng start,
    LatLng end,
  ) {
    double distanceInMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    if (distanceInMeters < 1000) {
      return "${distanceInMeters.toStringAsFixed(0)}m";
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return "${distanceInKm.toStringAsFixed(1)}km";
    }
  }
}
