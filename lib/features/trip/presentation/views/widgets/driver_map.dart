import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/core/utils/colors_app.dart';

class DriverMap extends StatefulWidget {
  final LatLng destination;
  const DriverMap({super.key,required this.destination});

  @override
  State<DriverMap> createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverMap> {
  final MapController _mapController = MapController();
  final loc.Location _location = loc.Location();
  StreamSubscription<loc.LocationData>? _locSub;

  bool _isLoading = true;
  bool _isError = false;

  LatLng? _lastPoint;
  final Distance _dist = const Distance();

  @override
  void initState() {
    super.initState();
    debugPrint('init state destination:');
    debugPrint('destination: ${widget.destination}');
    WidgetsBinding.instance.addPostFrameCallback((_) async => await _startTracking());
  }

  @override
  void dispose() {
    _locSub?.cancel();   // أوقف الاستماع أولًا
    debugPrint('dispose');
    super.dispose();
  }

  /* ─────────── إذن وتشغيل GPS ─────────── */
  Future<void> _startTracking() async {
    debugPrint('start of tracking');
    if (!await _checkPermissions()) return;
    

    _locSub = _location.onLocationChanged.listen((d) async {
      if (!mounted) return; // Prevents using provider after dispose
      if (d.latitude == null || d.longitude == null) return;

      final point = LatLng(d.latitude!, d.longitude!);

      // Check distance before any provider updates
      if (_lastPoint == null || _dist(_lastPoint!, point) > 5) { // 5 meters threshold
        // Always get provider from context
        final provider = Provider.of<DriverTripProvider>(context, listen: false);
        debugPrint('in tracking before set current user location');
        provider.setCurrentUserLocation(point);
        debugPrint('in tracking after set current user location');
        provider.setCurrentPoints(point,widget.destination);
        debugPrint('in tracking after set current points');
        await provider.pushDriverLocation(point);
        _lastPoint = point;
        if (_isLoading) setState(() => _isLoading = false); // Only call once
      }
      
    });
  }

  Future<bool> _checkPermissions() async {
    if (!await _location.serviceEnabled() && !await _location.requestService()) {
      return false;
    }
    final perm = await _location.requestPermission();
    return perm == loc.PermissionStatus.granted;
  }

  /* ───────── واجهة المستخدم ───────── */
  @override
  Widget build(BuildContext context) {
    if (_isError) return const Center(child: Text('Bad connection'));
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // نستخدم watch ليحدث الرسم إذا تغيّرت البيانات
    final provider = context.watch<DriverTripProvider>();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: provider.currentTrip.userLocation ?? const LatLng(0, 0),
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          errorTileCallback: (_, __, ___) => setState(() => _isError = true),
          tileBuilder: (_, w, __) {
            if (_isError) setState(() => _isError = false);
            return w;
          },
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
        if ( widget.destination!= const LatLng(0, 0))
          MarkerLayer(
            markers: [
              Marker(
                point: widget.destination,
                width: 35,
                height: 35,
                child: const Icon(Icons.location_pin,
                    color: AppColors.blueColor, size: 35),
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
