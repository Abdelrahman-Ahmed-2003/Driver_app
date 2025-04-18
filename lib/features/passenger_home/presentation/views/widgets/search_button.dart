import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/features/passenger_home/presentation/provider/trip_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            // var provider = context.read<TripProvider>();
            // if(provider.toController.text.isEmpty) return;
            // try {
            //   CollectionReference trips = FirebaseFirestore.instance.collection('trips');
              
            //   User? user = FirebaseAuth.instance.currentUser;
            //   // Create a new trip document
            //   await trips.add({
            //     'passengerEmail': user?.email,
            //     'passengerName': user?.displayName,
            //     'passengerPhone': user?.phoneNumber,
            //     'destination': provider.toController.text,
            //     'destinationCoords': {
            //       'lat': provider.dest.latitude,
            //       'long': provider.dest.longitude
            //     },
            //     'status': 'waiting', // ✅ Initially, trip is waiting for a driver
            //     'driverId': null,
            //     'createdAt': FieldValue.serverTimestamp(),
            //   });
      
            //   debugPrint("🚀 Trip created successfully!");
            // } catch (e) {
            //   debugPrint("❌ Error creating trip: $e");
            // }
      
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0XFF661AFD),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          child: Text(
            "create trip",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
