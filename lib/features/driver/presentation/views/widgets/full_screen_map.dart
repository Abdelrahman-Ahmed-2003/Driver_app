import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FullScreenMap extends StatefulWidget {
  const FullScreenMap({super.key,});

  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  var mapController = MapController();
  late MapProvider mapProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var mapProvider = Provider.of<MapProvider>(context, listen: false);
      // await mapProvider.initializeLocation(); // include notifyListeners
      await mapProvider.initialize3MarkersRoute();
      debugPrint("FullScreenMap initState called");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapProvider = context.read<MapProvider>(); // Safe here
  }

  @override
  void dispose() {
    mapController.dispose();
    mapProvider.cancelLocationSubscription(); // Use saved reference
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mapProvider = context.watch<MapProvider>();
    // Avoid triggering setState or notifyListeners during build
    if (mapProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    debugPrint('DriverMap Rebuild  ${mapProvider.isLoading}');
    return SafeArea(
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: mapProvider.driverLocation,
              initialZoom: 15,
              minZoom: 0,
              maxZoom: 100,
              // onMapReady: mapProvider.centerOnUserLocation,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: Theme.of(context).colorScheme.onPrimary,
                    child: Icon(Icons.navigation,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  markerSize: const Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 35,
                    height: 35,
                    point: mapProvider.destination,
                    child: Icon(
                      Icons.location_pin,
                      color: AppColors.cardBorderLight,
                      size: 35,
                    ),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 35,
                    height: 35,
                    point: mapProvider.passengerLocation,
                    child: Icon(
                      Icons.location_pin,
                      color: AppColors.darkRed,
                      size: 35,
                    ),
                  ),
                ],
              ),
              PolylineLayer(
                  polylines: [
                    Polyline(
                      points: mapProvider.toUserPoints,
                      strokeWidth: 5,
                      color: AppColors.orangeColor,
                    ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: mapProvider.points,
                      strokeWidth: 5,
                      color: AppColors.darkRed,
                    ),
                  ],
                ),
            ],
          ),
          // Positioned(
          //   bottom: 50,
          //   right: 1,
          //   child: IconButton(
          //     icon: const Icon(Icons.add, color: AppColors.cardBorderLight),
          //     onPressed: () {
          //       ++_currentZoom;
          //       setState(() {
                  
          //       });
          //     },
          //   ),
          // ),
          // Positioned(
          //   bottom: 1,
          //   right: 1,
          //   child: IconButton(
          //     icon: const Icon(Icons.remove, color: AppColors.cardBorderLight),
          //     onPressed: () {
          //       if (_currentZoom > 0) {
          //         --_currentZoom;
          //         setState(() {});
          //       }
          //     },
          //   ),
          // ),
          
          
        ],
      ),
    );
  }
}
