import 'dart:async';

import 'package:dirver/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location_package;
import 'package:provider/provider.dart';
import 'package:dirver/features/passenger_home/presentation/provider/trip_provider.dart';

class ShowMap extends StatefulWidget {
  const ShowMap({super.key});

  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  final MapController _mapController = MapController();
  final  _location = location_package.Location();
  StreamSubscription<location_package.LocationData>? _locationSubscription;
  bool _isLoading = true;
  LatLng? _lastUpdatedLocation;
  final Distance _distanceCalculator = Distance();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    if (!await _checkPermissions()) return;
    
    _locationSubscription = _location.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        final newLocation = LatLng(
          currentLocation.latitude!, 
          currentLocation.longitude!
        );

        // Check if we should update based on distance threshold
        if (_shouldUpdateLocation(newLocation)){
          final tripProvider = Provider.of<TripProvider>(context, listen: false);
          tripProvider.currentLocation = newLocation;
          tripProvider.setCurrentPoints(newLocation);
          _lastUpdatedLocation = newLocation;
          
          if (_isLoading) {
            setState(() => _isLoading = false);
          }
        }
      }
    });
  }

  bool _shouldUpdateLocation(LatLng newLocation) {
    // If first location or no previous location, always update
    if (_lastUpdatedLocation == null) return true;
    
    // Calculate distance in meters between last point and new point
    final distance = _distanceCalculator(
      _lastUpdatedLocation!, 
      newLocation
    );
    
    // Only update if moved more than 15 meters
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
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    
    if (tripProvider.currentLocation != null) {
      _mapController.move(tripProvider.currentLocation!, 15);
    } else {
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

  Widget _buildMap(TripProvider tripProvider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        onTap:(TapPosition tapPosition, LatLng latLng) async {
          tripProvider.setDest(latLng);
          tripProvider.setCoordinatesPoint(latLng);
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              latLng.latitude,
              latLng.longitude
            );
            
            Placemark place = placemarks.first;
            tripProvider.toController.text = place.street ?? 'Unknown location';
          } catch (e) {
            debugPrint("Error: $e");
            errorMessage(context, e.toString());
          }

        },
        initialCenter: tripProvider.currentLocation ?? const LatLng(0, 0),
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
              color: Colors.white,
              child: const Icon(Icons.location_pin),
            ),
            markerSize: const Size(35, 35),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        if (tripProvider.dest != const LatLng(0, 0))
          MarkerLayer(
            markers: [
              Marker(
                width: 50,
                height: 50,
                point: tripProvider.dest,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ],
          ),
        if (tripProvider.points.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: tripProvider.points,
                strokeWidth: 5,
                color: Colors.red,
              ),
            ],
          ),
      ],
    );
  }
}