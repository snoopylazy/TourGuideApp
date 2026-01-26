import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../widgets/glass_container.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/gradient_background.dart';
import '../config/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _destination = args?['destination'] as LatLng? ?? LatLng(11.556444, 104.928208);
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
      Get.snackbar('Permission Denied', 'Location permissions permanently denied');
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
    _positionStream = Geolocator.getPositionStream(
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

    final start = '${_currentPosition!.longitude},${_currentPosition!.latitude}';
    final end = '${_destination.longitude},${_destination.latitude}';

    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&geometries=polyline',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['routes']?.isNotEmpty ?? false) {
          final geometry = json['routes'][0]['geometry'] as String;
          final polylinePoints = PolylinePoints();
          final result = polylinePoints.decodePolyline(geometry);

          setState(() {
            _routePoints = result
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();
          });
        }
      } else {
        Get.snackbar('Route Error', 'Could not fetch route');
      }
    } catch (e) {
      Get.snackbar('Network Error', 'Failed to load route: $e');
    }
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
          title: const Text('Navigation', style: TextStyle(color: Colors.white)),
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
                    child: const Text(
                      'Getting your location...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.tourguideapp',
                    ),
                    if (_routePoints.isNotEmpty)  // Add this condition to avoid empty points error
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