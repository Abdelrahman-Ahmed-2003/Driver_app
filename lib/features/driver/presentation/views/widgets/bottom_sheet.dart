import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/button_widget.dart';
import 'package:dirver/features/driver/presentation/views/widgets/dest_widget.dart';
import 'package:dirver/features/driver/presentation/views/widgets/price_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class BottomSheetDriver extends StatefulWidget {
  final Trip trip;
  const BottomSheetDriver({super.key, required this.trip});

  @override
  State<BottomSheetDriver> createState() => _BottomSheetDriverState();
}

class _BottomSheetDriverState extends State<BottomSheetDriver> {
  final TextEditingController _driverController = TextEditingController();
  double? distanceToUser;
  double? distanceToDestination;

  @override
  void initState() {
    super.initState();
    _calculateDistances();
  }

  Future<void> _calculateDistances() async {
    try {
      Position driverPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Distance from driver to user
      double dist1 = Geolocator.distanceBetween(
        driverPosition.latitude,
        driverPosition.longitude,
        widget.trip.userLocation!.latitude,
        widget.trip.userLocation!.longitude,
      );

      // Distance from user to destination
      double dist2 = Geolocator.distanceBetween(
        widget.trip.userLocation!.latitude,
        widget.trip.userLocation!.longitude,
        widget.trip.destinationCoords.latitude,
        widget.trip.destinationCoords.longitude,
      );

      setState(() {
        distanceToUser = dist1 / 1000; // convert to kilometers
        distanceToDestination = dist2 / 1000;
      });
    } catch (e) {
      print('Error getting distances: $e');
    }
  }

  @override
  void dispose() {
    _driverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverTripProvider>(context, listen: false);
    if (provider.currentTrip != Trip() &&
        provider.currentTrip.id == widget.trip.id) {
      _driverController.text =
          provider.driverProposal!.proposedPrice.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChangeNotifierProvider(
            create: (_) => MapProvider(),
            child: DestWidget(destination: widget.trip.destination,destinationCoords: widget.trip.destinationCoords,passengerLocation: widget.trip.userLocation!,),
          ),
          
          const SizedBox(height: 10),
          if (distanceToUser != null && distanceToDestination != null) ...[
            Text(
              'Distance to User: ${distanceToUser!.toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Distance to Destination: ${distanceToDestination!.toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
          ] else
            const Center(child: CircularProgressIndicator()),
          PriceWidget(driverController: _driverController, trip: widget.trip),
          const SizedBox(height: 10),
          ButtonWidget(driverController: _driverController, trip: widget.trip),
        ],
      ),
    );
  }
}
