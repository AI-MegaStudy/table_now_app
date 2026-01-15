import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_button.dart';
import 'package:table_now_app/model/weather.dart';
import 'package:table_now_app/theme/app_colors.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/vm/weather_notifier.dart';

/// 날씨 화면
///
/// 날씨 데이터를 표시하는 화면입니다.
class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 날씨 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherNotifierProvider.notifier).fetchWeather();
    });
  }

  /// OpenWeatherMap API에서 데이터 가져오기
  Future<void> _fetchFromApi() async {
    final success = await ref
        .read(weatherNotifierProvider.notifier)
        .fetchWeatherFromApi();

    if (mounted) {
      if (success) {
        CustomCommonUtil.showSuccessSnackbar(
          context: context,
          title: '날씨 데이터 업데이트',
          message: '날씨 데이터가 성공적으로 업데이트되었습니다.',
        );
      } else {
        final errorMsg = ref.read(weatherNotifierProvider).errorMessage;
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: errorMsg ?? '날씨 데이터 업데이트에 실패했습니다.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final weatherState = ref.watch(weatherNotifierProvider);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: const Text('날씨'),
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: weatherState.isLoading
                ? null
                : () {
                    ref.read(weatherNotifierProvider.notifier).fetchWeather();
                  },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(weatherNotifierProvider.notifier).fetchWeather();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: mainDefaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // OpenWeatherMap API에서 데이터 가져오기 버튼
              CustomButton(
                btnText: 'OpenWeatherMap에서 날씨 데이터 가져오기',
                onCallBack: weatherState.isLoading ? null : _fetchFromApi,
                buttonType: ButtonType.outlined,
              ),
              mainLargeVerticalSpacing,

              // 로딩 중
              if (weatherState.isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(mainLargeSpacing * 1.33), // 32.0
                    child: CircularProgressIndicator(),
                  ),
                ),

              // 에러 메시지
              if (weatherState.errorMessage != null && !weatherState.isLoading)
                Container(
                  padding: mainDefaultPadding,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: mainSmallBorderRadius,
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      SizedBox(width: mainSmallSpacing),
                      Expanded(
                        child: Text(
                          weatherState.errorMessage!,
                          style: mainBodyTextStyle.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 날씨 데이터 목록
              if (!weatherState.isLoading &&
                  weatherState.weatherList.isNotEmpty)
                ...weatherState.weatherList.map(
                  (weather) => _buildWeatherCard(context, weather, p),
                ),

              // 데이터 없음
              if (!weatherState.isLoading &&
                  weatherState.weatherList.isEmpty &&
                  weatherState.errorMessage == null)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(mainLargeSpacing * 1.33), // 32.0
                    child: Column(
                      children: [
                        Icon(Icons.cloud_off, size: 64, color: p.textSecondary),
                        mainDefaultVerticalSpacing,
                        Text(
                          '날씨 데이터가 없습니다.',
                          style: mainBodyTextStyle.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                        mainDefaultVerticalSpacing,
                        CustomButton(
                          btnText: '데이터 가져오기',
                          onCallBack: () {
                            ref
                                .read(weatherNotifierProvider.notifier)
                                .fetchWeather();
                          },
                          buttonType: ButtonType.elevated,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 날씨 타입에 따른 아이콘 반환
  Widget _getWeatherIcon(String weatherType, Color color) {
    IconData iconData;

    switch (weatherType) {
      case '맑음':
        iconData = Icons.wb_sunny;
        break;
      case '흐림':
        iconData = Icons.wb_cloudy;
        break;
      case '비':
        iconData = Icons.grain;
        break;
      case '이슬비':
        iconData = Icons.grain;
        break;
      case '천둥번개':
        iconData = Icons.flash_on;
        break;
      case '눈':
        iconData = Icons.ac_unit;
        break;
      case '안개':
      case '짙은 안개':
      case '연무':
      case '먼지':
      case '모래':
      case '화산재':
        iconData = Icons.blur_on;
        break;
      case '돌풍':
      case '토네이도':
        iconData = Icons.wb_twilight;
        break;
      default:
        iconData = Icons.wb_sunny;
    }

    return Icon(iconData, size: 48, color: color);
  }

  /// 날씨 카드 위젯 생성
  Widget _buildWeatherCard(
    BuildContext context,
    Weather weather,
    AppColorScheme p,
  ) {
    final isToday = weather.isToday;
    final isTomorrow = weather.isTomorrow;

    String dateLabel;
    if (isToday) {
      dateLabel = '오늘';
    } else if (isTomorrow) {
      dateLabel = '내일';
    } else {
      dateLabel =
          '${weather.weatherDatetime.month}/${weather.weatherDatetime.day}';
    }

    return Card(
      margin: EdgeInsets.only(bottom: mainDefaultSpacing),
      child: Padding(
        padding: mainDefaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 라벨
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateLabel,
                  style: mainTitleStyle.copyWith(
                    color: p.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isToday)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: mainSmallSpacing,
                      vertical: mainTinyPadding.vertical,
                    ),
                    decoration: BoxDecoration(
                      color: p.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        4,
                      ), // 매우 작은 radius는 유지
                    ),
                    child: Text(
                      '오늘',
                      style: mainSmallTextStyle.copyWith(
                        color: p.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            mainDefaultVerticalSpacing,

            // 날씨 아이콘 및 상태
            Row(
              children: [
                // 날씨 타입에 따른 아이콘 표시
                _getWeatherIcon(weather.weatherType, p.primary),
                SizedBox(width: mainDefaultSpacing),

                // 날씨 상태
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.weatherType,
                        style: mainBodyTextStyle.copyWith(
                          color: p.textPrimary,
                          fontSize: mainMediumTextStyle.fontSize! + 2, // 18
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: mainTinyPadding.vertical),
                      Text(
                        '${weather.weatherLow.toStringAsFixed(1)}° / ${weather.weatherHigh.toStringAsFixed(1)}°',
                        style: mainBodyTextStyle.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: 날씨 화면 - 날씨 데이터 표시 및 OpenWeatherMap API 연동
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - WeatherScreen 위젯 생성
//   - 날씨 데이터 목록 표시
//   - OpenWeatherMap API 연동 버튼 추가
//   - Pull-to-refresh 기능 추가
//   - 로딩 상태 및 에러 처리
//   - 날씨 카드 UI 구현 (날짜, 아이콘, 온도 표시)
//
// 2026-01-15 김택권: 날씨 아이콘 로컬 표시로 변경
//   - 네트워크 이미지 대신 Material Icons 사용
//   - weather_type에 따라 적절한 아이콘 매핑 함수 추가 (_getWeatherIcon)
//   - DB에 아이콘 저장하지 않고 프론트엔드에서만 표시
