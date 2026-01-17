import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/model/customer.dart';
import 'package:table_now_app/utils/fcm_storage.dart';

/// 인증 상태 모델
class AuthState {
  final Customer? customer;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.customer, this.isLoading = false, this.errorMessage});

  /// 로그인 여부 확인
  bool get isLoggedIn => customer != null;

  /// 로그아웃 여부 확인
  bool get isLoggedOut => customer == null;

  AuthState copyWith({
    Customer? customer,
    bool? isLoading,
    String? errorMessage,
    bool removeCustomer = false,
    bool removeErrorMessage = false,
  }) {
    return AuthState(
      customer: removeCustomer ? null : (customer ?? this.customer),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: removeErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 인증 Notifier
///
/// 로그인 상태 및 사용자 정보를 전역으로 관리하는 Notifier입니다.
/// GetStorage와 동기화하여 앱 재시작 후에도 로그인 상태를 유지합니다.
class AuthNotifier extends Notifier<AuthState> {
  final GetStorage _storage = GetStorage();

  @override
  AuthState build() {
    // 초기화 시 GetStorage에서 로그인 정보 불러오기
    // build() 메서드는 동기적으로 초기 상태만 반환해야 함
    try {
      final customerData = _storage.read<Map<String, dynamic>>(
        storageKeyCustomer,
      );

      if (customerData != null &&
          customerData['customer_name'] != null &&
          customerData['customer_email'] != null) {
        final customer = Customer.fromJson(customerData);
        return AuthState(customer: customer);
      } else {
        return AuthState(customer: null);
      }
    } catch (e) {
      // 파싱 실패 시 로그인 상태 없음으로 처리
      return AuthState(customer: null);
    }
  }

  /// GetStorage에서 고객 정보 불러오기 (새로고침용)
  void _loadCustomerFromStorage() {
    try {
      final customerData = _storage.read<Map<String, dynamic>>(
        storageKeyCustomer,
      );

      if (customerData != null &&
          customerData['customer_name'] != null &&
          customerData['customer_email'] != null) {
        final customer = Customer.fromJson(customerData);
        state = state.copyWith(customer: customer);
      } else {
        state = state.copyWith(customer: null);
      }
    } catch (e) {
      // 파싱 실패 시 로그인 상태 없음으로 처리
      state = state.copyWith(customer: null);
    }
  }

  /// 로그인 처리
  ///
  /// [customer]를 전역 상태에 저장하고 GetStorage에도 저장합니다.
  Future<void> login(Customer customer) async {
    try {
      // GetStorage에 저장
      await _storage.write(storageKeyCustomer, customer.toJson());

      // 상태 업데이트
      state = state.copyWith(customer: customer, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: '로그인 정보 저장 중 오류가 발생했습니다.');
    }
  }

  /// 로그아웃 처리
  ///
  /// 전역 상태와 GetStorage에서 로그인 정보를 제거합니다.
  /// FCM 서버 동기화 상태만 초기화합니다 (토큰과 알림 권한은 기기별이므로 유지).
  Future<void> logout() async {
    // GetStorage에서 삭제
    _storage.remove(storageKeyCustomer);

    // FCM 서버 동기화 상태만 초기화
    // (토큰과 알림 권한은 기기별이므로 유지, 다음 로그인 시 재사용 가능)
    await FCMStorage.clearSyncStatus();

    // 상태 업데이트
    state = state.copyWith(removeCustomer: true, removeErrorMessage: true);
  }

  /// 고객 정보 업데이트
  ///
  /// 프로필 수정 등으로 고객 정보가 변경되었을 때 호출합니다.
  Future<void> updateCustomer(Customer customer) async {
    try {
      // GetStorage에 저장
      await _storage.write(storageKeyCustomer, customer.toJson());

      // 상태 업데이트
      state = state.copyWith(customer: customer);
    } catch (e) {
      state = state.copyWith(errorMessage: '고객 정보 업데이트 중 오류가 발생했습니다.');
    }
  }

  /// 고객 정보 새로고침
  ///
  /// GetStorage에서 최신 정보를 다시 불러옵니다.
  void refreshCustomer() {
    _loadCustomerFromStorage();
  }

  /// 로그인 상태 초기화 (테스트용)
  void reset() {
    _storage.remove(storageKeyCustomer);
    state = AuthState();
  }
}

/// AuthNotifier Provider
///
/// Riverpod 3.x 방식: 생성자 참조 사용
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: Auth Notifier - 인증 상태 전역 관리 및 GetStorage 동기화
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - AuthState 클래스 생성 (인증 상태 모델)
//   - AuthNotifier 클래스 생성 (Riverpod Notifier)
//   - login 메서드 구현 (로그인 처리 및 GetStorage 저장)
//   - logout 메서드 구현 (로그아웃 처리 및 GetStorage 삭제)
//   - updateCustomer 메서드 구현 (고객 정보 업데이트)
//   - refreshCustomer 메서드 구현 (고객 정보 새로고침)
//   - GetStorage와 자동 동기화 (초기화 시 자동 로드)
