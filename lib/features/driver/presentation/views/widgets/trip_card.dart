import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/dest_widget.dart';
import 'package:dirver/features/driver/presentation/views/widgets/trip_action_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TripCard extends StatefulWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  double? distanceToUser;
  double? distanceToDestination;
  bool _enable = true;
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
        _enable = false;
        debugPrint('dist1: $dist1, dist2: $dist2');
        distanceToUser = dist1 / 1000; // convert to kilometers
        distanceToDestination = dist2 / 1000;
      });
    } catch (e) {
      print('Error getting distances: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("TripCard Rebuild ${widget.trip.id}");
    final tripDocRef =
        FirebaseFirestore.instance.collection('trips').doc(widget.trip.id);
    return StreamBuilder<DocumentSnapshot>(
      stream: tripDocRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          debugPrint('StreamBuilder no data${widget.trip.id}');
          return const SizedBox(); // Trip deleted
        }
        debugPrint('StreamBuilder state build ${widget.trip.id}');
        var provider = context.watch<DriverTripProvider>();
        final updatedTrip =
            Trip.fromFirestore(snapshot.data!, provider.driverId!);

        if (updatedTrip.driverProposalPrice != null) {
          debugPrint(
              'updatedTrip driverProposalPrice ${updatedTrip.driverProposalPrice}');
          provider.currentTrip = updatedTrip;
        }
        debugPrint('updatedTrip ${updatedTrip.toString()}');
        return Skeletonizer(
            enabled: _enable,
            enableSwitchAnimation: true,
            child: buildCard(updatedTrip));
      },
    );
  }

  Widget buildCard(Trip trip) {
    debugPrint('buildCard ');
    debugPrint(trip.driverProposalPrice ?? 'nulllllllllllllllllllll');
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorderLight, width: 1),
      ),
      elevation: 2,
      shadowColor: AppColors.blackColor,
      color: AppColors.whiteColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChangeNotifierProvider(
                  create: (_) => MapProvider(),
                  child: DestWidget(
                    destination: trip.destination,
                    destinationCoords: trip.destinationCoords,
                    passengerLocation: trip.userLocation!,
                  ),
                ),
                const SizedBox(height: 10),
                if (!_enable) ...[
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
                  const Text('Calculating distances...'),
                TripActionWidget(trip: trip),
              ],
            ),
          )
        ],
      ),
    );
  }
}
