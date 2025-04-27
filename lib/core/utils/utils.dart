import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void errorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating, // <-- Important!!
      margin: const EdgeInsets.all(20), // <-- Add margin to not cover bottomNavigationBar
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

// =================================== Firebase Functions ===================================
Future<void> acceptTrip(String tripId) async {
  try {
    final driver = FirebaseAuth.instance.currentUser;
    if (driver == null) throw "Driver is not logged in";

    await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
      'driverId': driver.uid,
      'status': 'in progress',
    });
  } catch (e) {
    debugPrint("❌ Error accepting trip: $e");
  }
}

Stream<List<Map<String, dynamic>>> listenForAvailableTrips() {
  final user = FirebaseAuth.instance.currentUser;
  return FirebaseFirestore.instance
      .collection('trips')
      .where('status', isEqualTo: 'waiting')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .where((doc) => doc['passengerEmail'] != user?.email)
          .map((doc) => {'tripId': doc.id, ...doc.data()})
          .toList());
}
