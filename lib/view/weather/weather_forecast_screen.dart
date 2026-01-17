import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/weather.dart';
import 'package:table_now_app/theme/app_colors.dart';
import 'package:table_now_app/vm/weather_notifier.dart';

/// 날씨 예보 화면
///
/// OpenWeatherMap API에서 직접 8일치 날씨 예보를 가져와서 표시하는 화면입니다.
/// 기기의 현재 위치를 사용하여 날씨 데이터를 조회합니다.
class WeatherForecastScreen extends ConsumerStatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  ConsumerState<WeatherForecastScreen> createState() =>
      _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends ConsumerState<WeatherForecastScreen> {
  // 기본 좌표 (서울) - 위치 권한이 거부되었을 때 사용
  static const double _defaultLat = 37.5665;
  static const double _defaultLon = 126.9780;

  double? _currentLat;
  double? _currentLon;
  bool _isLoadingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 위치 가져오기 및 날씨 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocationAndFetchWeather();
    });
  }

  /// 현재 위치 가져오기 및 날씨 데이터 가져오기
  Future<void> _getCurrentLocationAndFetchWeather() async {
    if (kDebugMode) {
      print('📍 위치 가져오기 시작...');
    }

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // 위치 서비스 활성화 여부 확인
      if (kDebugMode) {
        print('📍 위치 서비스 활성화 여부 확인 중...');
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (kDebugMode) {
        print('📍 위치 서비스 활성화 상태: $serviceEnabled');
      }

      if (!serviceEnabled) {
        if (kDebugMode) {
          print('⚠️  위치 서비스가 비활성화되어 있습니다.');
        }
        setState(() {
          _locationError = '위치 서비스가 비활성화되어 있습니다.';
        });
        // 기본 좌표로 날씨 데이터 가져오기
        await _fetchWeather(_defaultLat, _defaultLon);
        // 날씨 데이터 가져오기 완료 후 로딩 상태 해제
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }

      // 위치 권한 확인
      if (kDebugMode) {
        print('📍 위치 권한 확인 중...');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (kDebugMode) {
        print('📍 현재 위치 권한 상태: $permission');
      }

      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('📍 위치 권한이 거부되어 있음. 권한 요청 중...');
        }
        // 권한 요청
        permission = await Geolocator.requestPermission();
        
        if (kDebugMode) {
          print('📍 권한 요청 후 상태: $permission');
        }

        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('⚠️  위치 권한이 거부되었습니다.');
          }
          setState(() {
            _locationError = '위치 권한이 거부되었습니다. 기본 위치(서울)를 사용합니다.';
          });
          // 기본 좌표로 날씨 데이터 가져오기
          await _fetchWeather(_defaultLat, _defaultLon);
          // 날씨 데이터 가져오기 완료 후 로딩 상태 해제
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('⚠️  위치 권한이 영구적으로 거부되었습니다.');
        }
        setState(() {
          _locationError = '위치 권한이 영구적으로 거부되었습니다. 기본 위치(서울)를 사용합니다.';
        });
        // 기본 좌표로 날씨 데이터 가져오기
        await _fetchWeather(_defaultLat, _defaultLon);
        // 날씨 데이터 가져오기 완료 후 로딩 상태 해제
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }

      // 현재 위치 가져오기
      // 먼저 마지막으로 알려진 위치를 시도하고, 없으면 현재 위치 가져오기
      Position? position;
      
      if (kDebugMode) {
        print('📍 마지막으로 알려진 위치 확인 중...');
      }
      
      try {
        // 먼저 마지막으로 알려진 위치를 빠르게 가져오기 시도
        position = await Geolocator.getLastKnownPosition().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            if (kDebugMode) {
              print('📍 마지막으로 알려진 위치 없음. 현재 위치 가져오기 시도...');
            }
            return null;
          },
        );
        
        if (position != null && kDebugMode) {
          print('✅ 마지막으로 알려진 위치 사용: lat=${position.latitude}, lon=${position.longitude}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('📍 마지막으로 알려진 위치 가져오기 실패: $e');
        }
      }
      
      // 마지막으로 알려진 위치가 없으면 현재 위치 가져오기 시도
      if (position == null) {
        if (kDebugMode) {
          print('📍 현재 위치 가져오기 시작... (타임아웃: 15초)');
        }
        
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low, // low로 변경하여 더 빠른 응답
            timeLimit: const Duration(seconds: 15), // Geolocator 내부 타임아웃
          ).timeout(
            const Duration(seconds: 15), // 외부 타임아웃도 15초로 증가
            onTimeout: () {
              if (kDebugMode) {
                print('⏱️  위치 가져오기 타임아웃 발생 (15초 초과)');
                print('💡 에뮬레이터에서는 위치를 가져오는 데 시간이 오래 걸릴 수 있습니다.');
                print('💡 Android Studio의 Extended Controls에서 위치를 설정하거나 기본 좌표를 사용합니다.');
              }
              throw TimeoutException('위치를 가져오는 시간이 초과되었습니다.');
            },
          );
        } catch (e) {
          if (kDebugMode) {
            print('❌ 현재 위치 가져오기 실패: $e');
          }
          position = null; // 실패 시 null로 설정
        }
      }

      // 위치를 가져오지 못한 경우 기본 좌표 사용
      final finalPosition = position;
      if (finalPosition == null) {
        if (kDebugMode) {
          print('⚠️  위치를 가져오지 못했습니다. 기본 좌표(서울)를 사용합니다.');
        }
        setState(() {
          _locationError = '위치를 가져오지 못했습니다. 기본 위치(서울)를 사용합니다.';
        });
        await _fetchWeather(_defaultLat, _defaultLon);
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }

      // finalPosition이 null이 아니므로 안전하게 사용 가능
      if (kDebugMode) {
        print('✅ 위치 가져오기 성공: lat=${finalPosition.latitude}, lon=${finalPosition.longitude}');
        print('📍 정확도: ${finalPosition.accuracy}m');
        print('📍 고도: ${finalPosition.altitude}m');
      }

      setState(() {
        _currentLat = finalPosition.latitude;
        _currentLon = finalPosition.longitude;
        _locationError = null;
        // 날씨 데이터를 가져오는 동안에도 로딩 상태 유지
        // _isLoadingLocation은 _fetchWeather 완료 후 false로 설정됨
      });

      // 현재 위치로 날씨 데이터 가져오기
      if (kDebugMode) {
        print('🌤️  날씨 데이터 가져오기 시작...');
      }
      await _fetchWeather(_currentLat!, _currentLon!);
      
      if (kDebugMode) {
        print('✅ 날씨 데이터 가져오기 완료');
      }
      
      // 날씨 데이터 가져오기 완료 후 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
      
      // 날씨 데이터 가져오기 완료 후 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ 위치 가져오기 오류 발생: $e');
        print('📍 스택 트레이스: $stackTrace');
        
        // 에러 타입별 상세 정보
        if (e is TimeoutException) {
          print('⏱️  타임아웃 에러: 위치를 가져오는 데 시간이 너무 오래 걸렸습니다.');
          print('💡 에뮬레이터에서는 GPS 신호를 받을 수 없어 위치 가져오기가 실패할 수 있습니다.');
          print('💡 Android Studio Extended Controls > Location에서 위치를 설정하거나');
          print('💡 ADB 명령어로 위치 설정: adb emu geo fix <경도> <위도>');
        } else if (e.toString().contains('PERMISSION_DENIED')) {
          print('🚫 권한 거부 에러: 위치 권한이 거부되었습니다.');
        } else if (e.toString().contains('LOCATION_SERVICES_DISABLED')) {
          print('📴 위치 서비스 비활성화: 위치 서비스가 꺼져 있습니다.');
        } else if (e.toString().contains('LOCATION_SERVICE_UNAVAILABLE')) {
          print('🔌 위치 서비스 사용 불가: 위치 서비스를 사용할 수 없습니다.');
        }
      }

      setState(() {
        String errorMessage = '위치를 가져오는 중 오류가 발생했습니다. 기본 위치(서울)를 사용합니다.';
        
        // 에러 타입에 따른 더 구체적인 메시지
        if (e is TimeoutException) {
          errorMessage = '위치를 가져오는 시간이 초과되었습니다. 기본 위치(서울)를 사용합니다.';
        } else if (e.toString().contains('PERMISSION_DENIED')) {
          errorMessage = '위치 권한이 거부되었습니다. 기본 위치(서울)를 사용합니다.';
        } else if (e.toString().contains('LOCATION_SERVICES_DISABLED')) {
          errorMessage = '위치 서비스가 비활성화되어 있습니다. 기본 위치(서울)를 사용합니다.';
        }
        
        _locationError = errorMessage;
      });
      
      // 기본 좌표로 날씨 데이터 가져오기
      if (kDebugMode) {
        print('📍 기본 좌표로 날씨 데이터 가져오기: lat=$_defaultLat, lon=$_defaultLon');
      }
      await _fetchWeather(_defaultLat, _defaultLon);
      
      // 날씨 데이터 가져오기 완료 후 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  /// 날씨 데이터 가져오기
  Future<void> _fetchWeather(double lat, double lon) async {
    try {
      await ref
          .read(weatherNotifierProvider.notifier)
          .fetchWeatherDirect8Days(lat: lat, lon: lon);
    } catch (e) {
      // 날씨 데이터 가져오기 실패 시에도 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
      // 에러는 weatherState.errorMessage에 표시됨
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final weatherState = ref.watch(weatherNotifierProvider);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: const Text('날씨 예보'),
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: (weatherState.isLoading || _isLoadingLocation)
                ? null
                : () {
                    _getCurrentLocationAndFetchWeather();
                  },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _getCurrentLocationAndFetchWeather,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: mainDefaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: mainDefaultSpacing,
            children: [
              // 위치 정보 표시
              if (_currentLat != null && _currentLon != null)
                Container(
                  padding: mainDefaultPadding,
                  decoration: BoxDecoration(
                    color: p.cardBackground,
                    borderRadius: mainSmallBorderRadius,
                    border: Border.all(color: p.divider),
                  ),
                  child: Row(
                    spacing: mainSmallSpacing,
                    children: [
                      Icon(Icons.location_on, color: p.primary, size: 20),
                      Expanded(
                        child: Text(
                          '현재 위치: ${_currentLat!.toStringAsFixed(4)}, ${_currentLon!.toStringAsFixed(4)}',
                          style: mainSmallTextStyle.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 위치 오류 메시지
              if (_locationError != null)
                Container(
                  padding: mainDefaultPadding,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: mainSmallBorderRadius,
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    spacing: mainSmallSpacing,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      Expanded(
                        child: Text(
                          _locationError!,
                          style: mainSmallTextStyle.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 로딩 중
              if (weatherState.isLoading || _isLoadingLocation)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(mainLargeSpacing * 1.33), // 32.0
                    child: const CircularProgressIndicator(),
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
                          '날씨 데이터가 없습니다.',
                          textAlign: TextAlign.center,
                          style: mainBodyTextStyle.copyWith(
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
                      borderRadius: BorderRadius.circular(4),
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
// 작성일: 2026-01-18
// 작성자: AI Assistant
// 설명: 날씨 예보 화면 - OpenWeatherMap API에서 직접 8일치 날씨 예보를 가져와서 표시
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-18: 초기 생성
//   - WeatherForecastScreen 위젯 생성
//   - 화면 진입 시 자동으로 8일치 날씨 데이터 가져오기
//   - 상단 새로고침 버튼으로 데이터 갱신
//   - Pull-to-refresh 기능 추가
//   - 날씨 카드 UI 구현 (날짜, 아이콘, 온도 표시)
