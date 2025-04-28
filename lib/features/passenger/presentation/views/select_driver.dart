import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/driver.dart';
import 'package:dirver/features/passenger/presentation/provider/tripProvider.dart';
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

    if (tripProvider.drivers.isEmpty && driverEmails.isNotEmpty) {
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
          onSelect: () => _selectDriver(context, tripProvider, driver),
        );
      },
    );
  },
);

        },
      ),
    );
  }

  void _selectDriver(BuildContext context, TripProvider tripProvider, Driver driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Driver'),
        content: Text('Select ${driver.name ?? driver.email} for this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              tripProvider.updateSelectedDriver(driver.email);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${driver.name ?? driver.email} selected')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback onSelect;

  const DriverCard({
    super.key,
    required this.driver,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: driver.imageUrl != null 
              ? NetworkImage(driver.imageUrl!) 
              : null,
          child: driver.imageUrl == null 
              ? Text(driver.email[0].toUpperCase())
              : null,
        ),
        title: Text(driver.name ?? driver.email),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (driver.vehicleType != null) Text(driver.vehicleType!),
            if (driver.rating != null)
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(driver.rating!.toStringAsFixed(1)),
                ],
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onSelect,
      ),
    );
  }
}