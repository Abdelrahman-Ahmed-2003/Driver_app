import 'dart:async';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
import 'package:dirver/features/passenger_home/presentation/provider/tripProvider.dart';
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
  const ShowMap({super.key,required this.isDriver,this.destination});

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
  late ContentOfTripProvider contentProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
      if (widget.isDriver) {
        final provider = Provider.of<ContentOfTripProvider>(context, listen: false);
        provider.setCoordinatesPoint(widget.destination!);
      }
    });
  }

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  contentProvider = Provider.of<ContentOfTripProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    contentProvider.clear(); // ✅ Safe now
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
          final provider = Provider.of<ContentOfTripProvider>(context, listen: false);
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
    final provider = Provider.of<ContentOfTripProvider>(context, listen: false);
    
    if (provider.currentLocation != null) {
      _mapController.move(provider.currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentOfTripProvider>(
      builder: (context, ContentOfTripProvider, child) {
        var tripProvider = Provider.of<TripProvider>(context);
        return _buildMap(ContentOfTripProvider,tripProvider);
      },
    );
  }

  Widget _buildMap(ContentOfTripProvider provider,TripProvider tripProvider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        onTap:(TapPosition tapPosition, LatLng latLng) async {
          if(widget.isDriver) return;
          if(tripProvider.tripStream != null) return;
          provider.setCoordinatesPoint(latLng);
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              latLng.latitude,
              latLng.longitude
            );
            
            Placemark place = placemarks.first;
            provider.toController.text = place.street ?? 'Unknown location';
          } catch (e) {
            debugPrint("Error: $e");
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
                width: 50,
                height: 50,
                point: provider.dest,
                child: const Icon(
                  Icons.location_pin,
                  color: AppColors.blueColor,
                  size: 40,
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