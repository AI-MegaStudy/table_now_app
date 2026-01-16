import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/model/customer.dart';

/// Customer 정보 저장소 헬퍼 클래스
///
/// GetStorage를 사용하여 Customer 정보를 저장/불러오기/삭제하는 정적 메서드를 제공합니다.
/// config.dart의 storageKeyCustomer 상수를 사용합니다.
class CustomerStorage {
  static GetStorage get _storage => GetStorage();

  /// Customer 정보 저장
  ///
  /// [customer]를 GetStorage에 JSON 형태로 저장합니다.
  static Future<void> saveCustomer(Customer customer) async {
    await _storage.write(storageKeyCustomer, customer.toJson());
  }

  /// 저장된 Customer 정보 가져오기
  ///
  /// GetStorage에서 Customer 정보를 불러와 Customer 객체로 반환합니다.
  /// 저장된 정보가 없거나 유효하지 않으면 null을 반환합니다.
  static Customer? getCustomer() {
    try {
      final customerData = _storage.read<Map<String, dynamic>>(
        storageKeyCustomer,
      );

      if (customerData == null ||
          customerData['customer_name'] == null ||
          customerData['customer_email'] == null) {
        return null;
      }

      return Customer.fromJson(customerData);
    } catch (e) {
      // 파싱 실패 시 null 반환
      return null;
    }
  }

  /// Customer 정보 삭제 (로그아웃 시 호출)
  ///
  /// GetStorage에서 Customer 정보를 제거합니다.
  static Future<void> clearCustomer() async {
    await _storage.remove(storageKeyCustomer);
  }

  /// Customer 로그인 여부 확인
  ///
  /// GetStorage에 Customer 정보가 저장되어 있는지 확인합니다.
  static bool isCustomerLoggedIn() {
    return _storage.hasData(storageKeyCustomer);
  }

  /// Customer Seq 가져오기
  ///
  /// 저장된 Customer의 customerSeq를 반환합니다.
  /// Customer 정보가 없으면 null을 반환합니다.
  static int? getCustomerSeq() {
    final customer = getCustomer();
    return customer?.customerSeq;
  }

  /// Customer 이름 가져오기
  ///
  /// 저장된 Customer의 이름을 반환합니다.
  /// Customer 정보가 없으면 null을 반환합니다.
  static String? getCustomerName() {
    final customer = getCustomer();
    return customer?.customerName;
  }

  /// Customer 이메일 가져오기
  ///
  /// 저장된 Customer의 이메일을 반환합니다.
  /// Customer 정보가 없으면 null을 반환합니다.
  static String? getCustomerEmail() {
    final customer = getCustomer();
    return customer?.customerEmail;
  }

  /// Customer 전화번호 가져오기
  ///
  /// 저장된 Customer의 전화번호를 반환합니다.
  /// Customer 정보가 없거나 전화번호가 없으면 null을 반환합니다.
  static String? getCustomerPhone() {
    final customer = getCustomer();
    return customer?.customerPhone;
  }

  /// Customer Provider 가져오기
  ///
  /// 저장된 Customer의 로그인 제공업체를 반환합니다.
  /// ('local' 또는 'google')
  /// Customer 정보가 없으면 null을 반환합니다.
  static String? getCustomerProvider() {
    final customer = getCustomer();
    return customer?.provider;
  }

  /// 구글 계정인지 확인
  ///
  /// 저장된 Customer가 구글 계정인지 확인합니다.
  static bool isGoogleAccount() {
    final customer = getCustomer();
    return customer?.isGoogleAccount ?? false;
  }

  /// 로컬 계정인지 확인
  ///
  /// 저장된 Customer가 로컬 계정인지 확인합니다.
  static bool isLocalAccount() {
    final customer = getCustomer();
    return customer?.isLocalAccount ?? false;
  }

  /// Customer 정보 업데이트
  ///
  /// 기존 Customer 정보를 [customer]로 업데이트합니다.
  static Future<void> updateCustomer(Customer customer) async {
    await saveCustomer(customer);
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 김택권
// 설명: Customer Storage 헬퍼 클래스 - GetStorage를 사용한 Customer 정보 관리
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 김택권: 초기 생성
//   - CustomerStorage 클래스 생성
//   - saveCustomer, getCustomer, clearCustomer 메서드 구현
//   - isCustomerLoggedIn 메서드 구현
//   - 개별 필드 조회 메서드 구현 (getCustomerSeq, getCustomerName 등)
//   - 계정 타입 확인 메서드 구현 (isGoogleAccount, isLocalAccount)
//   - updateCustomer 메서드 구현
