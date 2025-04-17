import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:dirver/features/passenger_home/presentation/provider/trip_provider.dart';

class ShowMap extends StatefulWidget {
  const ShowMap({super.key});

  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    if (!await _checktheRequestPermissions()) return;

    _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
      if (!mounted) return; // ✅ Ensure widget is mounted before updating UI

      var tripProvider = Provider.of<TripProvider>(context, listen: false);
      LatLng newLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      tripProvider.updateCurrentLocation(newLocation);
    });
  }



  Future<bool> _checktheRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }
    final PermissionStatus permissionStatus = await _location.requestPermission();
    return permissionStatus == PermissionStatus.granted;
  }

  Future<void> userCurrentLocation() async {
    var tripProvider = Provider.of<TripProvider>(context, listen: false);
    if (tripProvider.currentLocation != null) {
      _mapController.move(tripProvider.currentLocation!, 15);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current location not available'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TripProvider, LatLng?>(
      selector: (_, provider) => provider.currentLocation,
      builder: (context, currentLocation, child) {
        return _buildMap(currentLocation);
      },
    );
  }

  Widget _buildMap(LatLng? currentLocation) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: currentLocation ?? LatLng(0, 0),
        initialZoom: 2,
        minZoom: 0,
        maxZoom: 100,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        CurrentLocationLayer(
          style: LocationMarkerStyle(
            marker: DefaultLocationMarker(
              // color: Colors.white,
              child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
            ),
            markerSize: Size(35, 35),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        Selector<TripProvider, LatLng>(
          selector: (_, provider) => provider.dest,
          builder: (context, dest, child) {
            return dest != LatLng(0, 0)
                ? MarkerLayer(
              markers: [
                Marker(
                  width: 50,
                  height: 50,
                  point: dest,
                  child: const Icon(Icons.flag, color: Colors.red, size: 40),
                ),
              ],
            )
                : SizedBox.shrink();
          },
        ),
        Selector<TripProvider, List<LatLng>>(
          selector: (_, provider) => provider.points,
          builder: (context, points, child) {
            return points.isNotEmpty
                ? PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  strokeWidth: 5,
                  color: Colors.green,
                ),
              ],
            )
                : SizedBox.shrink();
          },
        ),
      ],
    );
  }
  @override
  void dispose() {
    _locationSubscription?.cancel(); // ✅ Cancel location updates when widget is destroyed
    super.dispose();
  }
}
