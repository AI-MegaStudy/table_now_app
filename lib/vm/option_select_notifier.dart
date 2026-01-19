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

// StateNotifierProvider: 클래스를 외부에서 사용 가능하게 만들어주는 Provider
final optionSelectProvider = NotifierProvider<OptionSelectNotifier, OptionSelectState>(
  OptionSelectNotifier.new // 계산해서 CounterNotifier로 줌
);