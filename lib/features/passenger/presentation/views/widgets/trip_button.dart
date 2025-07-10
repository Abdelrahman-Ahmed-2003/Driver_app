import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/passenger_trip_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dirver/core/utils/utils.dart';
class TripButton extends StatelessWidget {
  const TripButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<PassengerTripProvider>(); // WATCH to reflect UI changes

    return tripProvider.isLoading?LinearProgressIndicator():Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        width: double.infinity,
        child: Builder(
          builder: (context) {
            final snapshot = tripProvider.tripStream;
            return StreamBuilder<DocumentSnapshot>(
              stream: snapshot,
              builder: (context, tripSnapshot) {
                final status = tripProvider.getCurrentStatus(tripSnapshot.data);
                
                if (status == 'waiting') {
                  return FilledButton(
                    onPressed: () async {
                      await tripProvider.deleteTrip();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.redColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Cancel Trip",
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }
                if(status == 'started') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create:(_)=>DriverTripProvider(), // same instance!
                          child: const PassengerTripView(),
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  });
                  return const SizedBox.shrink(); // No button if trip is started
                }
                
                return FilledButton(
                  onPressed: () => _createTrip(context,tripProvider),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Create Trip",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _createTrip(
    BuildContext context,
    PassengerTripProvider tripProvider,
  ) async {
    if (tripProvider.currentTrip.destination.isEmpty || 
        tripProvider.currentTrip.price.isEmpty) {
      errorMessage(context, 'Please fill all fields');
      return;
    }

    try {
      await tripProvider.createTrip();
    } catch (e) {
      if (!context.mounted) return;
      errorMessage(context, 'Failed to create trip: $e');
    }
  }
}
