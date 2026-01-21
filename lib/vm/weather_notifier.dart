import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/model/weather.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/utils/custom_common_util.dart';

/// 날씨 상태 모델
class WeatherState {
  final List<Weather> weatherList;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastUpdated;

  WeatherState({
    this.weatherList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastUpdated,
  });

  WeatherState copyWith({
    List<Weather>? weatherList,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return WeatherState(
      weatherList: weatherList ?? this.weatherList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 특정 날짜의 날씨 데이터 조회
  Weather? getWeatherByDate(DateTime date) {
    try {
      return weatherList.firstWhere((weather) => weather.isSameDate(date));
    } catch (e) {
      return null;
    }
  }

  /// 오늘 날씨 조회
  Weather? get todayWeather {
    return getWeatherByDate(DateTime.now());
  }

  /// 내일 날씨 조회
  Weather? get tomorrowWeather {
    return getWeatherByDate(DateTime.now().add(const Duration(days: 1)));
  }
}

/// 날씨 Notifier
///
/// 날씨 데이터를 관리하고 OpenWeatherMap API를 호출하는 Notifier입니다.
/// DB 저장 없이 직접 API 호출만 지원합니다.
class WeatherNotifier extends Notifier<WeatherState> {
  // API 기본 URL (캐시된 값 사용)
  String get _apiBaseUrl => getApiBaseUrl();

  @override
  WeatherState build() {
    return WeatherState();
  }

  /// Store 리스트 가져오기
  Future<List<Store>> fetchStores() async {
    try {
      final url = Uri.parse('$_apiBaseUrl/api/store/select_stores');

      final response = await http.get(url).timeout(const Duration(seconds: 30));

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        if (responseData['results'] != null) {
          final List<dynamic> results = responseData['results'];
          return results.map((json) => Store.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('서버 오류가 발생했습니다. (${response.statusCode})');
      }
    } catch (e) {
      CustomCommonUtil.logError(
        functionName: 'WeatherNotifier.fetchStores',
        error: e.toString(),
        url: '$_apiBaseUrl/api/store/select_stores',
      );
      rethrow;
    }
  }

  /// OpenWeatherMap API에서 직접 날씨 데이터 가져오기 (DB 저장 없이)
  ///
  /// [lat], [lon]을 직접 받아서 OpenWeatherMap API를 호출합니다 (store 테이블 조회 없음).
  /// [startDate]가 없으면 오늘 포함 8일치 모두 반환하고,
  /// [startDate]가 있으면 해당 날짜부터 남은 날짜만 반환합니다.
  ///
  /// 참고:
  /// - OpenWeatherMap OneCall API의 daily 배열은 최대 8일(오늘 포함)까지 제공합니다.
  /// - 날짜 검증: 과거 날짜 불가, 최대 8일까지만 가능 (클라이언트 + 백엔드 이중 검증)
  /// - 예: startDate=오늘+3일 → 오늘+3일부터 5일치만 반환 (총 8일 중 남은 5일)
  Future<void> fetchWeatherDirect({
    required double lat,
    required double lon,
    DateTime? startDate,
  }) async {
    // 로딩 시작
    state = state.copyWith(isLoading: true, errorMessage: null);

    // 클라이언트 날짜 검증 (백엔드에서도 검증하지만 불필요한 API 호출 방지)
    if (startDate != null) {
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      final maxDate = todayOnly.add(
        const Duration(days: 7),
      ); // 오늘 포함 8일 = 오늘 + 7일
      final dateOnly = DateTime(startDate.year, startDate.month, startDate.day);

      if (dateOnly.isBefore(todayOnly)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '과거 날짜의 실시간 예보는 조회할 수 없습니다.',
        );
        return;
      }

      if (dateOnly.isAfter(maxDate)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              '예보는 오늘부터 최대 8일까지만 조회 가능합니다. (요청한 날짜: ${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')})',
        );
        return;
      }
    }

