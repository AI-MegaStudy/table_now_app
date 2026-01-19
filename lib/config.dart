//  Configuration of the App
import 'package:table_now_app/utils/custom_common_util.dart';

//  Paths
const String imageAssetPath = 'images/';

const String defaultProfileImage =
    '${imageAssetPath}dummy-profile-pic.png'; //  더미 프로필 이미지 경로

//-----------------------------------------------------

//  Business Rules
/// 휴면 회원 판단 기준일 (일수) - 6개월 미접속 시 휴면 회원 처리
const int dormantAccountDays = 180;

/// FastAPI 서버 기본 URL (커스텀 오버라이드)
/// Windows + Android 에뮬레이터 사용자는 자신의 호스트 IP를 설정하세요
/// 예: 'http://192.168.1.50:8000'
/// null이면 플랫폼에 따라 자동 선택 (Android: 10.0.2.2, iOS: 127.0.0.1)
const String? customApiBaseUrl = 'http://172.16.250.187:8000';
//윈도우 사용자는 윗줄 주석 처리 하고 아래 줄 주석 해제하여 자신의 호스트 IP를 설정하세요.
// const String customApiBaseUrl = 'http://192.168.83.7:8000';
// const String customApiBaseUrl = 'http://cheng80.myqnapcloud.com:18000';

/// FastAPI 서버 기본 URL
///
/// customApiBaseUrl이 설정되어 있으면 사용하고, 없으면 플랫폼에 따라 기본값 반환
String getApiBaseUrl() {
  if (customApiBaseUrl != null && customApiBaseUrl!.isNotEmpty) {
    return customApiBaseUrl!;
  }
  // 기본값 반환 (플랫폼별)
  return CustomCommonUtil.getApiBaseUrlSync();
}

// GetStorage 키 상수
/// 고객 정보 저장 키 (GetStorage)
const String storageKeyCustomer = 'customer';

/// FCM 토큰 저장 키 (GetStorage)
const String storageKeyFCMToken = 'fcm_token';

/// 마지막 서버에 전송한 FCM 토큰 저장 키 (GetStorage)
const String storageKeyFCMLastSentToken = 'fcm_last_sent_token';

/// 서버 동기화 성공 여부 저장 키 (GetStorage)
const String storageKeyFCMServerSynced = 'fcm_server_synced';

/// 마지막 서버 전송 시도 시간 저장 키 (GetStorage)
const String storageKeyFCMLastSyncAttempt = 'fcm_last_sync_attempt';

/// 알림 권한 상태 저장 키 (GetStorage)
const String storageKeyFCMNotificationPermission =
    'fcm_notification_permission';

/// 자동 로그인 활성화 여부 저장 키 (GetStorage)
const String storageKeyAutoLogin = 'auto_login_enabled';

const String storageTossKey = 'tossClientKey';


// 회원 상태 (현재 미사용)
// Map loginStatus = {0: '활동 회원', 1: '휴면 회원', 2: '탈퇴 회원'};

//-----------------------------------------------------

// 서울 내 자치구 리스트 (현재 미사용)
const List<String> district = [
  '강남구',
  '강동구',
  '강북구',
  '강서구',
  '관악구',
  '광진구',
  '구로구',
  '금천구',
  '노원구',
  '도봉구',
  '동대문구',
  '동작구',
  '마포구',
  '서대문구',
  '서초구',
  '성동구',
  '성북구',
  '송파구',
  '양천구',
  '영등포구',
  '용산구',
  '은평구',
  '종로구',
  '중구',
  '중랑구',
];

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: 앱 전역 설정 파일 - API URL, 비즈니스 규칙, 상수 정의
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - API 기본 URL 설정 함수 추가 (getApiBaseUrl)
//   - 커스텀 API URL 설정 옵션 추가 (customApiBaseUrl)
//   - 회원 상태 맵 추가 (loginStatus)
//   - GetStorage 키 상수 추가 (storageKeyCustomer)
// 2026-01-20 김택권: null 체크 수정
//   - getApiBaseUrl() 함수에서 customApiBaseUrl null 체크 추가
