import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:dirver/core/utils/colors_app.dart';

class DriverTripMap extends StatefulWidget {
  final LatLng destination;
  const DriverTripMap({super.key,required this.destination});

  @override
  State<DriverTripMap> createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverTripMap> {
  final MapController _mapController = MapController();
  late MapProvider mapProvider;

  @override
  void initState() {
    super.initState();
    debugPrint('init state destination:');
    debugPrint('destination: ${widget.destination}');
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      var mapProvider = Provider.of<MapProvider>(context, listen: false);
      
            mapProvider.destination = widget.destination;

      await mapProvider.listenLocation(true);
      // await mapProvider.fetchRoute();
    });
  }
@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapProvider = context.read<MapProvider>(); // Safe here
  }
  @override
  void dispose() {
    mapProvider.cancelLocationSubscription();
    debugPrint('dispose');
    super.dispose();
  }

  /* ─────────── إذن وتشغيل GPS ─────────── */
  // Future<void> _startTracking() async {
  //   debugPrint('start of tracking');
  //   if (!await _checkPermissions()) return;
    

  //   _locSub = _location.onLocationChanged.listen((d) async {
  //     if (!mounted) return; // Prevents using provider after dispose
  //     if (d.latitude == null || d.longitude == null) return;

  //     final point = LatLng(d.latitude!, d.longitude!);

  //     // Check distance before any provider updates
  //     if (_lastPoint == null || _dist(_lastPoint!, point) > 5) { // 5 meters threshold
  //       // Always get provider from context
  //       debugPrint('in tracking before set current user location');
  //       provider.setCurrentUserLocation(point);
  //       debugPrint('in tracking after set current user location');
  //       provider.setCurrentPoints(point,widget.destination);
  //       debugPrint('in tracking after set current points');
  //       await provider.pushDriverLocation(point);
  //       _lastPoint = point;
  //       if (_isLoading) setState(() => _isLoading = false); // Only call once
  //     }
      
  //   });
  // }


  /* ───────── واجهة المستخدم ───────── */
  @override
  Widget build(BuildContext context) {

    // نستخدم watch ليحدث الرسم إذا تغيّرت البيانات
    final provider = context.watch<MapProvider>();
    if(mapProvider.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: provider.driverLocation,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          
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
