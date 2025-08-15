import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/driver_with_proposal.dart';
import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';
import '../models/trip.dart';

abstract class TripProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // Core Firestore trip document state
  Stream<DocumentSnapshot>? tripStream;
  DocumentReference? currentDocumentTrip;
  Trip currentTrip = Trip();

  // UI-related proposals list
  List<DriverWithProposal> driverWithProposalList = [];

  // void setCurrentUserLocation(LatLng location) {
  //   currentTrip.userLocation = location;
  //   // notifyListeners(); // Notify listeners of the update
  // }

  Future<void> fetchOnlineTrip(String tripId, String iam) async {
    isLoading = true;
    notifyListeners(); // Notify listeners of the loading state
    try {
      
      currentDocumentTrip = firestore.collection('trips').doc(tripId);
      tripStream = currentDocumentTrip?.snapshots();
      final snapshot = await currentDocumentTrip!.get();
      if (snapshot.exists) {
        currentTrip = Trip.fromFirestore(snapshot, iam);
        debugPrint('fetchOnlineTrip: $currentTrip');
      } else {
        debugPrint('No trip found with ID: $tripId');
      }
    } catch (e) {
      debugPrint('Error fetching trip: $e');
    } finally {
      isLoading = false;
        notifyListeners(); // Notify listeners of the loading state change
      
    }
  }

  Future<bool> updateDestination(String dest) async {
    debugPrint('updateDestination: ${currentTrip.id}');
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(currentTrip.id)
        .update({
      'driverDistination': dest,
    });
    currentTrip.driverDistination = 'toDestination';

    notifyListeners();
    return true;
  }

  Future<void> endTrip() async {
    await firestore.collection('drivers').doc(currentTrip.driverId).update({
      'tripId': FieldValue.delete(),
    });
    debugPrint('endTrip: ${currentTrip.passengerId}');
    await firestore
        .collection('passengers')
        .doc(currentTrip.passengerId)
        .update({
      'tripId': FieldValue.delete(),
    });

    await firestore.collection('trips').doc(currentTrip.id).delete();
    currentTrip = Trip(); // Reset currentTrip after ending
    currentDocumentTrip = null; // Clear the current document reference
    tripStream = null; // Stop listening to the trip stream
  }

  Future<void> pushDriverLocation(LatLng location) async {
    if (currentTrip.driverLocation == null ||
        currentTrip.driverLocation != location) {
      debugPrint('in condation of rebuild in push funciton');
      currentTrip.driverLocation = location;
      debugPrint('pushDriverLocation before notifyListeners');
      notifyListeners(); // Notify listeners of the update
      debugPrint('pushDriverLocation: $location');
      if (currentDocumentTrip != null) {
        await firestore
            .collection('trips')
            .doc(currentDocumentTrip!.id)
            .update({
          'driverLocation': {
            'lat': location.latitude,
            'long': location.longitude
          },
        });
      }
    }
    debugPrint('pushDriverLocation after notifyListeners');
  }

  void reconnectTripStream() {
    tripStream = currentDocumentTrip?.snapshots();
  }

  Future<String?> checkUserInTrip(String id, String iam) async {
    final doc = await firestore.collection(iam).doc(id).get();
    return doc.data()?['tripId'];
  }

  void clear() {
    currentTrip = Trip();
    currentDocumentTrip = null;
    tripStream = null;
    driverWithProposalList = [];
    isLoading = false;
  }
}
