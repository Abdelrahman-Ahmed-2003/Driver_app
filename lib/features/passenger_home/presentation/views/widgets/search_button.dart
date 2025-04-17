import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/passenger_home/presentation/provider/trip_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: () async {
          try {
            CollectionReference trips = FirebaseFirestore.instance.collection('trips');
            var provider = context.read<TripProvider>();
            User? user = FirebaseAuth.instance.currentUser;
            // Create a new trip document
            await trips.add({
              'passengerEmail': user?.email,
              'passengerName': user?.displayName,
              'passengerPhone': user?.phoneNumber,
              'destination': provider.toController.text,
              'destinationCoords': {
                'lat': provider.dest.latitude,
                'long': provider.dest.longitude
              },
              'status': 'waiting', // ✅ Initially, trip is waiting for a driver
              'driverId': null,
              'createdAt': FieldValue.serverTimestamp(),
            });

            print("🚀 Trip created successfully!");
          } catch (e) {
            print("❌ Error creating trip: $e");
          }

        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0XFF661AFD),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Text(
          "Search",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
