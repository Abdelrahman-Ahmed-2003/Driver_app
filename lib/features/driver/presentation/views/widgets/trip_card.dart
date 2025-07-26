import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/views/widgets/bottom_sheet.dart';
import 'package:flutter/material.dart';

class TripCard extends StatefulWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {


  @override
  Widget build(BuildContext context) {
    final tripDocRef =
        FirebaseFirestore.instance.collection('trips').doc(widget.trip.id);
    return StreamBuilder<DocumentSnapshot>(
      stream: tripDocRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox(); // Trip deleted
        }

        final updatedTrip = Trip.fromFirestore(snapshot.data!);

        return Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.cardBorderLight, width: 1),
          ),
          elevation: 2,
          shadowColor: AppColors.blackColor,
          color: AppColors.whiteColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🗺️ Map (fixed height)
              // SizedBox(
              //   height: 200,
              //   child: ClipRRect(
              //       borderRadius:
              //           const BorderRadius.vertical(top: Radius.circular(20)),
              //       child: Stack(
              //         children: [
              //           // DriverMap(
              //           // ),
              //           // Positioned(
              //           //         bottom: 1,
              //           //         right: 1,
              //           //         child: IconButton(
              //           //           icon: const Icon(Icons.fullscreen,
              //           //               color: AppColors.cardBorderLight),
              //           //           onPressed: () {
              //           //             debugPrint(
              //           //                 "FullScreenMap button pressed");
              //           //                 // mapProvider.reSetMapController();
              //           //             Navigator.push(
              //           //               context,
              //           //               MaterialPageRoute(
              //           //                 builder: (context) =>
              //           //                     ChangeNotifierProvider.value(
              //           //                   value:
              //           //                       mapProvider, // Pass the existing instance
              //           //                   child: FullScreenMap(
              //           //                     userLocation:
              //           //                         updatedTrip.userLocation!,
              //           //                   ),
              //           //                 ),
              //           //               ),
              //           //             );
              //           //           },
              //           //         ),
              //           //       ),
              //         ],
              //       )),
              // ),
          
              // 🧾 Flexible Bottom Part
              BottomSheetDriver(trip: updatedTrip),
            ],
          ),
        );
      },
    );
  }
}
