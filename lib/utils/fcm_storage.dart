import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config.dart';

/// FCM 토큰 정보 저장소 헬퍼 클래스
///
/// GetStorage를 사용하여 FCM 토큰 관련 정보를 저장/불러오기/삭제하는 정적 메서드를 제공합니다.
/// config.dart의 storageKeyFCM 관련 상수를 사용합니다.
class FCMStorage {
  static GetStorage get _storage => GetStorage();

  /// FCM 토큰 저장
  ///
  /// 현재 발급받은 FCM 토큰을 로컬에 저장합니다.
  /// 서버 전송 실패 시 재시도하거나, 앱 재시작 시 사용합니다.
  static Future<void> saveFCMToken(String token) async {
    await _storage.write(storageKeyFCMToken, token);
    if (kDebugMode) {
      print('💾 FCM 토큰 로컬 저장 완료');
    }
  }

  /// 저장된 FCM 토큰 가져오기
  ///
  /// 로컬에 저장된 FCM 토큰을 반환합니다.
  /// 저장된 토큰이 없으면 null을 반환합니다.
  static String? getFCMToken() {
    return _storage.read<String>(storageKeyFCMToken);
  }

  /// 마지막 서버에 전송한 FCM 토큰 저장
  ///
  /// 서버에 성공적으로 전송한 토큰을 저장합니다.
  /// 토큰이 변경되었는지 확인하는 데 사용됩니다.
  static Future<void> saveLastSentToken(String token) async {
    await _storage.write(storageKeyFCMLastSentToken, token);
  }

  /// 마지막 서버에 전송한 FCM 토큰 가져오기
  ///
  /// 서버에 마지막으로 전송한 토큰을 반환합니다.
  /// 저장된 토큰이 없으면 null을 반환합니다.
  static String? getLastSentToken() {
    return _storage.read<String>(storageKeyFCMLastSentToken);
  }

  /// 토큰이 서버에 전송되었는지 확인
  ///
  /// 현재 토큰과 마지막 전송한 토큰이 같은지 확인합니다.
  /// 다르면 서버에 전송이 필요합니다.
  static bool isTokenSynced() {
    final currentToken = getFCMToken();
    final lastSentToken = getLastSentToken();
    
    if (currentToken == null || lastSentToken == null) {
      return false;
    }
    
    return currentToken == lastSentToken;
  }

  /// 서버 전송 성공 여부 저장
  ///
  /// 서버에 토큰 전송이 성공했는지 여부를 저장합니다.
  static Future<void> setServerSyncStatus(bool isSynced) async {
    await _storage.write(storageKeyFCMServerSynced, isSynced);
  }

  /// 서버 전송 성공 여부 확인
  ///
  /// 서버에 토큰이 성공적으로 전송되었는지 확인합니다.
  static bool isServerSynced() {
    return _storage.read<bool>(storageKeyFCMServerSynced) ?? false;
  }

  /// 마지막 서버 전송 시도 시간 저장
  ///
  /// 서버에 토큰을 전송하려고 시도한 마지막 시간을 저장합니다.
  /// 재시도 로직에서 사용합니다.
  static Future<void> saveLastSyncAttempt(DateTime dateTime) async {
    await _storage.write(
      storageKeyFCMLastSyncAttempt,
      dateTime.toIso8601String(),
    );
  }

  /// 마지막 서버 전송 시도 시간 가져오기
  ///
  /// 마지막으로 서버에 토큰을 전송하려고 시도한 시간을 반환합니다.
  /// 저장된 시간이 없으면 null을 반환합니다.
  static DateTime? getLastSyncAttempt() {
    final dateTimeString = _storage.read<String>(storageKeyFCMLastSyncAttempt);
    if (dateTimeString == null) return null;
    
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// 알림 권한 상태 저장
  ///
  /// 사용자가 알림 권한을 허용했는지 여부를 저장합니다.
  static Future<void> saveNotificationPermissionStatus(bool granted) async {
    await _storage.write(storageKeyFCMNotificationPermission, granted);
  }

  /// 알림 권한 상태 확인
  ///
  /// 사용자가 알림 권한을 허용했는지 확인합니다.
  /// 저장된 값이 없으면 null을 반환합니다.
  static bool? getNotificationPermissionStatus() {
    return _storage.read<bool>(storageKeyFCMNotificationPermission);
  }

  /// FCM 관련 모든 데이터 삭제
  ///
  /// 로그아웃 시 또는 FCM 설정 초기화 시 호출합니다.
  static Future<void> clearAll() async {
    await _storage.remove(storageKeyFCMToken);
    await _storage.remove(storageKeyFCMLastSentToken);
    await _storage.remove(storageKeyFCMServerSynced);
    await _storage.remove(storageKeyFCMLastSyncAttempt);
    await _storage.remove(storageKeyFCMNotificationPermission);
    
    if (kDebugMode) {
      print('🗑️  FCM 로컬 저장소 초기화 완료');
    }
  }

  /// FCM 토큰만 삭제 (토큰 갱신 시 사용)
  ///
  /// 토큰이 갱신될 때 이전 토큰을 삭제합니다.
  static Future<void> clearToken() async {
    await _storage.remove(storageKeyFCMToken);
  }

  /// 서버 동기화 상태만 초기화
  ///
  /// 서버 전송 실패 시 동기화 상태를 초기화합니다.
  static Future<void> clearSyncStatus() async {
    await _storage.remove(storageKeyFCMServerSynced);
    await _storage.remove(storageKeyFCMLastSentToken);
    await _storage.remove(storageKeyFCMLastSyncAttempt);
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-17
// 작성자: 김택권
// 설명: FCM Storage 헬퍼 클래스 - GetStorage를 사용한 FCM 토큰 정보 관리
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-17 김택권: 초기 생성
//   - FCMStorage 클래스 생성
//   - FCM 토큰 저장/불러오기 메서드 구현
//   - 서버 동기화 상태 관리 메서드 구현
//   - 알림 권한 상태 저장/불러오기 메서드 구현
//   - 토큰 동기화 확인 메서드 구현
