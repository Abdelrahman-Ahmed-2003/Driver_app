import 'dart:async';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/passenger/presentation/provider/tripProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location_package;
import 'package:provider/provider.dart';

class ShowMap extends StatefulWidget {
  final bool isDriver;
  final LatLng? destination;
  const ShowMap({super.key, required this.isDriver, this.destination});

  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  final MapController _mapController = MapController();
  final location_package.Location _location = location_package.Location();
  StreamSubscription<location_package.LocationData>? _locationSubscription;
  bool _isLoading = true;
  LatLng? _lastUpdatedLocation;
  final Distance _distanceCalculator = Distance();
  late TripProvider provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = Provider.of<TripProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
      if (widget.isDriver && widget.destination != null) {
        provider.setCoordinatesPoint(widget.destination!);
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel(); //✅ فقط نلغي الاشتراك، بدون التعامل مع context
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    if (!await _checkPermissions()) return;

    _locationSubscription = _location.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        final newLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        if (_shouldUpdateLocation(newLocation)) {
          provider.currentLocation = newLocation;
          provider.setCurrentPoints(newLocation);
          _lastUpdatedLocation = newLocation;

          if (_isLoading) {
            setState(() => _isLoading = false);
          }
        }
      }
    });
  }

  bool _shouldUpdateLocation(LatLng newLocation) {
    if (_lastUpdatedLocation == null) return true;
    final distance = _distanceCalculator(_lastUpdatedLocation!, newLocation);
    return distance > 5;
  }

  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    final permissionStatus = await _location.requestPermission();
    return permissionStatus == location_package.PermissionStatus.granted;
  }

  Future<void> _centerOnUserLocation() async {
    if (provider.currentLocation != null) {
      _mapController.move(provider.currentLocation!, 15);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        return _buildMap(tripProvider);
      },
    );
  }

  Widget _buildMap(TripProvider provider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        onTap: (tapPosition, latLng) async {
          if (widget.isDriver || provider.tripStream != null) return;
          provider.setCoordinatesPoint(latLng);
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              latLng.latitude,
              latLng.longitude,
            );
            Placemark place = placemarks.first;
            provider.toController.text = place.street ?? 'Unknown location';
          } catch (e) {
            debugPrint("Error getting place name: $e");
            if (!mounted) return;
            errorMessage(context, e.toString());
          }
        },
        initialCenter: provider.currentLocation ?? const LatLng(0, 0),
        initialZoom: 15,
        minZoom: 0,
        maxZoom: 100,
        onMapReady: _centerOnUserLocation,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        CurrentLocationLayer(
          style: LocationMarkerStyle(
            marker: DefaultLocationMarker(
              color: AppColors.whiteColor,
              child: const Icon(Icons.location_pin),
            ),
            markerSize: const Size(35, 35),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        if (provider.dest != const LatLng(0, 0))
          MarkerLayer(
            markers: [
              Marker(
                width: 35,
                height: 35,
                point: provider.dest,
                child: const Icon(
                  Icons.location_pin,
                  color: AppColors.blueColor,
                  size: 35,
                ),
              ),
            ],
          ),
        if (provider.points.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: provider.points,
                strokeWidth: 5,
                color: AppColors.redColor,
              ),
            ],
          ),
      ],
    );
  }
}
