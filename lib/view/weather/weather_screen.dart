import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_button.dart';
import 'package:table_now_app/model/weather.dart';
import 'package:table_now_app/model/store.dart';
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
  List<Store> _storeList = [];
  Store? _selectedStore;
  bool _isLoadingStores = false;
  
  // 날짜 지정 저장을 위한 상태 변수
  DateTime? _selectedDate;
  bool _overwrite = true;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 지점 리스트 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStores();
    });
  }

  /// 지점 리스트 가져오기
  Future<void> _loadStores() async {
    if (!mounted) return;
    setState(() {
      _isLoadingStores = true;
    });

    try {
      final stores = await ref
          .read(weatherNotifierProvider.notifier)
          .fetchStores();
      if (mounted) {
        setState(() {
          _storeList = stores;
          _isLoadingStores = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStores = false;
        });
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '지점 리스트를 가져오는 중 오류가 발생했습니다.',
        );
      }
    }
  }

  /// DB에서 저장된 날씨 데이터 불러오기
  Future<void> _loadWeatherFromDb() async {
    if (!mounted) return;
    if (_selectedStore == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '지점을 선택해주세요.',
      );
      return;
    }

    await ref
        .read(weatherNotifierProvider.notifier)
        .fetchWeather(storeSeq: _selectedStore!.store_seq);
  }

  /// 오늘 날씨를 OpenWeatherMap API에서 가져와서 DB에 저장
  Future<void> _saveTodayWeather() async {
    if (!mounted) return;
    if (_selectedStore == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '지점을 선택해주세요.',
      );
      return;
    }

    final success = await ref
        .read(weatherNotifierProvider.notifier)
        .fetchWeatherFromApi(storeSeq: _selectedStore!.store_seq);

    if (mounted) {
      if (success) {
        CustomCommonUtil.showSuccessSnackbar(
          context: context,
          title: '날씨 데이터 저장',
          message: '오늘 날씨가 성공적으로 저장되었습니다.',
        );
      } else {
        final errorMsg = ref.read(weatherNotifierProvider).errorMessage;
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: errorMsg ?? '오늘 날씨 저장에 실패했습니다.',
        );
      }
    }
  }

  /// 날짜를 지정하여 날씨를 OpenWeatherMap API에서 가져와서 DB에 저장
  Future<void> _saveWeatherWithDate() async {
    if (!mounted) return;
    if (_selectedStore == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '지점을 선택해주세요.',
      );
      return;
    }

    if (_selectedDate == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '날짜를 선택해주세요.',
      );
      return;
    }

    final success = await ref
        .read(weatherNotifierProvider.notifier)
        .fetchWeatherFromApi(
          storeSeq: _selectedStore!.store_seq,
          targetDate: _selectedDate,
          overwrite: _overwrite,
        );

    if (mounted) {
      if (success) {
        final dateStr =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
        CustomCommonUtil.showSuccessSnackbar(
          context: context,
          title: '날씨 데이터 저장',
          message: '$dateStr 날씨가 성공적으로 저장되었습니다.',
        );
      } else {
        final errorMsg = ref.read(weatherNotifierProvider).errorMessage;
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: errorMsg ?? '날씨 저장에 실패했습니다.',
        );
      }
    }
  }

  /// 날짜 선택 다이얼로그 표시
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 7)); // 최대 8일 (오늘 포함)

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: '날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
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
          // 새로고침 버튼 (날씨 데이터 다시 불러오기)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: (weatherState.isLoading || _selectedStore == null)
                ? null
                : () {
                    _loadWeatherFromDb();
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: mainDefaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: mainDefaultSpacing,
          children: [
            // 지점 선택 드롭다운
            Text('지점 선택', style: mainTitleStyle.copyWith(color: p.textPrimary)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: mainDefaultSpacing),
              decoration: BoxDecoration(
                color: p.cardBackground,
                borderRadius: mainSmallBorderRadius,
                border: Border.all(color: p.divider),
              ),
              child: _isLoadingStores
                  ? Padding(
                      padding: mainDefaultPadding,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<Store>(
                        value: _selectedStore,
                        hint: Text(
                          '지점을 선택하세요',
                          style: mainBodyTextStyle.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                        isExpanded: true,
                        items: _storeList.map((store) {
                          return DropdownMenuItem<Store>(
                            value: store,
                            child: Text(
                              store.store_description ?? store.store_address,
                              style: mainBodyTextStyle.copyWith(
                                color: p.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (Store? newValue) {
                          if (!mounted) return;
                          setState(() {
                            _selectedStore = newValue;
                          });
                          // 지점 선택 시 자동으로 날씨 데이터 불러오기
                          if (newValue != null) {
                            _loadWeatherFromDb();
                          } else {
                            // 지점 선택 해제 시 리스트 초기화
                            ref.read(weatherNotifierProvider.notifier).reset();
                          }
                        },
                      ),
                    ),
            ),

            // 오늘 날씨 넣기 버튼
            CustomButton(
              btnText: '오늘 날씨 넣기',
              onCallBack: (weatherState.isLoading || _selectedStore == null)
                  ? null
                  : _saveTodayWeather,
              buttonType: ButtonType.outlined,
            ),

            // 구분선
            Divider(color: p.divider, thickness: 1),

            // 날짜 지정 저장 섹션
            Text(
              '날짜 지정 저장',
              style: mainTitleStyle.copyWith(color: p.textPrimary),
            ),
            
            // 날짜 선택 버튼
            Container(
              padding: EdgeInsets.symmetric(horizontal: mainDefaultSpacing),
              decoration: BoxDecoration(
                color: p.cardBackground,
                borderRadius: mainSmallBorderRadius,
                border: Border.all(color: p.divider),
              ),
              child: InkWell(
                onTap: _selectDate,
                borderRadius: mainSmallBorderRadius,
                child: Padding(
                  padding: mainDefaultPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? '날짜를 선택하세요'
                            : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                        style: mainBodyTextStyle.copyWith(
                          color: _selectedDate == null
                              ? p.textSecondary
                              : p.textPrimary,
                        ),
                      ),
                      Icon(Icons.calendar_today,
                          size: 20, color: p.textSecondary),
                    ],
                  ),
                ),
              ),
            ),

            // Overwrite 옵션
            Container(
              padding: EdgeInsets.symmetric(horizontal: mainDefaultSpacing),
              decoration: BoxDecoration(
                color: p.cardBackground,
                borderRadius: mainSmallBorderRadius,
                border: Border.all(color: p.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '기존 데이터 덮어쓰기',
                      style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                    ),
                  ),
                  Switch(
                    value: _overwrite,
                    onChanged: (value) {
                      setState(() {
                        _overwrite = value;
                      });
                    },
                    activeColor: p.primary,
                  ),
                ],
              ),
            ),

            // 날짜 지정 저장 버튼
            CustomButton(
              btnText: '날짜 지정 저장',
              onCallBack: (weatherState.isLoading ||
                      _selectedStore == null ||
                      _selectedDate == null)
                  ? null
                  : _saveWeatherWithDate,
              buttonType: ButtonType.outlined,
            ),

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
                  spacing: mainSmallSpacing,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
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
            if (!weatherState.isLoading && weatherState.weatherList.isNotEmpty)
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
                    spacing: mainDefaultSpacing,
                    children: [
                      Icon(Icons.cloud_off, size: 64, color: p.textSecondary),
                      Text(
                        '날씨 데이터가 없습니다.\n지점을 선택하면 자동으로 불러옵니다.',
                        textAlign: TextAlign.center,
                        style: mainBodyTextStyle.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                      SizedBox(height: mainDefaultSpacing),
                      Text(
                        '오늘 날씨를 저장하려면\n"오늘 날씨 넣기" 버튼을 눌러주세요.',
                        textAlign: TextAlign.center,
                        style: mainSmallTextStyle.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
          spacing: mainDefaultSpacing,
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

            // 날씨 아이콘 및 상태
            Row(
              spacing: mainDefaultSpacing,
              children: [
                // 날씨 타입에 따른 아이콘 표시
                _getWeatherIcon(weather.weatherType, p.primary),

                // 날씨 상태
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: mainTinyPadding.vertical,
                    children: [
                      Text(
                        weather.weatherType,
                        style: mainBodyTextStyle.copyWith(
                          color: p.textPrimary,
                          fontSize: mainMediumTextStyle.fontSize! + 2, // 18
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
// 2026-01-16 김택권: 지점 선택 드롭다운 추가
//   - 지점 리스트를 드롭다운으로 표시
//   - 선택한 지점의 날씨 데이터만 조회 및 표시
//   - "받기!" 버튼으로 OpenWeatherMap API에서 날씨 데이터 가져오기 및 저장
//   - store_seq 기반 날씨 조회로 변경
//
// 2026-01-19: 버튼 기능 분리
//   - "받기!" 버튼: DB에서 저장된 날씨 데이터만 불러오기 (저장하지 않음)
//   - "오늘 날씨 넣기" 버튼 추가: 오늘 날씨를 OpenWeatherMap API에서 가져와서 DB에 저장 후 리스트 갱신
