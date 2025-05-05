import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/features/passenger/presentation/provider/tripProvider.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/driver_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectDriver extends StatefulWidget {
  const SelectDriver({super.key});
  static const String routeName = '/select-driver';

  @override
  State<SelectDriver> createState() => _SelectDriverState();
}

class _SelectDriverState extends State<SelectDriver> {
  late final TripProvider _tripProvider;

  @override
  void initState() {
    super.initState();
    _tripProvider = Provider.of<TripProvider>(context, listen: false);
    _tripProvider.reconnectTripStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Available Drivers"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _tripProvider.tripStream,
        builder: (context, snapshot) {
          // Show loading only for initial connection
          if (snapshot.connectionState == ConnectionState.waiting && 
              snapshot.data == null) {
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
          final rawDrivers = tripData['drivers'] as Map<String, dynamic>? ?? {};

          // Immediately show if no drivers are available
          if (rawDrivers.isEmpty) {
            return const Center(child: Text('No drivers available yet'));
          }

          // Convert drivers into the proper format
          final driverMap = rawDrivers.map<String, Map<String, String>>(
            (key, value) => MapEntry(key, Map<String, String>.from(value)),
          );

          // Update provider with new driver data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _tripProvider.updateDrivers(driverMap);
          });

          return Consumer<TripProvider>(
            builder: (context, tripProvider, _) {
              return ListView.builder(
                itemCount: tripProvider.drivers.length,
                itemBuilder: (context, index) {
                  final driver = tripProvider.drivers[index];
                  return DriverCard(driver: driver);
                },
              );
            },
          );
        },
      ),
    );
  }
}