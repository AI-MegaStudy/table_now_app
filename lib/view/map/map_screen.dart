import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_now_app/vm/map_notifier.dart';

class MapScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(
      appStateProvider.select((s) => s.selectedStore),
    );

    if (store == null) {
      return Scaffold(
        appBar: AppBar(title: Text('지도')),
        body: Center(child: Text('매장을 선택하세요')),
      );
    }

    final markers = <Marker>{
      Marker(
        markerId: MarkerId(store.name),
        position: store.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        ),
      ),
    };

    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('me'),
          position: currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(store.name)),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: store.location,
          zoom: 15,
        ),
        markers: markers,
        myLocationEnabled: true,
      ),
    );
  }
}
