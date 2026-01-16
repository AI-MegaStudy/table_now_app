class Reserve {
  final int reserve_seq;
  final int store_seq;
  final int customer_seq;
  final String? weather_datetime;
  final String reserve_tables;
  final String reserve_date;
  final String created_at;
  final String payment_key;
  final String payment_status;

  Reserve({
    required this.reserve_seq,
    required this.store_seq,
    required this.customer_seq,
    this.weather_datetime,
    required this.reserve_tables,
    required this.reserve_date,
    required this.created_at,
    required this.payment_key,
    required this.payment_status,
  });

  /// JSON 데이터에서 객체 생성
  factory Reserve.fromJson(Map<String, dynamic> json) {
    return Reserve(
      reserve_seq: json['reserve_seq'] ?? 0,
      store_seq: json['store_seq'] ?? 0,
      customer_seq: json['customer_seq'] ?? 0,
      weather_datetime: json['weather_datetime'],
      reserve_tables: json['reserve_tables'] ?? '',
      reserve_date: json['reserve_date'] ?? '',
      created_at: json['created_at'] ?? '',
      payment_key: json['payment_key'] ?? '',
      payment_status: json['payment_status'] ?? '',
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'reserve_seq': reserve_seq,
      'store_seq': store_seq,
      'customer_seq': customer_seq,
      'weather_datetime': weather_datetime,
      'reserve_tables': reserve_tables,
      'reserve_date': reserve_date,
      'created_at': created_at,
      'payment_key': payment_key,
      'payment_status': payment_status,
    };
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 유다원
// 설명: Reserve 모델 클래스
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 유다원: 최초 생성
