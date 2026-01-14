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
// const String? customApiBaseUrl = null;
//윈도우 사용자는 윗줄 주석 처리 하고 아래 줄 주석 해제하여 자신의 호스트 IP를 설정하세요.
// const String? customApiBaseUrl = 'http://192.168.1.50:8000';
const String customApiBaseUrl = 'http://cheng80.myqnapcloud.com:18000';

/// FastAPI 서버 기본 URL
/// customApiBaseUrl이 설정되어 있으면 사용하고, 없으면 플랫폼에 따라 자동 선택
String getApiBaseUrl() {
  return CustomCommonUtil.getApiBaseUrl(customApiBaseUrl);
}

// 회원 상태
Map loginStatus = {0: '활동 회원', 1: '휴면 회원', 2: '탈퇴 회원'};

// 서울 내 자치구 리스트.
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
