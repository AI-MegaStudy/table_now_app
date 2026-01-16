class Menu {
  final int menu_seq;
  final int store_seq;
  final String menu_name;
  final int menu_price;
  final String menu_description;
  final String menu_image;
  final int menu_cost;
  final String created_at;

  Menu({
    required this.menu_seq,
    required this.store_seq,
    required this.menu_name,
    required this.menu_price,
    required this.menu_description,
    required this.menu_image,
    required this.menu_cost,
    required this.created_at,
  });

  /// JSON 데이터에서 객체 생성
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      menu_seq: json['menu_seq'] ?? '',
      store_seq: json['store_seq'] ?? '',
      menu_name: json['menu_name'] ?? '',
      menu_price: json['menu_price'] ?? '',
      menu_description: json['menu_description'] ?? '',
      menu_image: json['menu_image'] ?? '',
      menu_cost: json['menu_cost'] ?? '',
      created_at: json['created_at'] ?? '',
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'menu_seq': menu_seq,
      'store_seq': store_seq,
      'menu_name': menu_name,
      'menu_price': menu_price,
      'menu_description': menu_description,
      'menu_image': menu_image,
      'menu_cost': menu_cost,
      'created_at': created_at,
    };
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 임소연
// 설명: Menu 모델 클래스
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 임소연: 최초 생성
//   - Menu 클래스 생성(fromJson, toJson 방식 추가)