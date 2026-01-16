/// Store 모델 클래스
///
/// 식당(매장) 정보를 담는 모델입니다.
/// API 응답을 파싱하여 사용합니다.
class Store {
  final int storeSeq;
  final String storeAddress;
  final double storeLat;
  final double storeLng;
  final String storePhone;
  final String? storeOpentime;
  final String? storeClosetime;
  final String? storeDescription;
  final String? storeImage;
  final String storePlacement;
  final DateTime? createdAt;

  Store({
    required this.storeSeq,
    required this.storeAddress,
    required this.storeLat,
    required this.storeLng,
    required this.storePhone,
    this.storeOpentime,
    this.storeClosetime,
    this.storeDescription,
    this.storeImage,
    required this.storePlacement,
    this.createdAt,
  });

  /// JSON에서 Store 객체 생성
  factory Store.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    if (json['created_at'] != null) {
      if (json['created_at'] is String) {
        try {
          createdAt = DateTime.parse(json['created_at']);
        } catch (e) {
          createdAt = null;
        }
      }
    }

    return Store(
      storeSeq: json['store_seq'] as int,
      storeAddress: json['store_address'] as String,
      storeLat: (json['store_lat'] as num).toDouble(),
      storeLng: (json['store_lng'] as num).toDouble(),
      storePhone: json['store_phone'] as String,
      storeOpentime: json['store_opentime'] as String?,
      storeClosetime: json['store_closetime'] as String?,
      storeDescription: json['store_description'] as String?,
      storeImage: json['store_image'] as String?,
      storePlacement: json['store_placement'] as String,
      createdAt: createdAt,
    );
  }

  /// Store 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'store_seq': storeSeq,
      'store_address': storeAddress,
      'store_lat': storeLat,
      'store_lng': storeLng,
      'store_phone': storePhone,
      'store_opentime': storeOpentime,
      'store_closetime': storeClosetime,
      'store_description': storeDescription,
      'store_image': storeImage,
      'store_placement': storePlacement,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Store 객체 복사
  Store copyWith({
    int? storeSeq,
    String? storeAddress,
    double? storeLat,
    double? storeLng,
    String? storePhone,
    String? storeOpentime,
    String? storeClosetime,
    String? storeDescription,
    String? storeImage,
    String? storePlacement,
    DateTime? createdAt,
  }) {
    return Store(
      storeSeq: storeSeq ?? this.storeSeq,
      storeAddress: storeAddress ?? this.storeAddress,
      storeLat: storeLat ?? this.storeLat,
      storeLng: storeLng ?? this.storeLng,
      storePhone: storePhone ?? this.storePhone,
      storeOpentime: storeOpentime ?? this.storeOpentime,
      storeClosetime: storeClosetime ?? this.storeClosetime,
      storeDescription: storeDescription ?? this.storeDescription,
      storeImage: storeImage ?? this.storeImage,
      storePlacement: storePlacement ?? this.storePlacement,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 김택권
// 설명: Store 모델 클래스 - 식당 정보를 담는 모델, API 응답 파싱 지원
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 김택권: 초기 생성
//   - Store 클래스 생성
//   - storeSeq, storeAddress, storeLat, storeLng 등 필드 추가
//   - fromJson, toJson 메서드 구현
//   - copyWith 메서드 구현
