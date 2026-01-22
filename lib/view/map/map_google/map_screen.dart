import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../vm/location_provider.dart';
import '../../../vm/route_provider.dart';
import '../../../model/route_model.dart';
import '../../../utils/common_app_bar.dart';
import '../../../config/ui_config.dart';
import '../../../theme/app_colors.dart';

class DestinationArguments {
  final double latitude;

  final double longitude;

  final String? name;

  DestinationArguments({
    required this.latitude,
    required this.longitude,
    this.name,
  });

  factory DestinationArguments.fromMap(
    Map<String, dynamic> map,
  ) {
    return DestinationArguments(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      name: map['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (name != null) 'name': name,
    };
  }
}

class MapScreen extends ConsumerStatefulWidget {
  final double? destinationLatitude;

  final double? destinationLongitude;

  final String? destinationName;

  const MapScreen({
    super.key,
    this.destinationLatitude,
    this.destinationLongitude,
    this.destinationName,
  });

  @override
  ConsumerState<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Marker? _startMarker;
  Marker? _endMarker;
  Set<Polyline> _polylines = {};
  DestinationArguments? _destination;
  bool _destinationLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_destinationLoaded) {
      _loadDestinationFromArguments();
      _destinationLoaded = true;
    }
  }

  void _loadDestinationFromArguments() {
    final arguments = ModalRoute.of(
      context,
    )?.settings.arguments;

    if (arguments != null) {
      if (arguments is Map<String, dynamic>) {
        _destination = DestinationArguments.fromMap(
          arguments,
        );
      } else if (arguments is DestinationArguments) {
        _destination = arguments;
      }
    }

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

  double? get _destinationLatitude =>
      _destination?.latitude;

  double? get _destinationLongitude =>
      _destination?.longitude;

  String? get _destinationName =>
      _destination?.name ?? widget.destinationName;

  /// [forceRefresh] true이면 위치를 강제로 다시 가져옴
  Future<void> _initializeLocation({
    bool forceRefresh = false,
  }) async {
    try {
      await ref
          .read(locationProvider.notifier)
          .getCurrentLocation(forceRefresh: forceRefresh);

      final currentLocation = ref.read(locationProvider);

      if (currentLocation.isLoaded) {
        if (_destinationLatitude == null ||
            _destinationLongitude == null) {
          throw Exception('목적지 좌표가 설정되지 않았습니다.');
        }

        await ref
            .read(routeProvider.notifier)
            .fetchRoute(
              currentLocation.latitude,
              currentLocation.longitude,
              _destinationLatitude!,
              _destinationLongitude!,
            );
        _updateMap();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll(
          'Exception: ',
          '',
        );
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
                      await Geolocator.openAppSettings();
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  void _updateMap() {
    final currentLocation = ref.read(locationProvider);
    final routeAsyncValue = ref.read(routeProvider);
    if (!currentLocation.isLoaded) return;
    _startMarker = Marker(
      markerId: const MarkerId('start'),
      position: LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
      infoWindow: const InfoWindow(
        title: '출발지',
        snippet: '현재 위치',
      ),
    );
    if (_destinationLatitude != null &&
        _destinationLongitude != null) {
      _endMarker = Marker(
        markerId: const MarkerId('end'),
        position: LatLng(
          _destinationLatitude!,
          _destinationLongitude!,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: '도착지',
          snippet: _destinationName ?? '목적지',
        ),
      );
    }

    routeAsyncValue.whenData((route) {
      if (route != null) {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: route.polylinePoints.map((point) {
              return LatLng(
                point['latitude']!,
                point['longitude']!,
              );
            }).toList(),
            color: Colors.blue,
            width: 5,
            patterns: [],
          ),
        };

        _fitBounds(route);
      }
    });

    setState(() {});
  }

  void _fitBounds(RouteModel route) {
    if (_mapController == null) return;

    double minLat = route.startLatitude;
    double maxLat = route.startLatitude;
    double minLng = route.startLongitude;
    double maxLng = route.startLongitude;

    minLat = minLat < route.endLatitude
        ? minLat
        : route.endLatitude;
    maxLat = maxLat > route.endLatitude
        ? maxLat
        : route.endLatitude;
    minLng = minLng < route.endLongitude
        ? minLng
        : route.endLongitude;
    maxLng = maxLng > route.endLongitude
        ? maxLng
        : route.endLongitude;

    for (var point in route.polylinePoints) {
      final lat = point['latitude']!;
      final lng = point['longitude']!;
      minLat = minLat < lat ? minLat : lat;
      maxLat = maxLat > lat ? maxLat : lat;
      minLng = minLng < lng ? minLng : lng;
      maxLng = maxLng > lng ? maxLng : lng;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(locationProvider);
    final routeAsyncValue = ref.watch(routeProvider);

    if (_destinationLatitude == null ||
        _destinationLongitude == null) {
      return Builder(
        builder: (context) {
          final p = context.palette;
          return Scaffold(
            backgroundColor: p.background,
            appBar: CommonAppBar(
              title: Text(
                '길찾기',
                style: mainAppBarTitleStyle.copyWith(
                  color: p.textOnPrimary,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: p.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '목적지가 설정되지 않았습니다.',
                    style: mainBodyTextStyle.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Route Arguments 또는 생성자로\n목적지 좌표를 전달해주세요.',
                    textAlign: TextAlign.center,
                    style: mainSmallTextStyle.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (!currentLocation.isLoaded) {
      return Builder(
        builder: (context) {
          final p = context.palette;
          return Scaffold(
            backgroundColor: p.background,
            appBar: CommonAppBar(
              title: Text(
                '길찾기',
                style: mainAppBarTitleStyle.copyWith(
                  color: p.textOnPrimary,
                ),
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }

    final initialCameraPosition = CameraPosition(
      target: LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      ),
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
              style: mainAppBarTitleStyle.copyWith(
                color: p.textOnPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                tooltip: '경로 새로고침',
                color: p.textOnPrimary,
                onPressed: () {
                  _initializeLocation(forceRefresh: true);
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    initialCameraPosition,
                onMapCreated:
                    (GoogleMapController controller) {
                      _mapController = controller;
                      _updateMap();
                    },
                markers: {
                  if (_startMarker != null) _startMarker!,
                  if (_endMarker != null) _endMarker!,
                },
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              ),
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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  '경로 정보',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge,
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                  decoration: BoxDecoration(
                                    color:
                                        _getTravelModeColor(
                                          route.travelMode,
                                        ),
                                    borderRadius:
                                        BorderRadius.circular(
                                          20,
                                        ),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getTravelModeIcon(
                                          route.travelMode,
                                        ),
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        route
                                            .travelModeText,
                                        style:
                                            const TextStyle(
                                              color: Colors
                                                  .white,
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
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

                            if (route.steps.isNotEmpty) ...[
                              SizedBox(height: 12),
                              const Divider(),
                              SizedBox(height: 8),
                              Text(
                                '경로 안내',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 8),
                              ...route.steps
                                  .take(3)
                                  .map(
                                    (step) => Padding(
                                      padding:
                                          const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Icon(
                                            Icons
                                                .navigation,
                                            size: 16,
                                            color:
                                                Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Expanded(
                                            child: Text(
                                              step.instruction,
                                              style:
                                                  TextStyle(
                                                    fontSize:
                                                        12,
                                                  ),
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            step.distanceText,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors
                                                  .grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              if (route.steps.length > 3)
                                Text(
                                  '외 ${route.steps.length - 3}개 단계...',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontStyle:
                                        FontStyle.italic,
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
                          Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '경로를 불러오는데 실패했습니다: $error',
                              style: TextStyle(
                                color: Colors.red,
                              ),
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

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

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
