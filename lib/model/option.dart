class Option {
  final int option_seq;
  final int store_seq;
  final int menu_seq;
  final String option_name;
  final int option_price;
  final int option_cost;
  final String created_at;

  Option({
    required this.option_seq,
    required this.store_seq,
    required this.menu_seq,
    required this.option_name,
    required this.option_price,
    required this.option_cost,
    required this.created_at,
  });

  /// JSON 데이터에서 객체 생성
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      option_seq: json['option_seq'] ?? '',
      store_seq: json['store_seq'] ?? '',
      menu_seq: json['menu_seq'] ?? '',
      option_name: json['option_name'] ?? '',
      option_price: json['option_price'] ?? '',
      option_cost: json['option_cost'] ?? '',
      created_at: json['created_at'] ?? '',
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'option_seq': option_seq,
      'store_seq': store_seq,
      'menu_seq': menu_seq,
      'option_name': option_name,
      'option_price': option_price,
      'option_cost': option_cost,
      'created_at': created_at,
    };
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 임소연
// 설명: Option 모델 클래스
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 임소연: 최초 생성
//   - Option 클래스 생성(fromJson, toJson 방식 추가)