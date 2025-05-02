import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/features/passenger/presentation/provider/tripProvider.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/driver_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectDriver extends StatelessWidget {
  const SelectDriver({super.key});
  static const String routeName = '/select-driver';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Available Drivers"),
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          tripProvider.reconnectTripStream();
          return StreamBuilder<DocumentSnapshot>(
  stream: tripProvider.tripStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    if (!snapshot.hasData || !snapshot.data!.exists) {
      return const Center(child: Text('No trip data available'));
    }

    // 🔥 New code: Fetch drivers when snapshot updates
    final tripData = snapshot.data!.data() as Map<String, dynamic>;
    final driverEmails = List<String>.from(tripData['driversMails'] ?? []);

    if (tripProvider.drivers.length != driverEmails.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tripProvider.updateDriversList(driverEmails);
      });
    }

    if (tripProvider.drivers.isEmpty) {
      return const Center(child: Text('No drivers available yet'));
    }

    return ListView.builder(
      itemCount: tripProvider.drivers.length,
      itemBuilder: (context, index) {
        final driver = tripProvider.drivers[index];
        return DriverCard(
          driver: driver,
        );
      },
    );
  },
);

        },
      ),
    );
  }

  // void _selectDriver(BuildContext context, TripProvider tripProvider, Driver driver) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Confirm Driver'),
  //       content: Text('Select ${driver.name ?? driver.email} for this trip?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             tripProvider.updateSelectedDriver(driver.email);
  //             Navigator.pop(context);
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text('${driver.name ?? driver.email} selected')),
  //             );
  //           },
  //           child: const Text('Confirm'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
