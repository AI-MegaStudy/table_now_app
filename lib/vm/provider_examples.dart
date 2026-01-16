import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config.dart';

// ============================================
// 1. Provider - 단순한 값 제공 (변경 불가)
// ============================================
// 사용 시기: 상수, 설정값, 계산된 값 등
final appNameProvider = Provider<String>((ref) {
  return 'Table Now';
});

final apiBaseUrlProvider = Provider<String>((ref) {
  return 'https://api.example.com';
});

// ============================================
// 2. StateProvider - 간단한 상태 관리 (레거시)
// ============================================
// ⚠️ Riverpod 3.x에서는 StateProvider가 제거되었거나 제한적입니다.
// 최신 방식은 Notifier를 사용하는 것을 권장합니다.
//
// 사용 시기: 단순한 값 하나만 관리 (int, String, bool 등)
//
// 레거시 방식 (Riverpod 2.x):
// final counterProvider = StateProvider<int>((ref) => 0);
// 사용: ref.read(counterProvider.notifier).state = 5;
//
// 최신 방식 (권장) - 아래 NotifierProvider 섹션 참고

// ============================================
// 3. NotifierProvider - 상태 관리 (권장)
// ============================================
// 사용 시기:
// - 상태를 관리해야 하는 경우 (간단하든 복잡하든)
// - 여러 메서드가 필요한 경우
// - 복잡한 로직이 필요한 경우
// - 상태 변경 시 추가 작업이 필요한 경우 (저장, 검증 등)

// 간단한 카운터 예제
class CounterNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void increment() {
    state = state + 1;
  }

  void decrement() {
    state = state - 1;
  }

  void reset() {
    state = 0;
  }
}

final counterNotifierProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

// 간단한 boolean 상태 예제 (GetStorage와 동기화)
class LoginNotifier extends Notifier<bool> {
  final GetStorage _storage = GetStorage();

  @override
  bool build() {
    // 초기화 시 GetStorage에서 로그인 상태 확인
    // 실제 로그인 상태는 authNotifierProvider를 통해 관리되므로
    // GetStorage에 customer 정보가 있으면 로그인 상태로 간주
    try {
      final customerData = _storage.read<Map<String, dynamic>>(
        storageKeyCustomer,
      );
      return customerData != null &&
          customerData['customer_name'] != null &&
          customerData['customer_email'] != null;
    } catch (e) {
      return false;
    }
  }

  void login() {
    state = true;
  }

  void logout() {
    // GetStorage에서도 로그인 정보 제거
    _storage.remove(storageKeyCustomer);
    state = false;
  }

  /// GetStorage에서 로그인 상태 새로고침
  void refresh() {
    try {
      final customerData = _storage.read<Map<String, dynamic>>(
        storageKeyCustomer,
      );
      state =
          customerData != null &&
          customerData['customer_name'] != null &&
          customerData['customer_email'] != null;
    } catch (e) {
      state = false;
    }
  }
}

final loginNotifierProvider = NotifierProvider<LoginNotifier, bool>(
  LoginNotifier.new,
);

// ============================================
// 4. AsyncNotifierProvider - 비동기 상태 관리
// ============================================
// 사용 시기: API 호출, 데이터 로딩 등 비동기 작업

class UserNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    // 초기 데이터 로딩
    return await fetchUsers();
  }

  Future<List<String>> fetchUsers() async {
    // API 호출 등
    await Future.delayed(const Duration(seconds: 1));
    return ['User1', 'User2', 'User3'];
  }

  Future<void> addUser(String user) async {
    final currentUsers = state.value ?? [];
    state = AsyncValue.data([...currentUsers, user]);
  }
}

final userNotifierProvider = AsyncNotifierProvider<UserNotifier, List<String>>(
  UserNotifier.new,
);

// ============================================
// 5. FutureProvider - Future 값 제공
// ============================================
// 사용 시기: 한 번만 실행되는 비동기 작업
final futureDataProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return 'Loaded Data';
});

// ============================================
// 6. StreamProvider - Stream 값 제공
// ============================================
// 사용 시기: 실시간 데이터 스트림
final streamDataProvider = StreamProvider<int>((ref) async* {
  for (int i = 0; i < 10; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
});

// ============================================
// 선택 가이드
// ============================================
//
// 1. 단순한 값만 제공 → Provider
//    예: 앱 이름, 설정값
//
// 2. 상태 관리 (간단하든 복잡하든) → NotifierProvider (권장)
//    예: 카운터, 로그인 여부, 테마 관리, 폼 상태, 복잡한 비즈니스 로직
//    ⚠️ Riverpod 3.x에서는 StateProvider 대신 NotifierProvider 사용 권장
//
// 4. 비동기 데이터 로딩 → AsyncNotifierProvider
//    예: API 데이터, 데이터베이스 쿼리
//
// 5. 한 번만 실행되는 Future → FutureProvider
//    예: 초기 설정 로딩
//
// 6. 실시간 스트림 → StreamProvider
//    예: WebSocket, 실시간 업데이트
