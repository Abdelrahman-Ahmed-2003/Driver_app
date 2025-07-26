import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ShowMap extends StatefulWidget {
  final LatLng destination;

  const ShowMap({
    super.key,// Pass the provider here
    required this.destination,
  });

  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  late MapProvider mapProvider;
  var mapController = MapController();

  @override
  void initState() {
    super.initState();
    debugPrint("ShowMap initState called");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var mapProvider = Provider.of<MapProvider>(context, listen: false);
      mapProvider.destination = widget.destination;

      await mapProvider.listenLocation(false);
      // if(widget.destination != const LatLng(0, 0)) {
      //   await mapProvider.fetchRoute();
      // }
      // await mapProvider.fetchRoute(widget.destination);
    });
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  mapProvider = context.read<MapProvider>(); // Safe here
}

@override
void dispose() {
  mapProvider.cancelLocationSubscription(); // Use saved reference
  mapController.dispose();
  mapProvider.clear();
  super.dispose();
}



  @override
Widget build(BuildContext context) {
  
  var mapProvider = context.watch<MapProvider>();
  var passengerProvider = context.read<PassengerTripProvider>();
  if(passengerProvider.tripStream != null && mapProvider.destination == const LatLng(0, 0))
  {
    debugPrint('print from condation in begining of show map');
    mapProvider.stringDestination = passengerProvider.currentTrip.destination;
    WidgetsBinding.instance.addPostFrameCallback((_)async{
        mapProvider.destination = passengerProvider.currentTrip.destinationCoords;
        // await mapProvider.fetchRoute();
    });
    

  }
  debugPrint('ShowMap Rebuild ${mapProvider.isLoading}');
  if(mapProvider.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        onTap: (tapPosition, latLng) async {
          if (passengerProvider.tripStream != null) return;
          var mapProvider = context.read<MapProvider>();
          if(mapProvider.canSearch) {
            mapProvider.canSearch = false;
          }
          
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              latLng.latitude,
              latLng.longitude,
            );
            Placemark place = placemarks.first;
            mapProvider.stringDestination = place.street ?? 'Unknown Location';
            mapProvider.destination = latLng;
            debugPrint('in show map destination: ${latLng}');
            await mapProvider.setCurrentPoints(from:mapProvider.passengerLocation, to:latLng,type: 'toDest');
          } catch (e) {
            debugPrint("Error getting place name: $e");
            if (!mounted) return;
            errorMessage(context, e.toString());
          }
        },
        initialCenter: mapProvider.passengerLocation,
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
              child: Icon(Icons.location_pin, color: Theme.of(context).colorScheme.primary),
            ),
            markerSize: const Size(35, 35),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        if (mapProvider.destination != const LatLng(0, 0))
          MarkerLayer(
            markers: [
              Marker(
                width: 35,
                height: 35,
                point: mapProvider.destination,
                child: Icon(
                  Icons.location_pin,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 35,
                ),
              ),
            ],
          ),
        if (mapProvider.points.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: mapProvider.points,
                strokeWidth: 5,
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
      ],
    );
}

}
