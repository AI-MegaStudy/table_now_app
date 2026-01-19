
class Payment {
  final int? pay_id;
  final int reserve_seq;
  final int store_seq;
  final int menu_seq;
  final int? option_seq;
  final int pay_quantity;
  final int pay_amount;
  final DateTime? created_at;

  Payment({
    this.pay_id,
    required this.reserve_seq,
    required this.store_seq,
    required this.menu_seq,
    this.option_seq,
    required this.pay_quantity,
    required this.pay_amount,
    this.created_at
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      pay_id: json['pay_id'],
      reserve_seq: json['reserve_seq'],
      store_seq: json['store_seq'],
      menu_seq: json['menu_seq'],
      option_seq: json['option_seq'],
      pay_quantity: json['pay_quantity'],
      pay_amount: json['pay_amount'],
      created_at: DateTime.parse(json['created_at'])
    );
  }

  Payment copyWidth(
    int? pay_id,
    int? reserve_seq,
    int? store_seq,
    int? menu_seq,
    int? option_seq,
    int? pay_quantity,
    int? pay_amount,
    DateTime? created_at
  ) {
    return Payment(
      pay_id: pay_id ?? this.pay_id,
      reserve_seq: reserve_seq ?? this.reserve_seq,
      store_seq: store_seq ?? this.store_seq,
      menu_seq: menu_seq ?? this.menu_seq,
      pay_quantity: pay_quantity ?? this.pay_quantity,
      pay_amount: pay_amount ?? this.pay_amount,
      created_at: created_at ?? this.created_at
    );
  }

  Map<String,dynamic> toJson() {
    return {
       'pay_id':pay_id,
      "reserve_seq": reserve_seq,
      "store_seq": store_seq,
      "menu_seq": menu_seq,
      "option_seq": option_seq,
      "pay_quantity": pay_quantity,
      "pay_amount": pay_amount,
      "created_at": created_at.toString()
    };
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 이광태
// 설명: Pay 모델 클래스
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 이광태: 최초 생성
//   - Payment 클래스 생성(fromJson, toJson, copyWith 추가)