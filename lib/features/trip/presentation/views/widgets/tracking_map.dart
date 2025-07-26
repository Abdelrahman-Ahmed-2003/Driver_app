import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class TrackingMap extends StatefulWidget {
  /// Current moving position (e.g. driver)
  final LatLng current;

  /// Fixed destination position
  final LatLng destination;

  /// Zoom when the map first appears
  final double initialZoom;

  const TrackingMap({
    super.key,
    required this.current,
    required this.destination,
    this.initialZoom = 15,
  });

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  final MapController _mapController = MapController();

  // @override
  // void didUpdateWidget(covariant TrackingMap oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   // If current position moved, keep the map centred on it.
  //   if (widget.current != oldWidget.current) {
  //     _mapController.move(widget.current, _mapController.camera.zoom);
  //   }
  // }

  @override
  void initState(){
    super.initState();
    debugPrint('in initstate of tracking map');
    debugPrint('${widget.destination}');
    debugPrint('${widget.current}');

    WidgetsBinding.instance.addPostFrameCallback((_)async{
      var mapProvider = Provider.of<MapProvider>(context, listen: false);
      mapProvider.passengerLocation = widget.current;
      mapProvider.setCurrentPoints(from: widget.current);
      // tripProvider.setCurrentPoints(widget.current,widget.destination);
      debugPrint('end of initstate of tracking map');
    });
  }

  @override
  Widget build(BuildContext context) {
    
    debugPrint('trackingggggggggggggg maaaaaaaaaaappppppppppppp');
    var mapProvider = context.watch<MapProvider>();
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.current,
        initialZoom: widget.initialZoom,
        maxZoom: 18,
        minZoom: 3,
      ),
      children: [
        // ─── OSM tiles ────────────────────────────────────────────────
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.your_app',
        ),

        // ─── Destination marker ──────────────────────────────────────
        MarkerLayer(
          markers: [
            Marker(
              point: widget.destination,
              width: 35,
              height: 35,
              child: const Icon(Icons.location_pin,
                  color: Colors.blue, size: 35),
            ),
          ],
        ),

        // ─── Current-position marker ─────────────────────────────────
        MarkerLayer(
          markers: [
            Marker(
              point: widget.current,
              width: 35,
              height: 35,
              
              rotate: true,
              child: const Icon(Icons.directions_car,
                  color: Colors.black, size: 30),
            ),
          ],
        ),

        // ─── Polyline current ➜ destination ─────────────────────────
        mapProvider.points.isNotEmpty ?
        PolylineLayer(
          polylines: [
            Polyline(
              points: mapProvider.points,
              strokeWidth: 5,
              color: Colors.red,
            ),
          ],
        ):SizedBox.shrink(),
      ],
    );
  }
}
