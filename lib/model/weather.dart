/// Weather 모델 클래스
///
/// 날씨 정보를 담는 모델입니다.
/// API 응답을 파싱하여 사용합니다.
class Weather {
  final DateTime weatherDatetime;
  final String weatherType; // 한글 날씨 상태 (예: "맑음", "비")
  final double weatherLow; // 최저 온도
  final double weatherHigh; // 최고 온도
  final String? iconUrl; // 날씨 아이콘 URL (선택사항)

  Weather({
    required this.weatherDatetime,
    required this.weatherType,
    required this.weatherLow,
    required this.weatherHigh,
    this.iconUrl,
  });

  /// JSON에서 Weather 객체 생성
  factory Weather.fromJson(Map<String, dynamic> json) {
    // weather_datetime 파싱
    DateTime weatherDatetime;
    if (json['weather_datetime'] is String) {
      weatherDatetime = DateTime.parse(json['weather_datetime']);
    } else {
      weatherDatetime = DateTime.now();
    }

    return Weather(
      weatherDatetime: weatherDatetime,
      weatherType: json['weather_type'] as String,
      weatherLow: (json['weather_low'] as num).toDouble(),
      weatherHigh: (json['weather_high'] as num).toDouble(),
      iconUrl: json['icon_url'] as String?,
    );
  }

  /// Weather 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'weather_datetime': weatherDatetime.toIso8601String(),
      'weather_type': weatherType,
      'weather_low': weatherLow,
      'weather_high': weatherHigh,
      'icon_url': iconUrl,
    };
  }

  /// Weather 객체 복사
  Weather copyWith({
    DateTime? weatherDatetime,
    String? weatherType,
    double? weatherLow,
    double? weatherHigh,
    String? iconUrl,
  }) {
    return Weather(
      weatherDatetime: weatherDatetime ?? this.weatherDatetime,
      weatherType: weatherType ?? this.weatherType,
      weatherLow: weatherLow ?? this.weatherLow,
      weatherHigh: weatherHigh ?? this.weatherHigh,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }

  /// 날짜만 비교 (시간 제외)
  bool isSameDate(DateTime other) {
    return weatherDatetime.year == other.year &&
        weatherDatetime.month == other.month &&
        weatherDatetime.day == other.day;
  }

  /// 오늘 날짜인지 확인
  bool get isToday {
    final now = DateTime.now();
    return isSameDate(now);
  }

  /// 내일 날짜인지 확인
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDate(tomorrow);
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: Weather 모델 클래스 - 날씨 정보를 담는 모델, API 응답 파싱 지원
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - Weather 클래스 생성
//   - weatherDatetime, weatherType, weatherLow, weatherHigh, iconUrl 필드 추가
//   - fromJson, toJson 메서드 구현
//   - copyWith 메서드 구현
//   - 날짜 비교 헬퍼 메서드 추가 (isSameDate, isToday, isTomorrow)
