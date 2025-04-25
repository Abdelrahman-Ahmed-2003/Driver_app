import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TripProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<DocumentSnapshot>? _tripStream;
  DocumentReference? _currentTrip;

  // Get current trip stream
  Stream<DocumentSnapshot>? get tripStream => _tripStream;

  // Create new trip using data from ContentOfTripProvider
  Future<void> createNewTrip(ContentOfTripProvider contentProvider) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // Create trip document
      _currentTrip = await _firestore.collection('trips').add({
        'passengerEmail': user?.email,
        'passengerName': user?.displayName,
        'destination': contentProvider.toController.text,
        'userLocation': {
          'lat': contentProvider.currentLocation?.latitude,
          'long': contentProvider.currentLocation?.longitude,
        },
        'destinationCoords': {
          'lat': contentProvider.dest.latitude,
          'long': contentProvider.dest.longitude,
        },
        'price': contentProvider.priceController.text,
        'status': 'waiting',
        'driverId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Start listening to the created trip
      _tripStream = _currentTrip?.snapshots();
      notifyListeners();

    } catch (e) {
      
      debugPrint("Error creating trip: $e");
      rethrow;
    }
  }

  // Cancel the current trip stream
  void cancelStream() {
    _tripStream = null;
    _currentTrip = null;
    notifyListeners();
  }

//   Future<void> cancelTrip() async {
//   if (_currentTrip != null) {
//     await _currentTrip!.update({'status': 'cancelled'});
//     cancelStream();
//   }
// }

  Future<void> deleteTrip() async {
    if (_currentTrip != null) {
      await _currentTrip!.delete();
      cancelStream();
    }
  }


  // Helper to get current status
  String getCurrentStatus(DocumentSnapshot? snapshot) {
    if (snapshot == null || !snapshot.exists) return 'not_created';
    return (snapshot.data() as Map<String, dynamic>)['status'] ?? 'unknown';
  }
}