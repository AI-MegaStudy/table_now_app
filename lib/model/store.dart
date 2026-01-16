class Store {
  final int store_seq;
  final String store_address;
  final double store_lat;
  final double store_lng;
  final String store_phone;
  final String? store_opentime;
  final String? store_closetime;
  final String? store_description;
  final String? store_image;
  final String store_placement;
  final String created_at;

  Store({
    required this.store_seq,
    required this.store_address,
    required this.store_lat,
    required this.store_lng,
    required this.store_phone,
    this.store_opentime,
    this.store_closetime,
    this.store_description,
    this.store_image,
    required this.store_placement,
    required this.created_at,
  });

  /// JSON 데이터에서 객체 생성
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      store_seq: json['store_seq'] ?? 0,
      store_address: json['store_address'] ?? '',
      store_lat: (json['store_lat'] ?? 0).toDouble(),
      store_lng: (json['store_lng'] ?? 0).toDouble(),
      store_phone: json['store_phone'] ?? '',
      store_opentime: json['store_opentime'],
      store_closetime: json['store_closetime'],
      store_description: json['store_description'],
      store_image: json['store_image'],
      store_placement: json['store_placement'] ?? '',
      created_at: json['created_at'] ?? '',
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'store_seq': store_seq,
      'store_address': store_address,
      'store_lat': store_lat,
      'store_lng': store_lng,
      'store_phone': store_phone,
      'store_opentime': store_opentime,
      'store_closetime': store_closetime,
      'store_description': store_description,
      'store_image': store_image,
      'store_placement': store_placement,
      'created_at': created_at,
    };
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 유다원
// 설명: Store 모델 클래스
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 유다원: 최초 생성
