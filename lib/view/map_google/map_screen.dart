import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../vm/location_provider.dart';
import '../../vm/route_provider.dart';
import '../../model/route_model.dart';
import '../../utils/common_app_bar.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';

/// 목적지 정보를 담는 클래스 (Route Arguments용)
class DestinationArguments {
  /// 도착지 위도
  final double latitude;

  /// 도착지 경도
  final double longitude;

  /// 도착지 이름 (선택사항)
  final String? name;

  DestinationArguments({
    required this.latitude,
    required this.longitude,
    this.name,
  });

  /// Map으로부터 생성
  factory DestinationArguments.fromMap(Map<String, dynamic> map) {
    return DestinationArguments(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      name: map['name'] as String?,
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (name != null) 'name': name,
    };
  }
}

/// Google Maps를 표시하고 경로를 그리는 화면 위젯
class MapScreen extends ConsumerStatefulWidget {
  /// 도착지 위도 (선택사항 - Route Arguments가 우선)
  final double? destinationLatitude;

  /// 도착지 경도 (선택사항 - Route Arguments가 우선)
  final double? destinationLongitude;

  /// 도착지 이름 (선택사항)
  final String? destinationName;

  const MapScreen({
    super.key,
    this.destinationLatitude,
    this.destinationLongitude,
    this.destinationName,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  /// Google Maps 컨트롤러
  GoogleMapController? _mapController;

  /// 출발지 마커
  Marker? _startMarker;

  /// 도착지 마커
  Marker? _endMarker;

  /// 경로를 그리는 Polyline
  Set<Polyline> _polylines = {};

  /// 목적지 정보 (Route Arguments 또는 생성자 값)
  DestinationArguments? _destination;

  /// Route Arguments 로드 여부 (한 번만 로드하기 위해)
  bool _destinationLoaded = false;

  @override
  void initState() {
    super.initState();
    // 화면이 로드되면 현재 위치 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Route Arguments는 didChangeDependencies에서 로드
    // (context가 사용 가능한 상태가 된 후)
    if (!_destinationLoaded) {
      _loadDestinationFromArguments();
      _destinationLoaded = true;
    }
  }

  /// Route Arguments에서 목적지 정보 로드
  void _loadDestinationFromArguments() {
    // Route Arguments 확인
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments != null) {
      // Map 형태로 전달된 경우
      if (arguments is Map<String, dynamic>) {
        _destination = DestinationArguments.fromMap(arguments);
      }
      // DestinationArguments 객체로 전달된 경우
      else if (arguments is DestinationArguments) {
        _destination = arguments;
      }
    }

    // Route Arguments가 없으면 생성자 값 사용
    if (_destination == null &&
        widget.destinationLatitude != null &&
        widget.destinationLongitude != null) {
      _destination = DestinationArguments(
        latitude: widget.destinationLatitude!,
        longitude: widget.destinationLongitude!,
        name: widget.destinationName,
      );
    }
  }

  /// 목적지 위도 가져오기
  double? get _destinationLatitude => _destination?.latitude;

  /// 목적지 경도 가져오기
  double? get _destinationLongitude => _destination?.longitude;

  /// 목적지 이름 가져오기
  String? get _destinationName => _destination?.name ?? widget.destinationName;

  /// 현재 위치 초기화 및 경로 가져오기
  /// [forceRefresh] true이면 위치를 강제로 다시 가져옴
  Future<void> _initializeLocation({bool forceRefresh = false}) async {
    try {
      // 현재 위치 가져오기 (강제 새로고침 옵션 포함)
      await ref
          .read(locationProvider.notifier)
          .getCurrentLocation(forceRefresh: forceRefresh);

      final currentLocation = ref.read(locationProvider);

      if (currentLocation.isLoaded) {
        // 목적지 정보 확인
        if (_destinationLatitude == null || _destinationLongitude == null) {
          throw Exception('목적지 좌표가 설정되지 않았습니다.');
        }

        // 경로 정보 가져오기
        await ref
            .read(routeProvider.notifier)
            .fetchRoute(
              currentLocation.latitude,
              currentLocation.longitude,
              _destinationLatitude!,
              _destinationLongitude!,
            );

        // 마커 및 경로 업데이트
        _updateMap();
      }
    } catch (e) {
      // 에러 발생 시 사용자에게 알림
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: errorMessage.contains('설정')
                ? SnackBarAction(
                    label: '설정 열기',
                    textColor: Colors.white,
                    onPressed: () async {
                      // 설정 앱으로 이동
                      await Geolocator.openAppSettings();
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  /// 지도에 마커와 경로 업데이트
  void _updateMap() {
    final currentLocation = ref.read(locationProvider);
    final routeAsyncValue = ref.read(routeProvider);

    if (!currentLocation.isLoaded) return;

    // 출발지 마커 생성
    _startMarker = Marker(
      markerId: const MarkerId('start'),
      position: LatLng(currentLocation.latitude, currentLocation.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: '출발지', snippet: '현재 위치'),
    );

    // 도착지 마커 생성
    if (_destinationLatitude != null && _destinationLongitude != null) {
      _endMarker = Marker(
        markerId: const MarkerId('end'),
        position: LatLng(_destinationLatitude!, _destinationLongitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: '도착지',
          snippet: _destinationName ?? '목적지',
        ),
      );
    }

    // 경로 정보가 있으면 Polyline 생성
    routeAsyncValue.whenData((route) {
      if (route != null) {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: route.polylinePoints.map((point) {
              return LatLng(point['latitude']!, point['longitude']!);
            }).toList(),
            color: Colors.blue,
            width: 5,
            patterns: [],
          ),
        };

        // 지도에 모든 마커와 경로가 보이도록 카메라 이동
        _fitBounds(route);
      }
    });

    setState(() {});
  }

  /// 지도에 모든 마커와 경로가 보이도록 카메라 위치 조정
  void _fitBounds(RouteModel route) {
    if (_mapController == null) return;

    // 모든 좌표를 포함하는 bounds 계산
    double minLat = route.startLatitude;
    double maxLat = route.startLatitude;
    double minLng = route.startLongitude;
    double maxLng = route.startLongitude;

    // 출발지와 도착지 좌표 비교
    minLat = minLat < route.endLatitude ? minLat : route.endLatitude;
    maxLat = maxLat > route.endLatitude ? maxLat : route.endLatitude;
    minLng = minLng < route.endLongitude ? minLng : route.endLongitude;
    maxLng = maxLng > route.endLongitude ? maxLng : route.endLongitude;

    // Polyline의 모든 좌표도 포함
    for (var point in route.polylinePoints) {
      final lat = point['latitude']!;
      final lng = point['longitude']!;
      minLat = minLat < lat ? minLat : lat;
      maxLat = maxLat > lat ? maxLat : lat;
      minLng = minLng < lng ? minLng : lng;
      maxLng = maxLng > lng ? maxLng : lng;
    }

    // 카메라 이동
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // 패딩
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(locationProvider);
    final routeAsyncValue = ref.watch(routeProvider);

    // 목적지 정보 확인
    if (_destinationLatitude == null || _destinationLongitude == null) {
      return Builder(
        builder: (context) {
          final p = context.palette;
          return Scaffold(
            backgroundColor: p.background,
            appBar: CommonAppBar(
              title: Text(
                '길찾기',
                style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: p.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    '목적지가 설정되지 않았습니다.',
                    style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Route Arguments 또는 생성자로\n목적지 좌표를 전달해주세요.',
                    textAlign: TextAlign.center,
                    style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // 현재 위치가 로드되지 않았으면 로딩 화면 표시
    if (!currentLocation.isLoaded) {
      return Builder(
        builder: (context) {
          final p = context.palette;
          return Scaffold(
            backgroundColor: p.background,
            appBar: CommonAppBar(
              title: Text(
                '길찾기',
                style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    // 초기 카메라 위치 (출발지)
    final initialCameraPosition = CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 15.0,
    );

    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.background,
          appBar: CommonAppBar(
            title: Text(
              '길찾기',
              style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
            ),
            actions: [
              // 경로 새로고침 버튼
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '경로 새로고침',
                color: p.textOnPrimary,
                onPressed: () {
                  // 경로 다시 가져오기 (강제 새로고침)
                  _initializeLocation(forceRefresh: true);
                },
              ),
            ],
          ),
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // 지도가 생성되면 마커와 경로 업데이트
              _updateMap();
            },
            markers: {
              if (_startMarker != null) _startMarker!,
              if (_endMarker != null) _endMarker!,
            },
            polylines: _polylines,
            myLocationEnabled: true, // 현재 위치 버튼 표시
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),

          // 경로 정보 표시 카드
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: routeAsyncValue.when(
              data: (route) {
                if (route == null) {
                  return const SizedBox.shrink();
                }
                return Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '경로 정보',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            // 이동 방식 표시
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getTravelModeColor(route.travelMode),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getTravelModeIcon(route.travelMode),
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    route.travelModeText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem(
                              Icons.straighten,
                              '거리',
                              route.distanceText,
                            ),
                            _buildInfoItem(
                              Icons.access_time,
                              '소요 시간',
                              route.durationText,
                            ),
                          ],
                        ),
                        // 단계별 안내 정보 (최대 3개만 표시)
                        if (route.steps.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            '경로 안내',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...route.steps
                              .take(3)
                              .map(
                                (step) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.navigation,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          step.instruction,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        step.distanceText,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          if (route.steps.length > 3)
                            Text(
                              '외 ${route.steps.length - 3}개 단계...',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('경로를 불러오는 중...'),
                    ],
                  ),
                ),
              ),
              error: (error, stack) => Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '경로를 불러오는데 실패했습니다: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }

  /// 정보 아이템 위젯 생성
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  /// 이동 방식에 따른 아이콘 반환
  IconData _getTravelModeIcon(String travelMode) {
    switch (travelMode.toLowerCase()) {
      case 'driving':
        return Icons.directions_car;
      case 'walking':
        return Icons.directions_walk;
      case 'transit':
        return Icons.directions_transit;
      case 'bicycling':
        return Icons.directions_bike;
      default:
        return Icons.directions;
    }
  }

  /// 이동 방식에 따른 색상 반환
  Color _getTravelModeColor(String travelMode) {
    switch (travelMode.toLowerCase()) {
      case 'driving':
        return Colors.blue;
      case 'walking':
        return Colors.green;
      case 'transit':
        return Colors.orange;
      case 'bicycling':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
