/// 현재 화면 추적 유틸리티
///
/// 알림 클릭 시 현재 화면을 확인하기 위해 사용됩니다.
class CurrentScreenTracker {
  /// 현재 화면 이름 (예: "Dev_05", "Home", "WeatherScreen" 등)
  static String? _currentScreen;

  /// 현재 화면 설정
  static void setCurrentScreen(String screenName) {
    _currentScreen = screenName;
  }

  /// 현재 화면 가져오기
  static String? getCurrentScreen() {
    return _currentScreen;
  }

  /// 현재 화면 초기화
  static void clearCurrentScreen() {
    _currentScreen = null;
  }
}
