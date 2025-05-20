import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/driver_card.dart';

class SelectDriver extends StatelessWidget {
  const SelectDriver({super.key});
  static const String routeName = '/select-driver';

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.read<PassengerTripProvider>();
    tripProvider.reconnectTripStream();
  

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Available Drivers"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: tripProvider.tripStream,
        builder: (context, snapshot) {
          debugPrint('snapshot: ${snapshot.connectionState}');
          debugPrint('snapshot data: ${snapshot.data?.data()}');
          // Show loading only for initial connection
          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle case where no trip document exists
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No trip data available'));
          }

          final tripData = snapshot.data!.data() as Map<String, dynamic>;
          final rawDrivers = tripData['driverProposals'] as Map<String, dynamic>? ?? {};
          debugPrint('rawDrivers: $rawDrivers');
          // Immediately show if no drivers are available
          if (rawDrivers.isEmpty) {
            return const Center(child: Text('No drivers available yet'));
          }

          // Convert drivers into the proper format
          final driverMap = rawDrivers.map<String, Map<String, String>>(
            (key, value) => MapEntry(key, Map<String, String>.from(value)),
          );
          debugPrint('Drivermap: $driverMap');
          debugPrint('Drivermap raw: $rawDrivers');
          // Update provider with new driver data

            tripProvider.updateDriverProposalsLocally(driverMap);
          debugPrint('Driver proposals updated locally');

          return Consumer<PassengerTripProvider>(
            builder: (context, provider, child) {
              debugPrint('Driver proposals: ${provider.driverWithProposalList.length}');
              return ListView.builder(
                itemCount: provider.driverWithProposalList.length,
                itemBuilder: (context, index) {
                  return DriverCard(driverWithProposal: provider.driverWithProposalList[index],passengerPrice:provider.currentTrip.price);
                },
              );
            },
          );
        },
      ),
    );
  }
}
