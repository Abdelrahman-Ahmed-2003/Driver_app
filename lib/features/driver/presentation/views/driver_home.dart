import 'package:dirver/core/models/trip.dart';
import 'package:dirver/features/trip/presentation/views/driver_trip_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/animated_cards.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  static const String routeName = '/driver_home';

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await StoreUserType.saveDriver(true);
      await StoreUserType.saveLastSignIn('driver');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverTripProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Available Trips'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () async {
                await StoreUserType.saveLastSignIn('null');
                await StoreUserType.saveDriverDocId('null');
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(
                  context,
                  DriverOrRiderView.routeName,
                );
              },
            ),
          ],
        ),
        body: Consumer<DriverTripProvider>(
          builder: (_, provider, __) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: provider.listenForAvailableTrips(),
              builder: (_, snap) {
                _checkDriverTripAndRedirect(context, provider);
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snap.hasData || snap.data!.isEmpty) {
                  return const Center(child: Text('No available trips'));
                }

                return const AnimatedCards();
              },
            );
          },
        ),
      ),
    );
  }

  // ✅ Extracted trip check logic
  Future<void> _checkDriverTripAndRedirect(
  BuildContext context,
  DriverTripProvider provider,
) async {
  try {
    debugPrint('Checking driver trip...');

    // Fetch driver document ID if not already fetched
    if (!provider.isDriverDocIdFetched) {
      await provider.fetchDriverDocId();
    }

    // Get driver's document snapshot
    final docSnapshot = await provider.firestore
        .collection('drivers')
        .doc(provider.driverId)
        .get();

    final data = docSnapshot.data();

    // Check if driver has an active trip
    if (data != null && data['tripId'] != null) {
      debugPrint('Driver has an active trip: ${data['tripId']}');

      if (!context.mounted) return;

      // Check if currentTrip is null or not set
      if (provider.currentTrip == Trip()) {
        // Get the trip document reference
        provider.currentDocumentTrip = provider.firestore
            .collection('trips')
            .doc(data['tripId']);

        // Fetch the trip snapshot
        final tripSnapshot = await provider.currentDocumentTrip!.get();

        // Parse trip data
        provider.currentTrip = Trip.fromFirestore(tripSnapshot);
      }

      // Start listening to trip updates
      provider.tripStream = provider.currentDocumentTrip!.snapshots();

      // Navigate to DriverTripView
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: const DriverTripView(),
          ),
        ),
        (_) => false,
      );
    }
  } catch (e) {
    debugPrint('Error checking trip: $e');
  }
}

}
