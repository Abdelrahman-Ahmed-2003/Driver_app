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
  final LatLng? destination;
  const DriverMap({super.key, this.destination});

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
  DateTime _lastSend = DateTime(2000);   // لضبط كل 3 ثوان
  final Distance _dist = const Distance();

  late final DriverTripProvider _provider; // ← نحفظ النسخة الحيّة

  @override
  void initState() {
    super.initState();

    _provider = context.read<DriverTripProvider>(); // مرة واحدة فقط

    WidgetsBinding.instance.addPostFrameCallback((_) => _startTracking());
  }

  @override
  void dispose() {
    _locSub?.cancel();   // أوقف الاستماع أولًا
    super.dispose();
  }

  /* ─────────── إذن وتشغيل GPS ─────────── */
  Future<void> _startTracking() async {
    if (!await _checkPermissions()) return;

    _locSub = _location.onLocationChanged.listen((d) async {
      if (d.latitude == null || d.longitude == null) return;

      final point = LatLng(d.latitude!, d.longitude!);

      // تحديث واجهة الخريطة
      _provider.setCurrentUserLocation(point);
      _provider.setCurrentPoints(point);

      // إرسال لـ Firestore كل 3 ثوانٍ
      if (DateTime.now().difference(_lastSend).inSeconds >= 3) {
        _lastSend = DateTime.now();
        await _provider.pushDriverLocation(point);  // ← دالة في المزود
      }

      if (_isLoading) setState(() => _isLoading = false);
      if (_lastPoint == null || _dist(_lastPoint!, point) > 5) {
        _lastPoint = point;
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
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          errorTileCallback: (_, __, ___) => setState(() => _isError = true),
          tileBuilder: (_, w, __) {
            if (_isError) setState(() => _isError = false);
            return w;
          },
        ),
        CurrentLocationLayer(
          style: LocationMarkerStyle(
            marker: DefaultLocationMarker(
              child: const Icon(Icons.location_pin),
              color: AppColors.whiteColor,
            ),
            markerSize: const Size(35, 35),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        if (provider.currentTrip.destinationCoords != const LatLng(0, 0))
          MarkerLayer(
            markers: [
              Marker(
                point: provider.currentTrip.destinationCoords,
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
