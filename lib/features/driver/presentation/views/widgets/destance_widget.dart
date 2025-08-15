import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class DestanceWidget extends StatefulWidget {
  final String destination;
  final LatLng destinationCoords;
  final LatLng passengerLocation;
  const DestanceWidget(
      {super.key,
      required this.destination,
      required this.destinationCoords,
      required this.passengerLocation});

  @override
  State<DestanceWidget> createState() => _DestanceWidgetState();
}

class _DestanceWidgetState extends State<DestanceWidget> {
   double? distanceToUser;
  double? distanceToDestination;
  bool _enable = true;
  Future<void> _calculateDistances() async {
    try {

      Position driverPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double dist1 = Geolocator.distanceBetween(
        driverPosition.latitude,
        driverPosition.longitude,
        widget.passengerLocation.latitude,
        widget.passengerLocation.longitude,
      );

      double dist2 = Geolocator.distanceBetween(
        widget.passengerLocation.latitude,
        widget.passengerLocation.longitude,
        widget.destinationCoords.latitude,
        widget.destinationCoords.longitude,
      );

      setState(() {
        _enable = false;
        distanceToUser = dist1 / 1000; // km
        distanceToDestination = dist2 / 1000;
      });
    } catch (e) {
      debugPrint('Error getting distances: $e');
    }
  }
  @override
  void initState() {
    super.initState();
    _calculateDistances();
  }
  @override
  Widget build(BuildContext context) {
  return !_enable
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distance to User: ${distanceToUser!.toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Distance to Destination: ${distanceToDestination!.toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 16),
            ),
            // const SizedBox(height: 10),
          ],
        )
      : const Text('Calculating distances...');
}

}