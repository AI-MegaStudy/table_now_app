/// 경로 정보를 담는 모델 클래스
/// Google Directions API 응답에서 경로 정보를 추출하여 저장
class RouteModel {
  /// 출발지 좌표 (위도, 경도)
  final double startLatitude;
  final double startLongitude;

  /// 도착지 좌표 (위도, 경도)
  final double endLatitude;
  final double endLongitude;

  /// 경로를 구성하는 좌표 리스트 (polyline을 디코딩한 결과)
  final List<Map<String, double>> polylinePoints;

  /// 총 거리 (미터 단위)
  final int distanceInMeters;

  /// 총 소요 시간 (초 단위)
  final int durationInSeconds;

  /// 이동 방식 (driving, walking, transit, bicycling)
  final String travelMode;

  /// 경로 단계별 안내 정보 리스트
  final List<RouteStep> steps;

  /// 이동 방식을 한국어로 변환
  String get travelModeText {
    switch (travelMode.toLowerCase()) {
      case 'driving':
        return '자동차';
      case 'walking':
        return '도보';
      case 'transit':
        return '대중교통';
      case 'bicycling':
        return '자전거';
      default:
        return travelMode;
    }
  }

  /// 거리를 읽기 쉬운 형식으로 변환 (예: "1.5 km")
  String get distanceText {
    if (distanceInMeters < 1000) {
      return '$distanceInMeters m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// 소요 시간을 읽기 쉬운 형식으로 변환 (예: "15분")
  String get durationText {
    final minutes = durationInSeconds ~/ 60;
    final hours = minutes ~/ 60;
    if (hours > 0) {
      return '$hours시간 ${minutes % 60}분';
    } else {
      return '$minutes분';
    }
  }

  RouteModel({
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.polylinePoints,
    required this.distanceInMeters,
    required this.durationInSeconds,
    this.travelMode = 'driving',
    this.steps = const [],
  });

  /// JSON 데이터로부터 RouteModel 인스턴스 생성
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      startLatitude: json['startLatitude']?.toDouble() ?? 0.0,
      startLongitude: json['startLongitude']?.toDouble() ?? 0.0,
      endLatitude: json['endLatitude']?.toDouble() ?? 0.0,
      endLongitude: json['endLongitude']?.toDouble() ?? 0.0,
      polylinePoints: List<Map<String, double>>.from(
        json['polylinePoints'] ?? [],
      ),
      distanceInMeters: json['distanceInMeters'] ?? 0,
      durationInSeconds: json['durationInSeconds'] ?? 0,
      travelMode: json['travelMode'] ?? 'driving',
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map((step) => RouteStep.fromJson(step))
              .toList() ??
          [],
    );
  }

  /// RouteModel을 JSON 형식으로 변환
  Map<String, dynamic> toJson() {
    return {
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'polylinePoints': polylinePoints,
      'distanceInMeters': distanceInMeters,
      'durationInSeconds': durationInSeconds,
      'travelMode': travelMode,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
}

/// 경로의 단계별 안내 정보를 담는 클래스
class RouteStep {
  /// 안내 문구 (예: "서울시청 방면으로 우회전")
  final String instruction;

  /// 이 단계의 거리 (미터 단위)
  final int distanceInMeters;

  /// 이 단계의 소요 시간 (초 단위)
  final int durationInSeconds;

  /// 이동 방식
  final String travelMode;

  RouteStep({
    required this.instruction,
    required this.distanceInMeters,
    required this.durationInSeconds,
    this.travelMode = 'driving',
  });

  /// 거리 텍스트
  String get distanceText {
    if (distanceInMeters < 1000) {
      return '$distanceInMeters m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// 소요 시간 텍스트
  String get durationText {
    final minutes = durationInSeconds ~/ 60;
    if (minutes == 0) {
      return '$durationInSeconds초';
    } else {
      return '$minutes분';
    }
  }

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] ?? '',
      distanceInMeters: json['distanceInMeters'] ?? 0,
      durationInSeconds: json['durationInSeconds'] ?? 0,
      travelMode: json['travelMode'] ?? 'driving',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'distanceInMeters': distanceInMeters,
      'durationInSeconds': durationInSeconds,
      'travelMode': travelMode,
    };
  }
}
