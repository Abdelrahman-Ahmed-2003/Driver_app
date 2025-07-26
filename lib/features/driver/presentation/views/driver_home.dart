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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<DriverTripProvider>();

      await StoreUserType.saveDriver(true);
      await StoreUserType.saveLastSignIn('driver');

      if (!provider.isDriverDocIdFetched) {
        await provider.fetchDriverDocId();
      }

      await provider.fetchInitialTrips(); // ✅ Fetch all trips once
      await _checkDriverTripAndRedirect(context, provider);

      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.read<DriverTripProvider>();
    debugPrint('DriverHome Rebuild');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Available Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await StoreUserType.saveLastSignIn('null');
              provider.clear();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DriverOrRiderView()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {

                if (provider.availableTrips.isEmpty) {
                  return const Center(child: NoTripWidget());
                }

                return const AnimatedCards(); // ListView with per-trip StreamBuilder
              },
            ),
    );
  }

  Future<void> _checkDriverTripAndRedirect(
    BuildContext context,
    DriverTripProvider provider,
  ) async {
    try {
      debugPrint('Checking driver trip...');

      final docSnapshot = await provider.firestore
          .collection('drivers')
          .doc(provider.driverId)
          .get();

      final data = docSnapshot.data();

      if (data != null && data['tripId'] != null) {
        debugPrint('Driver has an active trip: ${data['tripId']}');

        if (!context.mounted) return;

        if (provider.currentTrip == Trip()) {
          provider.currentDocumentTrip =
              provider.firestore.collection('trips').doc(data['tripId']);

          final tripSnapshot = await provider.currentDocumentTrip!.get();
          provider.currentTrip = Trip.fromFirestore(tripSnapshot);
        }

        provider.tripStream = provider.currentDocumentTrip!.snapshots();

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
