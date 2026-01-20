import 'package:flutter_riverpod/flutter_riverpod.dart';

// 주문 1건 정보 저장
class OrderState {
  final Map<int, OrderMenu> menus; // menuSeq : OrderMenu

  OrderState({this.menus = const {}});
}

// 메뉴 1건, 옵션 n건 묶어 저장
class OrderMenu {
  final int count;
  final Map<int, int> options; // optionSeq : count

  OrderMenu({
    this.count = 1,
    this.options = const {},
  });

  OrderMenu copyWith({
    int? count,
    Map<int, int>? options,
  }) {
    return OrderMenu(
      count: count ?? this.count,
      options: options ?? this.options,
    );
  }
}

// Provider
class OrderNotifier extends Notifier<OrderState> {
  @override
  OrderState build() => OrderState();

  // 메뉴 추가
  void addMenu(int menuSeq) {
    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: state.menus[menuSeq] ?? OrderMenu(),
      },
    );
  }

  // 메뉴 수량 증가
void addOrIncrementMenu(int menuSeq) {
  final menu = state.menus[menuSeq];

  if (menu == null) {
    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: OrderMenu(count: 1),
      },
    );
  } else {
    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: menu.copyWith(count: menu.count + 1),
      },
    );
  }
}

  // 메뉴 수량 감소 (최소 1)
  void decrementMenu(int menuSeq) {
    final menu = state.menus[menuSeq];
    if (menu == null || menu.count <= 1) return;

    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: menu.copyWith(count: menu.count - 1),
      },
    );
  }

  // 옵션 수량 증가
  void incrementOption(int menuSeq, int optionSeq) {
    final menu = state.menus[menuSeq];
    if (menu == null) return;

    final current = menu.options[optionSeq] ?? 0;

    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: menu.copyWith(
          options: {
            ...menu.options,
            optionSeq: current + 1,
          },
        ),
      },
    );
  }


  // 옵션 수량 감소 (0이면 제거)
  void decrementOption(int menuSeq, int optionSeq) {
    final menu = state.menus[menuSeq];
    if (menu == null) return;

    final current = menu.options[optionSeq] ?? 0;
    if (current <= 0) return;

    final newOptions = Map<int, int>.from(menu.options);

    if (current == 1) {
      newOptions.remove(optionSeq);
    } else {
      newOptions[optionSeq] = current - 1;
    }

    state = OrderState(
      menus: {
        ...state.menus,
        menuSeq: menu.copyWith(options: newOptions),
      },
    );
  }

  void reset() {
    state = OrderState();
  }
}

// 화면에서 사용
final orderNotifierProvider =
    NotifierProvider<OrderNotifier, OrderState>(
  OrderNotifier.new,
);