import 'package:dirver/core/models/trip.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/widgets/bottom_sheet_to_user.dart';
import 'package:dirver/features/trip/presentation/views/widgets/tracking_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class PassengerTripView extends StatelessWidget {
  const PassengerTripView({super.key});
  static const String routeName = '/PassengerTripView';

  @override
  Widget build(BuildContext context) {
    var tripProvider = context.read<DriverTripProvider>();
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Driver move to you"),
      ),
      body: StreamBuilder(
        stream: tripProvider.tripStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No trip data available'));
          }
          
          tripProvider.currentTrip = Trip.fromFirestore(snapshot.data!);

          return Column(
            children: [
              TrackingMap(
            current: tripProvider.currentTrip.driverLocation ?? const LatLng(0, 0),
            destination: tripProvider.currentTrip.userLocation ?? const LatLng(0, 0),
          ),
          BottomSheetToUser()
            ],
          );
        },
      ),
    ));
  }
}