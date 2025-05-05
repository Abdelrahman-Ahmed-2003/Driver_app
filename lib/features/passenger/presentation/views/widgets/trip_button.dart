import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger/presentation/provider/tripProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dirver/core/utils/utils.dart';
class TripButton extends StatelessWidget {
  const TripButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>(); // WATCH to reflect UI changes

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
                  return ElevatedButton(
                    onPressed: () async {
                      await tripProvider.deleteTrip();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text(
                      "Cancel Trip",
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 20,
                      ),
                    ),
                  );
                }

                return ElevatedButton(
                  onPressed: () => _createTrip(context,tripProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    "Create Trip",
                    style: TextStyle(
                      color: AppColors.whiteColor,
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
    TripProvider tripProvider,
  ) async {
    if (tripProvider.toController.text.isEmpty || 
        tripProvider.priceController.text.isEmpty) {
      errorMessage(context, 'Please fill all fields');
      return;
    }

    try {
      await tripProvider.createNewTrip();
    } catch (e) {
      if (!context.mounted) return;
      errorMessage(context, 'Failed to create trip: $e');
    }
  }
}
