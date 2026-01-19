import 'package:flutter_riverpod/flutter_riverpod.dart';

class OptionSelectState {
  final Map<int, int> counts; // optionId : count

  OptionSelectState({
    this.counts = const {},
  });

  OptionSelectState copyWith({
    Map<int, int>? counts,
  }) {
    return OptionSelectState(
      counts: counts ?? this.counts,
    );
  }
}

class OptionSelectNotifier extends Notifier<OptionSelectState> {
  @override
  OptionSelectState build() => OptionSelectState();

  void increment(int option_seq) {
    final current = state.counts[option_seq] ?? 0;

    state = state.copyWith(
      counts: {
        ...state.counts,
        option_seq: current + 1,
      },
    );
  }

  void decrement(int option_seq) {
    final current = state.counts[option_seq] ?? 0;
    if (current == 0) return;

    state = state.copyWith(
      counts: {
        ...state.counts,
        option_seq: current - 1,
      },
    );
  }
}

// autoDispose : 화면 나가면 자동 초기화
final optionSelectNotifierProvider = NotifierProvider.autoDispose<OptionSelectNotifier, OptionSelectState>(
  OptionSelectNotifier.new
);

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-19
// 작성자: 임소연
// 설명: Option Select Notifier | 화면에서 주문금액 합계 계산
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-19 임소연: 초기 생성