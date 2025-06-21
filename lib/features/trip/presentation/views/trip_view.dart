import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripView extends StatelessWidget {
  const TripView({
    super.key,
  });
  static const String routeName = '/TripView';
  @override
  Widget build(BuildContext context) {
    debugPrint('TripView build');
    var provider = context.read<DriverTripProvider>();
    // tripProvider.reconnectTripStream();
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("Trip Started"),
            ),
            body: StreamBuilder<DocumentSnapshot>(
                stream: provider.tripStream,
                builder: (context, snapshot) {
                  debugPrint('snapshot: ${snapshot.connectionState}');
                  debugPrint('snapshot data: ${snapshot.data?.data()}');
                  // Show loading only for initial connection
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());}
                  return Center(child:Text('data'));
                  },)));
  }
}
