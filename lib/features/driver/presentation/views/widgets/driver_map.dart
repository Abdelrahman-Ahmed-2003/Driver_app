import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

class DriverMap extends StatelessWidget {
  const DriverMap({
    super.key,
  });


  @override
Widget build(BuildContext context) {
  var mapProvider = context.read<MapProvider>();
  var mapController = MapController()
  ;
  // if(mapProvider.isLoading mapProvider.currentLocation == const LatLng(0, 0)) {
  //   return const Center(child: CircularProgressIndicator());
  // }
  debugPrint('DriverMap Rebuild ${mapProvider.isLoading}');
  return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: mapProvider.destination,
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
      ],
    );
  
}
}
