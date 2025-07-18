import 'package:dirver/core/models/trip.dart';
import 'package:dirver/features/driver/presentation/views/widgets/no_trip_widget.dart';
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
    var provider = context.watch<DriverTripProvider>();
    debugPrint('rebuilddddddddddddddddddddddddddddddddddd');

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Available Trips'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () async {
                await StoreUserType.saveLastSignIn('null');

                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => DriverOrRiderView()),
                  (route) => false,
                );
                provider.clear();
              },
            ),
          ],
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: provider.listenForAvailableTrips(),
          builder: (_, snap) {
            _checkDriverTripAndRedirect(context, provider);
            if (snap.connectionState == ConnectionState.waiting) {
              debugPrint('Waiting for available trips...');
              return const Center(child: CircularProgressIndicator());
            }

            if (!snap.hasData || snap.data!.isEmpty) {
              return Center(child: NoTripWidget());
            }

            return const AnimatedCards();
          },
        ));
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
          provider.currentDocumentTrip =
              provider.firestore.collection('trips').doc(data['tripId']);

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
            builder: (_) => const DriverTripView(),
          ),
          (_) => false,
        );
      }
    } catch (e) {
      debugPrint('Error checking trip: $e');
    }
  }
}
