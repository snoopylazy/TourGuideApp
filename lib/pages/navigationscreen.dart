import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:intl/intl.dart';
import '../widgets/glass_container.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/gradient_background.dart';
import '../config/app_colors.dart';

enum RouteMode { walk, motor, car, bus }

class _RouteData {
  final int durationSeconds;
  final double distanceMeters;
  final List<LatLng> points;

  const _RouteData({
    required this.durationSeconds,
    required this.distanceMeters,
    required this.points,
  });
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  late LatLng _destination;
  List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionStream;
  bool _arrived = false;
  final double _arrivalThreshold = 50.0; // meters

  RouteMode _selectedMode = RouteMode.car;
  final Map<RouteMode, _RouteData> _routes = {};
  bool _loadingRoutes = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _destination =
        args?['destination'] as LatLng? ?? LatLng(11.556444, 104.928208);
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Location Services', 'Please enable location services');
      Get.back();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Permission Denied', 'Location permission is required');
        Get.back();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Denied',
        'Location permissions permanently denied',
      );
      Get.back();
      return;
    }

    // Get initial position
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    await _getRoute();

    // Live location updates
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          final newPos = LatLng(position.latitude, position.longitude);
          setState(() {
            _currentPosition = newPos;
          });

          _mapController.move(newPos, 15.5);

          // Check if arrived
          double distance = Geolocator.distanceBetween(
            newPos.latitude,
            newPos.longitude,
            _destination.latitude,
            _destination.longitude,
          );

          if (distance <= _arrivalThreshold && !_arrived) {
            setState(() => _arrived = true);
            Get.snackbar(
              'Congratulations!',
              'You have arrived at your destination!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
          }
        });
  }

  Future<void> _getRoute() async {
    if (_currentPosition == null) return;

    final start =
        '${_currentPosition!.longitude},${_currentPosition!.latitude}';
    final end = '${_destination.longitude},${_destination.latitude}';
    const base = 'http://router.project-osrm.org/route/v1';
    const opts = 'overview=full&geometries=polyline';
    final polylinePoints = PolylinePoints();

    setState(() => _loadingRoutes = true);

    Future<_RouteData?> fetchProfile(String profile) async {
      final url = Uri.parse('$base/$profile/$start;$end?$opts');
      try {
        final response = await http.get(url);
        if (response.statusCode != 200) return null;
        final json = jsonDecode(response.body);
        if (json['routes']?.isEmpty ?? true) return null;
        final r = json['routes'][0];
        final geometry = r['geometry'] as String;
        final duration = (r['duration'] as num).toDouble();
        final distance = (r['distance'] as num).toDouble();
        final result = polylinePoints.decodePolyline(geometry);
        final points = result
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        return _RouteData(
          durationSeconds: duration.round(),
          distanceMeters: distance,
          points: points,
        );
      } catch (_) {
        return null;
      }
    }

    try {
      final footFuture = fetchProfile('foot');
      final drivingFuture = fetchProfile('driving');
      final bikeFuture = fetchProfile('bike');

      final foot = await footFuture;
      final driving = await drivingFuture;
      final bike = await bikeFuture;

      if (!mounted) return;
      setState(() {
        _loadingRoutes = false;
        _routes.clear();
        if (foot != null) {
          _routes[RouteMode.walk] = foot;
        }
        if (driving != null) {
          _routes[RouteMode.car] = driving;
          // Motor: use bike route when available (closer to motorcycle); else driving × 1.1
          if (bike != null) {
            _routes[RouteMode.motor] = bike;
          } else {
            final motorDuration = (driving.durationSeconds * 1.1).round();
            _routes[RouteMode.motor] = _RouteData(
              durationSeconds: motorDuration,
              distanceMeters: driving.distanceMeters,
              points: driving.points,
            );
          }
          // Bus: ~35% slower than car (stops, traffic)
          final busDuration = (driving.durationSeconds * 1.35).round();
          _routes[RouteMode.bus] = _RouteData(
            durationSeconds: busDuration,
            distanceMeters: driving.distanceMeters,
            points: driving.points,
          );
        }
        if (_routes.isNotEmpty && !_routes.containsKey(_selectedMode)) {
          _selectedMode = RouteMode.car;
          if (!_routes.containsKey(_selectedMode)) {
            _selectedMode = _routes.keys.first;
          }
        }
        _applySelectedRoute();
      });

      if (_routes.isEmpty) {
        Get.snackbar('Route Error', 'Could not fetch any route');
      }
    } catch (e) {
      if (mounted) setState(() => _loadingRoutes = false);
      Get.snackbar('Network Error', 'Failed to load route: $e');
    }
  }

  void _applySelectedRoute() {
    final data = _routes[_selectedMode];
    if (data != null) {
      _routePoints = List.from(data.points);
    }
  }

  void _selectMode(RouteMode mode) {
    if (!_routes.containsKey(mode)) return;
    setState(() {
      _selectedMode = mode;
      _applySelectedRoute();
    });
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (s == 0) return '$m min';
    return '$m min $s sec';
  }

  String _formatArriveBy(int durationSeconds) {
    final arrive = DateTime.now().add(Duration(seconds: durationSeconds));
    return DateFormat('h:mm a').format(arrive);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Get to Your Destination',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _currentPosition == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerLoading(
                      width: 50,
                      height: 50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    const SizedBox(height: 20),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          'Getting your location...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPosition!,
                      initialZoom: 15.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.tourguideapp',
                      ),
                      if (_routePoints
                          .isNotEmpty) // Add this condition to avoid empty points error
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              color: AppColors.primaryMedium,
                              strokeWidth: 5.0,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          // Current location
                          Marker(
                            point: _currentPosition!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),
                          // Destination
                          Marker(
                            point: _destination,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!_arrived && _routes.isNotEmpty && !_loadingRoutes)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 16,
                      child: _TransportModeCards(
                        routes: _routes,
                        selectedMode: _selectedMode,
                        onSelect: _selectMode,
                        formatDuration: _formatDuration,
                        formatArriveBy: _formatArriveBy,
                      ),
                    ),
                  if (_arrived)
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: const Center(
                          child: Text(
                            'You have arrived at your destination!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _TransportModeCards extends StatelessWidget {
  final Map<RouteMode, _RouteData> routes;
  final RouteMode selectedMode;
  final void Function(RouteMode) onSelect;
  final String Function(int) formatDuration;
  final String Function(int) formatArriveBy;

  const _TransportModeCards({
    required this.routes,
    required this.selectedMode,
    required this.onSelect,
    required this.formatDuration,
    required this.formatArriveBy,
  });

  static const _modes = [
    RouteMode.walk,
    RouteMode.motor,
    RouteMode.car,
    RouteMode.bus,
  ];

  static IconData _icon(RouteMode m) {
    switch (m) {
      case RouteMode.walk:
        return Icons.directions_walk;
      case RouteMode.motor:
        return Icons.two_wheeler;
      case RouteMode.car:
        return Icons.directions_car;
      case RouteMode.bus:
        return Icons.directions_bus;
    }
  }

  static String _label(RouteMode m) {
    switch (m) {
      case RouteMode.walk:
        return 'Walk';
      case RouteMode.motor:
        return 'Motor';
      case RouteMode.car:
        return 'Car';
      case RouteMode.bus:
        return 'Bus';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: _modes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final mode = _modes[i];
            final data = routes[mode];
            if (data == null) return const SizedBox.shrink();
            final selected = selectedMode == mode;
            return GestureDetector(
              onTap: () => onSelect(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 110,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryMedium.withOpacity(0.35)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryLight
                        : Colors.white.withOpacity(0.25),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _icon(mode),
                          size: 18,
                          color: selected
                              ? AppColors.primaryLight
                              : Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _label(mode),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDuration(data.durationSeconds),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Arrive ${formatArriveBy(data.durationSeconds)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
