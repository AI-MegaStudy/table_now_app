import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuSelectState {
  final int count;

  MenuSelectState({
    this.count = 0,
  });

  MenuSelectState copyWith(
    {
      int? count,
    }
  ){
    return MenuSelectState(
      count: count ?? this.count,
    );
  }
}

class MenuSelectNotifier extends Notifier<MenuSelectState> {
  @override
  MenuSelectState build() => MenuSelectState();

  void increment() {
    state = state.copyWith(
      count: state.count + 1
    );
  }

  void decrement() {
    if (state.count == 0) return;
    state = state.copyWith(
      count: state.count - 1
    );
  }
}

// autoDispose : 화면 나가면 자동 초기화
final menuSelectNotifierProvider = NotifierProvider.autoDispose<MenuSelectNotifier, MenuSelectState>(
  MenuSelectNotifier.new // 계산해서 CounterNotifier로 줌
);

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-19
// 작성자: 임소연
// 설명: Menu Select Notifier | 화면에서 주문금액 합계 계산
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-19 임소연: 초기 생성