// =================================== Trip Card ===================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/trip_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    debugPrint('trip card: $trip');
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.greyColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Trip to: ${trip.destination}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            // const SizedBox(height: 12),
            // Text(
            //   "Passenger: ${trip['passengerName']}",
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: AppColors.darkGrey,
            //   ),
            // ),
            const SizedBox(height: 20),
            Chip(
              backgroundColor: Colors.amber.shade100,
              label: Text(
                "${trip.price} EGP",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  //  backgroundColor: AppColors.grenColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  try {
                    var provider =
                        Provider.of<DriverTripProvider>(context, listen: false);
                    provider.currentTrip = trip;
                    provider.currentDocumentTrip = FirebaseFirestore.instance
                        .collection('trips')
                        .doc(trip.id);
                    provider.tripStream =
                        provider.currentDocumentTrip!.snapshots();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: provider, // same instance!
                          child: const TripView(),
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                    await provider.selectTrip();
                    debugPrint('before navigator');
                    // if (!context.mounted) {
                    //   debugPrint('context is not mounted, returning');
                    //   return;
                    // } // widget might be gone after await

                    // ➋ push TripView and keep the same provider instance alive
                    
                    debugPrint('its okeyyyyyyyyyyyyyyyyyy');
                  } catch (e) {
                    debugPrint('Error selecting driver: $e');
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error selecting driver: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // Update the price in the trip document
                  //  if(nameOfButton == 'update price'){
                  //  FirebaseFirestore.instance.collection('trips').doc(widget.trip['tripId']).update({
                  //    'updatedPrice': priceController.text,
                  //  });}
                  //  acceptTrip(widget.trip['tripId']);
                },
                child: Text('Accept Trip', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
