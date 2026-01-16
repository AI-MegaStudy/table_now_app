// select pay_id,reserve_seq,store_seq,menu_seq,option_seq,pay_quantitiy,pay_amount,created_at

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
    this.created_at,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      pay_id: json['pay_id'],
      reserve_seq: json['reserve_seq'],
      store_seq: json['store_seq'],
      menu_seq: json['menu_seq'],
      pay_quantity: json['pay_quantitiy'],
      pay_amount: json['pay_amount'],
      created_at: json['created_at'] ?? DateTime.now(),
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
    DateTime? created_at,
  ) {
    return Payment(
      pay_id: pay_id ?? this.pay_id,
      reserve_seq: reserve_seq ?? this.reserve_seq,
      store_seq: store_seq ?? this.store_seq,
      menu_seq: menu_seq ?? this.menu_seq,
      pay_quantity: pay_quantity ?? this.pay_quantity,
      pay_amount: pay_amount ?? this.pay_amount,
      created_at: created_at ?? this.created_at,
    );
  }
}
