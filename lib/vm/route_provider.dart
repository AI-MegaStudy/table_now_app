import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../model/route_model.dart';

/// 경로 정보를 관리하는 Notifier 클래스
/// Google Directions API를 사용하여 두 지점 간의 경로 정보를 가져옴
class RouteNotifier extends AsyncNotifier<RouteModel?> {
  /// Google Directions API 키
  /// iOS: Firebase가 자동 생성한 키 사용 (AIzaSyDGH3b2j4ZZ5PA0_Bz-lxLRYSRrysCqBFw)
  /// Android: 별도 키 필요 (AIzaSyBLa9JRNmTDkf_1yPqwPsI4uG3xBexyWLY)
  /// 실제 사용 시 환경 변수나 설정 파일에서 관리하는 것을 권장합니다
  static const String _apiKey = 'AIzaSyDGH3b2j4ZZ5PA0_Bz-lxLRYSRrysCqBFw';

  @override
  Future<RouteModel?> build() async {
    // 초기 상태는 null로 설정
    return null;
  }

  /// 두 지점 간의 경로 정보를 가져오는 메서드
  /// [startLat] 출발지 위도
  /// [startLng] 출발지 경도
  /// [endLat] 도착지 위도
  /// [endLng] 도착지 경도
  Future<void> fetchRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    // 로딩 상태로 변경
    state = const AsyncValue.loading();

    try {
      // 디버깅: 좌표 출력
      print('경로 요청: 출발지($startLat, $startLng) -> 도착지($endLat, $endLng)');

      // Google Directions API URL 생성 (Uri.https 사용)
      // 좌표를 더 정확하게 전달하기 위해 소수점 자릿수 제한
      final origin = '${startLat.toStringAsFixed(7)},${startLng.toStringAsFixed(7)}';
      final destination = '${endLat.toStringAsFixed(7)},${endLng.toStringAsFixed(7)}';
      
      // Directions API 파라미터 설정
      final params = <String, String>{
        'origin': origin,
        'destination': destination,
        'key': _apiKey,
        'language': 'ko',
        'region': 'kr', // 한국 지역 지정
      };
      
      // 먼저 driving 모드로 시도
      params['mode'] = 'driving';
      
      final url = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        params,
      );

      print('API URL: $url');

      // API 요청
      final response = await http.get(url);

      // 응답 전체 출력 (디버깅용)
      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // API 응답 상태 확인
        final status = data['status'];

        // 디버깅을 위한 로그 출력
        print('Directions API Status: $status');
        if (data['error_message'] != null) {
          print('Directions API Error: ${data['error_message']}');
        }
        if (data['geocoded_waypoints'] != null) {
          print('Geocoded Waypoints: ${data['geocoded_waypoints']}');
          for (var i = 0; i < data['geocoded_waypoints'].length; i++) {
            final waypoint = data['geocoded_waypoints'][i];
            print('Waypoint $i: geocoded_status=${waypoint['geocoded_status']}, types=${waypoint['types']}, place_id=${waypoint['place_id']}');
            
            // geocoded_status가 null이거나 비어있는 경우 경고
            if (waypoint['geocoded_status'] == null || waypoint.isEmpty) {
              print('⚠️ 경고: Waypoint $i가 geocode되지 않았습니다. 좌표가 도로에서 멀리 떨어져 있을 수 있습니다.');
            }
          }
        } else {
          print('⚠️ 경고: geocoded_waypoints가 null입니다.');
        }
        if (data['available_travel_modes'] != null) {
          print('Available Travel Modes: ${data['available_travel_modes']}');
        }

