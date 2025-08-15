import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/views/widgets/address_widget.dart';
import 'package:dirver/features/driver/presentation/views/widgets/destance_widget.dart';
import 'package:dirver/features/driver/presentation/views/widgets/trip_action_widget.dart';
import 'package:dirver/features/trip/presentation/views/driver_trip_view.dart';
import 'package:flutter/material.dart';

class TripCard extends StatefulWidget {
  Trip trip;

  TripCard({super.key, required this.trip});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
 
  StreamSubscription<DocumentSnapshot>? _tripSubscription;

  @override
  void initState() {
    super.initState();
    

// WidgetsBinding.instance.addPostFrameCallback((_) async {
      
_tripSubscription = FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.trip.id)
        .snapshots()
        .listen((snapshot) {
          if(snapshot.data()!.containsKey('driverDocId')){
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DriverTripView()),
                (route) => false,
              );
              return;
          }
      debugPrint('trip modified');
      widget.trip = Trip.fromFirestore(snapshot, widget.trip.driverId);
      setState(() {
        debugPrint('trip card rebuild in initstate');
      });
    });
      
    // });
    // Listen to trip updates
  
    
  }

  @override
  void dispose() {
    _tripSubscription?.cancel(); // Cancel Firestore listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("TripCard rebuild ${widget.trip.id}");

    

    return buildCard(widget.trip);
  }

  Widget buildCard(Trip trip) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorderLight, width: 1),
      ),
      elevation: 2,
      shadowColor: AppColors.blackColor,
      color: AppColors.whiteColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddressWidget(
              destination: trip.destination,
              destinationCoords: trip.destinationCoords,
              passengerLocation: trip.userLocationCoords!,
            ),
            const SizedBox(height: 10),
            DestanceWidget(destination: trip.destination, destinationCoords: trip.destinationCoords, passengerLocation: trip.userLocationCoords!),
            TripActionWidget(trip: trip),
          ],
        ),
      ),
    );
  }
}
