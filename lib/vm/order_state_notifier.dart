import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

/// ===========================
/// Option 모델
/// ===========================
class OrderOption {
  final int count;
  final int price; // 옵션 1개 단가

  OrderOption({
    this.count = 0,
    this.price = 0,
  });

  OrderOption copyWith({
    int? count,
    int? price,
  }) {
    return OrderOption(
      count: count ?? this.count,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() => {
        'count': count,
        'price': price,
      };

  factory OrderOption.fromMap(Map<String, dynamic> map) {
    return OrderOption(
      count: map['count'] ?? 0,
      price: map['price'] ?? 0,
    );
  }
}

/// ===========================
/// Menu 모델
/// ===========================
class OrderMenu {
  final int count;
  final int price;
  final String date;
  final Map<int, OrderOption> options;

  OrderMenu({
    this.count = 1,
    this.price = 0,
    this.date = '',
    this.options = const {},
  });

  OrderMenu copyWith({
    int? count,
    int? price,
    String? date,
    Map<int, OrderOption>? options,
  }) {
    return OrderMenu(
      count: count ?? this.count,
      price: price ?? this.price,
      date: date ?? this.date,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toMap() => {
        'count': count,
        'price': price,
        'date': date,
        'options': options.map(
          (k, v) => MapEntry(k.toString(), v.toMap()),
        ),
      };

  factory OrderMenu.fromMap(Map<String, dynamic> map) {
    return OrderMenu(
      count: map['count'] ?? 1,
      price: map['price'] ?? 0,
      date: map['date'] ?? '',
      options: (map['options'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          int.parse(k),
          OrderOption.fromMap(Map<String, dynamic>.from(v)),
        ),
      ),
    );
  }
}

/// ===========================
/// OrderState
/// ===========================
class OrderState {
  final Map<int, OrderMenu> menus; // menuSeq : OrderMenu

  OrderState({this.menus = const {}});

  Map<String, dynamic> toMap() => {
        'menus': menus.map(
          (k, v) => MapEntry(k.toString(), v.toMap()),
        ),
      };

  factory OrderState.fromMap(Map<String, dynamic> map) {
    return OrderState(
      menus: (map['menus'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          int.parse(k),
          OrderMenu.fromMap(Map<String, dynamic>.from(v)),
        ),
      ),
    );
  }
}

/// ===========================
/// GetStorage Helper
/// ===========================
final _box = GetStorage();
const _orderKey = 'order';

void saveOrder(OrderState state) {
  _box.write(_orderKey, state.toMap());
}

OrderState loadOrder() {
  final data = _box.read(_orderKey);
  if (data != null) {
    return OrderState.fromMap(Map<String, dynamic>.from(data));
  }
  return OrderState();
}

/// ===========================
/// Notifier
/// ===========================
class OrderNotifier extends Notifier<OrderState> {
  @override
  OrderState build() {
    return loadOrder();
  }

  /// 메뉴 추가
  void addMenu({
    required int menuSeq,
    required int price,
    required String date,
  }) {
    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: state.menus[menuSeq] ??
            OrderMenu(
              count: 1,
              price: price,
              date: date,
            ),
      },
    );
    saveOrder(state);
  }

  /// 메뉴 수량 증가
void addOrIncrementMenu(int menuSeq, int menuPrice) {
  final menu = state.menus[menuSeq];

  state = OrderState(
    menus: {
      ...state.menus,
      menuSeq: menu == null
          ? OrderMenu(count: 1, price: menuPrice)
          : menu.copyWith(count: menu.count + 1),
    },
  );

  saveOrder(state);
}


  /// 메뉴 수량 감소 (최소 1)
  void decrementMenu(int menuSeq) {
    final menu = state.menus[menuSeq];
    if (menu == null || menu.count <= 1) return;

    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: menu.copyWith(count: menu.count - 1),
      },
    );
    saveOrder(state);
  }

// 옵션 수량 증가 (+ price 저장)
void incrementOption(int menuSeq, int optionSeq, int optionPrice) {
  final menu = state.menus[menuSeq];
  if (menu == null) return;

  final current = menu.options[optionSeq];

  state = OrderState(
    menus: {
      ...state.menus,
      menuSeq: menu.copyWith(
        options: {
          ...menu.options,
          optionSeq: current == null
              ? OrderOption(
                  count: 1,
                  price: optionPrice,
                )
              : current.copyWith(
                  count: current.count + 1,
                ),
        },
      ),
    },
  );

  saveOrder(state);
}


  /// 옵션 수량 감소
  void decrementOption(int menuSeq, int optionSeq) {
    final menu = state.menus[menuSeq];
    if (menu == null) return;

    final option = menu.options[optionSeq];
    if (option == null) return;

    final newOptions = Map<int, OrderOption>.from(menu.options);

    if (option.count == 1) {
      newOptions.remove(optionSeq);
    } else {
      newOptions[optionSeq] = option.copyWith(count: option.count - 1);
    }

    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: menu.copyWith(options: newOptions),
      },
    );
    saveOrder(state);
  }

  void reset() {
    state = OrderState();
    saveOrder(state);
  }

  // 담기버튼 누를때 데이터 저장
  void confirmMenu(int menuSeq) {
    final menu = state.menus[menuSeq];
    if (menu == null) return;

    final now = DateTime.now().toIso8601String();

    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: menu.copyWith(
          date: now,
        ),
      },
    );
    saveOrder(state);
  }
}

/// ===========================
/// Provider
/// ===========================
final orderNotifierProvider =
    NotifierProvider<OrderNotifier, OrderState>(
  OrderNotifier.new,
);

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-20
// 작성자: 임소연
// 설명: Order Notifier
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-20 임소연: 초기 생성
// 2026-01-20 임소연: get storage helper 추가