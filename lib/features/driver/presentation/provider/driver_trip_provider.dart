import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class DriverTripProvider extends TripProvider {
  final driver = FirebaseAuth.instance.currentUser;
  String? driverId;
  bool isDriverDocIdFetched = false;

  DriverTripProvider() {
    fetchDriverDocId();
  }
  Future<void> fetchDriverDocId() async {
    driverId = await StoreUserType.getDriverDocId();
    isDriverDocIdFetched = true;
    notifyListeners();
  }

//   // =================================== Firebase Functions ===================================
// Future<void> acceptTrip(String tripId) async {
//   try {
//     if (driver == null) throw "Driver is not logged in";

//     await firestore.collection('trips').doc(tripId).update({
//       'driverId': driver.uid,
//       'status': 'in progress',
//     });
//   } catch (e) {
//     debugPrint("❌ Error accepting trip: $e");
//   }
// }

// Future<void> acceptTrip(String tripId, String driverEmail) async {
  //   currentDocumentTrip = firestore.collection('trips').doc(tripId);
  //   await currentDocumentTrip!.update({
  //     'selectedDriver': driverEmail,
  //     'driverDistination': 'toUser',
  //     'status': 'accepted',
  //   });
  // }

Stream<List<Map<String, dynamic>>> listenForAvailableTrips() {
  debugPrint('Listening for available trips...');
  if (!isDriverDocIdFetched) {
    debugPrint('Driver doc ID not yet fetched');
    return const Stream.empty();
  }

  return FirebaseFirestore.instance
      .collection('trips')
      .where('status', isEqualTo: 'waiting')
      .snapshots()
      .map((snapshot) {
        final trips = snapshot.docs
            .where((doc) => doc['passengerdocId'] != driverId)
            .map((doc) => {'tripId': doc.id, ...doc.data()})
            .toList();

        debugPrint('Fetched trips: $trips');
        return trips;
      });
}



  // 

  Future<void> updateTripStatus(String newStatus) async {
    if (currentDocumentTrip != null) {
      await currentDocumentTrip!.update({'status': newStatus});
    }
  }
}