        // ZERO_RESULTS이고 available_travel_modes에 TRANSIT이 있으면 대중교통 모드로 재시도
        if (status == 'ZERO_RESULTS' && 
            data['available_travel_modes'] != null &&
            data['available_travel_modes'].contains('TRANSIT')) {
          print('자동차 경로를 찾을 수 없어 대중교통 모드로 재시도합니다.');
          
          // 대중교통 모드로 재시도
          final transitParams = <String, String>{
            'origin': origin,
            'destination': destination,
            'key': _apiKey,
            'language': 'ko',
            'region': 'kr',
            'mode': 'transit', // 대중교통 모드
          };
          
          final transitUrl = Uri.https(
            'maps.googleapis.com',
            '/maps/api/directions/json',
            transitParams,
          );
          
          print('Transit API URL: $transitUrl');
          final transitResponse = await http.get(transitUrl);
          
          print('Transit HTTP Status Code: ${transitResponse.statusCode}');
          print('Transit Response Body: ${transitResponse.body}');
          
          if (transitResponse.statusCode == 200) {
            final transitData = json.decode(transitResponse.body);
            final transitStatus = transitData['status'];
            
            print('Transit API Status: $transitStatus');
            
            // Transit geocoded_waypoints 확인
            if (transitData['geocoded_waypoints'] != null) {
              for (var i = 0; i < transitData['geocoded_waypoints'].length; i++) {
                final waypoint = transitData['geocoded_waypoints'][i];
                print('Transit Waypoint $i: geocoded_status=${waypoint['geocoded_status']}, types=${waypoint['types']}');
              }
            }
            
            if (transitStatus == 'OK' &&
                transitData['routes'] != null &&
                transitData['routes'].isNotEmpty) {
              // 대중교통 경로 처리
              final route = transitData['routes'][0];
              final leg = route['legs'][0];
              
              // Polyline 디코딩
              final polyline = route['overview_polyline']['points'];
              final polylinePointsInstance = PolylinePoints();
              final decodedPolyline = polylinePointsInstance.decodePolyline(polyline);
              
              final polylinePoints = decodedPolyline.map((point) {
                return {'latitude': point.latitude, 'longitude': point.longitude};
              }).toList();
              
              // 단계별 안내 정보 추출
              final steps = <RouteStep>[];
              if (leg['steps'] != null) {
                for (var stepData in leg['steps']) {
                  steps.add(RouteStep(
                    instruction: stepData['html_instructions']?.toString().replaceAll(RegExp(r'<[^>]*>'), '') ?? 
                                stepData['instructions'] ?? '',
                    distanceInMeters: stepData['distance']['value'],
                    durationInSeconds: stepData['duration']['value'],
                    travelMode: stepData['travel_mode'] ?? 'transit',
                  ));
                }
              }
              
              final routeModel = RouteModel(
                startLatitude: startLat,
                startLongitude: startLng,
                endLatitude: endLat,
                endLongitude: endLng,
                polylinePoints: polylinePoints,
                distanceInMeters: leg['distance']['value'],
                durationInSeconds: leg['duration']['value'],
                travelMode: 'transit',
                steps: steps,
              );
              
              state = AsyncValue.data(routeModel);
              return;
            } else {
              // 대중교통 모드에서도 실패한 경우
              print('⚠️ 대중교통 모드에서도 경로를 찾을 수 없습니다. Status: $transitStatus');
              if (transitData['error_message'] != null) {
                print('Transit Error Message: ${transitData['error_message']}');
              }
            }
          }
        }
        
        if (status == 'OK' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          // Polyline 디코딩 (flutter_polyline_points 패키지 사용)
          final polyline = route['overview_polyline']['points'];
          final polylinePointsInstance = PolylinePoints();
          final decodedPolyline = polylinePointsInstance.decodePolyline(
            polyline,
          );

          // 좌표 리스트로 변환
          final polylinePoints = decodedPolyline.map((point) {
            return {'latitude': point.latitude, 'longitude': point.longitude};
          }).toList();

          // 단계별 안내 정보 추출
          final steps = <RouteStep>[];
          if (leg['steps'] != null) {
            for (var stepData in leg['steps']) {
              steps.add(RouteStep(
                instruction: stepData['html_instructions']?.toString().replaceAll(RegExp(r'<[^>]*>'), '') ?? 
                            stepData['instructions'] ?? '',
                distanceInMeters: stepData['distance']['value'],
                durationInSeconds: stepData['duration']['value'],
                travelMode: stepData['travel_mode'] ?? 'driving',
              ));
            }
          }

          // 이동 방식 확인 (요청한 mode 또는 경로의 기본 이동 방식)
          final travelMode = params['mode'] ?? 'driving';

          // RouteModel 생성
          final routeModel = RouteModel(
            startLatitude: startLat,
            startLongitude: startLng,
            endLatitude: endLat,
            endLongitude: endLng,
            polylinePoints: polylinePoints,
            distanceInMeters: leg['distance']['value'],
            durationInSeconds: leg['duration']['value'],
            travelMode: travelMode,
            steps: steps,
          );

          // 상태 업데이트
          state = AsyncValue.data(routeModel);
        } else {
          // API 응답 오류 처리
          String errorMessage;

          if (status == 'ZERO_RESULTS') {
            errorMessage =
                '출발지와 도착지 사이에 경로를 찾을 수 없습니다.\n'
                '출발지: ($startLat, $startLng)\n'
                '도착지: ($endLat, $endLng)\n'
                '두 지점이 너무 가깝거나 도로가 없는 지역일 수 있습니다.';
          } else if (status == 'NOT_FOUND') {
            errorMessage = '출발지 또는 도착지를 찾을 수 없습니다.';
          } else if (status == 'REQUEST_DENIED') {
            errorMessage = 'API 요청이 거부되었습니다. API 키 설정을 확인해주세요.';
          } else {
            errorMessage =
                data['error_message'] ?? '경로를 찾을 수 없습니다. (Status: $status)';
          }

          print('Directions API 실패: $errorMessage');
          throw Exception(errorMessage);
        }
      } else {
        final errorBody = response.body;
        print('HTTP Error ${response.statusCode}: $errorBody');
        throw Exception(
          '경로 정보를 가져오는데 실패했습니다: ${response.statusCode}\n$errorBody',
        );
      }
    } catch (e) {
      // 에러 상태로 변경
      print('Route fetch error: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 경로 정보 초기화
  void clearRoute() {
    state = const AsyncValue.data(null);
  }
}

/// RouteNotifier를 제공하는 Provider
final routeProvider = AsyncNotifierProvider<RouteNotifier, RouteModel?>(
  RouteNotifier.new,
);
