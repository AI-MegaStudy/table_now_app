import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoreRegion {
  final String name;
  final int storeCount;
  final List<Store> stores;

  StoreRegion({
    required this.name,
    required this.storeCount,
    required this.stores,
  });
}

class Store {
  final String name;
  final LatLng location;

  Store({required this.name, required this.location});
}
