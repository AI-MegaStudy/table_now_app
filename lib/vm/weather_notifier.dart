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
/// 날씨 데이터를 관리하고 API를 호출하는 Notifier입니다.
class WeatherNotifier extends Notifier<WeatherState> {
  // API 기본 URL (한 번만 계산하여 재사용)
  late final String _apiBaseUrl = getApiBaseUrl();

  @override
  WeatherState build() {
    return WeatherState();
  }

  /// 날씨 데이터 가져오기
  ///
  /// [storeSeq]가 제공되면 해당 식당의 날씨만 조회합니다.
  /// [startDate]와 [endDate]가 제공되면 해당 기간의 데이터만 조회합니다.
  /// 제공되지 않으면 전체 데이터를 조회합니다.
  Future<void> fetchWeather({
    int? storeSeq,
    String? startDate,
    String? endDate,
  }) async {
    // 로딩 시작
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      String url;

      // store_seq가 제공되면 해당 식당의 날씨만 조회
      if (storeSeq != null) {
        url = '$_apiBaseUrl/api/weather?store_seq=$storeSeq';

        // 쿼리 파라미터 추가
        if (startDate != null && endDate != null) {
          url += '&start_date=$startDate&end_date=$endDate';
        }
      } else {
        // store_seq가 없으면 에러
        state = state.copyWith(isLoading: false, errorMessage: '식당을 선택해주세요.');
        return;
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
        functionName: 'WeatherNotifier.fetchWeather',
        error: e.toString(),
        url: '$_apiBaseUrl/api/weather',
      );
    }
  }

  /// 특정 날짜의 날씨 데이터 가져오기
  Future<void> fetchWeatherByDate(DateTime date, {int? storeSeq}) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await fetchWeather(
      storeSeq: storeSeq,
      startDate: dateStr,
      endDate: dateStr,
    );
  }

  /// OpenWeatherMap API에서 날씨 데이터 가져오기 및 저장
  ///
  /// 백엔드에서 OpenWeatherMap API를 호출하여 데이터를 가져오고 저장합니다.
  /// [storeSeq]를 받아서 해당 식당의 store_lat, store_lng를 사용합니다.
  Future<bool> fetchWeatherFromApi({
    required int storeSeq,
    bool overwrite = true,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final url = Uri.parse('$_apiBaseUrl/api/weather/fetch-from-api');

      final requestBody = <String, String>{
        'store_seq': storeSeq.toString(),
        'overwrite': overwrite.toString(),
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));

        if (responseData['result'] == 'OK') {
          // 저장 성공 후 날씨 데이터 다시 가져오기
          await fetchWeather(storeSeq: storeSeq);
          return true;
        } else {
          final errorMsg = responseData['errorMsg'] ?? '날씨 데이터 저장에 실패했습니다.';
          state = state.copyWith(isLoading: false, errorMessage: errorMsg);
          return false;
        }
      } else {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        final errorMsg =
            responseData['errorMsg'] ??
            '서버 오류가 발생했습니다. (${response.statusCode})';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
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
        functionName: 'WeatherNotifier.fetchWeatherFromApi',
        error: e.toString(),
        url: '$_apiBaseUrl/api/weather/fetch-from-api',
      );
      return false;
    }
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
//   - 에러 처리 및 로딩 상태 관리
// 2026-01-16 김택권: store_seq 기반 날씨 조회로 변경
//   - fetchWeather에 store_seq 파라미터 추가 (필수)
//   - fetchWeatherFromApi에 store_seq 파라미터 추가 (필수)
//   - fetchStores 메서드 추가 (Store 리스트 조회)
