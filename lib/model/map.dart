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

  factory StoreRegion.fromJson(Map<String, dynamic> json) {
    return StoreRegion(
      name: json['name'] ?? "",
      storeCount: json['storeCount'] ?? "",
      stores: json['stores'] ?? "",
    );
  }
  Map<String, dynamic> toJSON() {
    return {
      'name': name,
      'storeCount': storeCount,
      'stores': stores,
    };
  }
}

class Store {
  final String description;
  final LatLng location;

  Store({
    required this.description,
    required this.location,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      description: json['description'],
      location: json['location'],
    );
  }
}
