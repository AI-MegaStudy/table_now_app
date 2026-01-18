class StoreTable {
  final int store_table_seq;
  final int store_seq;
  final int store_table_name;
  final int store_table_capacity;
  final String store_table_inuse;
  final String created_at;

  StoreTable({
    required this.store_table_seq,
    required this.store_seq,
    required this.store_table_name,
    required this.store_table_capacity,
    required this.store_table_inuse,
    required this.created_at,
  });

  /// JSON 데이터에서 객체 생성
  factory StoreTable.fromJson(Map<String, dynamic> json) {
    return StoreTable(
      store_table_seq: json['store_table_seq'] ?? 0,
      store_seq: json['store_seq'] ?? 0,
      store_table_name: json['store_table_name'] ?? 0,
      store_table_capacity: json['store_table_capacity'] ?? 0,
      store_table_inuse: json['store_table_inuse'] ?? 'N',
      created_at: json['created_at'] ?? '',
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'store_table_seq': store_table_seq,
      'store_seq': store_seq,
      'store_table_name': store_table_name,
      'store_table_capacity': store_table_capacity,
      'store_table_inuse': store_table_inuse,
      'created_at': created_at,
    };
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-18
// 작성자: 이예은
// 설명: StoreTable 모델 클래스
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-18 이예은: 최초 생성
//   - StoreTable 클래스 생성(fromJson, toJson 방식 추가)