    try {
      String url = '$_apiBaseUrl/api/weather/direct?lat=$lat&lon=$lon';

      // 시작 날짜 파라미터 추가
      if (startDate != null) {
        final dateStr =
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
        url += '&start_date=$dateStr';
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        if (responseData['results'] != null) {
          final List<dynamic> results = responseData['results'];
          final List<Weather> weatherList = results
              .map((json) => Weather.fromJson(json))
              .toList();

          state = state.copyWith(
            weatherList: weatherList,
            isLoading: false,
            lastUpdated: DateTime.now(),
            errorMessage: null,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: '날씨 데이터를 찾을 수 없습니다.',
          );
        }
      } else {
        final errorMsg =
            responseData['errorMsg'] ??
            '서버 오류가 발생했습니다. (${response.statusCode})';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      }
    } catch (e) {
      String errorMessage = '날씨 데이터를 가져오는 중 오류가 발생했습니다.';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '서버에 연결할 수 없습니다. 서버가 실행 중인지 확인해주세요.';
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);

      CustomCommonUtil.logError(
        functionName: 'WeatherNotifier.fetchWeatherDirect',
        error: e.toString(),
        url: '$_apiBaseUrl/api/weather/direct',
      );
    }
  }

  /// OpenWeatherMap API에서 오늘부터 8일치 예보 가져오기
  ///
  /// [lat], [lon]을 직접 받아서 OpenWeatherMap API를 호출합니다.
  /// OpenWeatherMap OneCall API의 daily 배열에서 8일치 데이터를 모두 반환합니다.
  Future<void> fetchWeatherDirect8Days({
    required double lat,
    required double lon,
  }) async {
    await fetchWeatherDirect(lat: lat, lon: lon);
  }

  /// OpenWeatherMap API에서 특정 날짜부터 남은 날짜의 날씨 가져오기
  ///
  /// [lat], [lon]을 직접 받아서 OpenWeatherMap API를 호출합니다.
  /// [startDate]부터 남은 날짜만 반환합니다 (최대 8일).
  /// 예: startDate=오늘+3일 → 오늘+3일부터 5일치만 반환
  Future<void> fetchWeatherDirectFromDate({
    required double lat,
    required double lon,
    required DateTime startDate,
  }) async {
    await fetchWeatherDirect(lat: lat, lon: lon, startDate: startDate);
  }

  /// 상태 초기화
  void reset() {
    state = WeatherState();
  }
}

/// WeatherNotifier Provider
///
/// Riverpod 3.x 방식: 생성자 참조 사용
final weatherNotifierProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: Weather Notifier - 날씨 데이터 상태 관리 및 API 호출
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - WeatherState 클래스 생성 (날씨 상태 모델)
//   - WeatherNotifier 클래스 생성 (Riverpod Notifier)
//   - fetchWeather 메서드 구현 (날씨 데이터 조회)
//   - fetchWeatherByDate 메서드 구현 (특정 날짜 조회)
//   - fetchWeatherFromApi 메서드 구현 (OpenWeatherMap API 연동)
//
// 2026-01-18: OpenWeatherMap API 직접 조회 기능 추가
//   - fetchWeatherDirect 메서드 추가 (DB 저장 없이 직접 조회)
//   - fetchWeatherDirect8Days 메서드 추가 (8일치 예보)
//   - fetchWeatherDirectFromDate 메서드 추가 (특정 날짜부터 남은 날짜 조회)
//
// 2026-01-21 김택권: weather 테이블 제거 마이그레이션
//   - fetchWeather() 메서드 삭제 (DB 조회)
//   - fetchWeatherByDate() 메서드 삭제 (DB 조회 래퍼)
//   - fetchWeatherFromApi() 메서드 삭제 (API→DB 저장)
//   - fetchWeatherDirect, fetchWeatherDirect8Days, fetchWeatherDirectFromDate만 유지
//   - OpenWeatherMap API 직접 호출만 지원
