class Store {
  final int store_seq;
  final String store_address;
  final double store_lat;
  final double store_lng;
  final String store_phone;
  final String? store_open_time;
  final String? store_close_time;
  final String? store_description;
  final String? store_image;
  final String store_placement;
  final DateTime created_at;

  Store({
    required this.store_seq,
    required this.store_address,
    required this.store_lat,
    required this.store_lng,
    required this.store_phone,
    this.store_open_time,
    this.store_close_time,
    this.store_description,
    this.store_image,
    required this.store_placement,
    required this.created_at,
  });

  //LatLng get location => LatLng(storeLat, storeLng);

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      store_seq: json['store_seq'] as int,
      store_address: json['store_address'] ?? "",
      store_lat: (json['store_lat'] as num).toDouble(),
      store_lng: (json['store_lng'] as num).toDouble(),
      store_phone: json['store_phone'] ?? "",
      store_open_time: json['store_opentime'],
      store_close_time: json['store_closetime'],
      store_description: json['store_description'],
      store_image: json['store_image'],
      store_placement: json['store_placement'] ?? "v1",
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_seq': store_seq,
      'store_address': store_address,
      'store_lat': store_lat,
      'store_lng': store_lng,
      'store_phone': store_phone,
      'store_open_time': store_open_time,
      'store_close_time': store_close_time,
      'store_description': store_description,
      'store_image': store_image,
      'store_placement': store_placement,
      'created_at': created_at,
    };
  }
}
