import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/bottom_sheet.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/show_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class SelectedTrip extends StatelessWidget {
  const SelectedTrip({super.key});
  static const String routeName = '/selected_trip';

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<DriverTripProvider>(context, listen: false);
    print('trip rebuild selected trip');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Details"),
      ),
      body: Stack(
        children: [
          ShowMap(isDriver: true,destination: LatLng(tripProvider.currentTrip.userLocation!.latitude, tripProvider.currentTrip.userLocation!.longitude),
         tripProvider:tripProvider
        ),
        BottomSheetDriver()
        ],
        
      )
    );
  }
}