import 'dart:async';
import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
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
  final TripProvider tripProvider; // Receive the provider in the constructor

  const ShowMap({
    super.key,
    required this.isDriver,
    required this.tripProvider, // Pass the provider here
    this.destination,
  });

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

  @override
  void initState() {
    super.initState();
    debugPrint("ShowMap initState called");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
      if (widget.isDriver && widget.destination != null) {
        widget.tripProvider.setCoordinatesPoint(widget.destination!,widget.destination!);
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel(); //✅ Only cancel the subscription without handling context
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
          widget.tripProvider.setCurrentUserLocation(newLocation);
          widget.tripProvider.setCurrentPoints(newLocation,widget.tripProvider.currentTrip.destinationCoords);
          _lastUpdatedLocation = newLocation;

          if (_isLoading) {
            // _isLoading = false;
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
  final location = widget.tripProvider.currentTrip.userLocation;
  if (location != null) {
    _mapController.move(location, 15);
  } else {
    debugPrint("Current location not available");
    debugPrint("Location: $location");
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current location not available')),
    );
  }
}

  bool isError = false;


  @override
Widget build(BuildContext context) {
  if (isError) {
    return const Center(child: Text('Bad connection'));
  }

  if (widget.isDriver) {
    return Consumer<DriverTripProvider>(
      builder: (context, provider, child) {
        return _buildMap(provider);
      },
    );
  } else {
    return Consumer<PassengerTripProvider>(
      builder: (context, provider, child) {
        return _buildMap(provider);
      },
    );
  }
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
          
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              latLng.latitude,
              latLng.longitude,
            );
            Placemark place = placemarks.first;
            provider.currentTrip.destination = place.street ?? 'Unknown location';
            await provider.setCoordinatesPoint(latLng,latLng);
          } catch (e) {
            debugPrint("Error getting place name: $e");
            if (!mounted) return;
            errorMessage(context, e.toString());
          }
        },
        initialCenter: provider.currentTrip.userLocation ?? LatLng(0, 0),
        initialZoom: 15,
        minZoom: 0,
        maxZoom: 100,
        onMapReady: _centerOnUserLocation,
      ),
      children: [
        TileLayer(
  urlTemplate: "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
  subdomains: ['a', 'b', 'c'],
  errorTileCallback: (tile, error, stackTrace) {
    if (!isError) {
      setState(() {
        isError = true;
      });
    }
  },
  tileBuilder: (context, tileWidget, image) {
    if (isError) {
      setState(() {
        isError = false;
      });
    }
    return tileWidget;
  },
),

        
        CurrentLocationLayer(
          style: LocationMarkerStyle(
            marker: DefaultLocationMarker(
              color: Theme.of(context).colorScheme.onPrimary,
              child: Icon(Icons.location_pin, color: Theme.of(context).colorScheme.primary),
            ),
            markerSize: const Size(35, 35),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        if (provider.currentTrip.destinationCoords != const LatLng(0, 0))
          MarkerLayer(
            markers: [
              Marker(
                width: 35,
                height: 35,
                point: provider.currentTrip.destinationCoords,
                child: Icon(
                  Icons.location_pin,
                  color: Theme.of(context).colorScheme.secondary,
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
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
      ],
    );
  }
}
