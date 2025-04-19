import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/features/passenger_home/presentation/provider/tripProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = context.read<ContentOfTripProvider>();
    final tripProvider = context.watch<TripProvider>(); // WATCH to reflect UI changes

    return Padding(
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
                  return ElevatedButton(
                    onPressed: () async {
                      await tripProvider.cancelTrip();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text(
                      "Cancel Trip",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  );
                }

                return ElevatedButton(
                  onPressed: () => _createTrip(context, contentProvider, tripProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF661AFD),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    "Create Trip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
    ContentOfTripProvider contentProvider,
    TripProvider tripProvider,
  ) async {
    if (contentProvider.toController.text.isEmpty || 
        contentProvider.priceController.text.isEmpty) {
      errorMessage(context, 'Please fill all fields');
      return;
    }

    try {
      await tripProvider.createNewTrip(contentProvider);
    } catch (e) {
      errorMessage(context, 'Failed to create trip: $e');
    }
  }
}
