import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/driver.dart';
import 'package:dirver/core/models/driver_with_proposal.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:flutter/material.dart';

class PassengerTripProvider extends TripProvider {
  Future<void> createTrip() async {
    isLoading = true;
    notifyListeners();
    try {
      var passengerId = await StoreUserType.getPassengerDocId();
      currentDocumentTrip = await firestore.collection('trips').add({
        'passengerdocId': passengerId,
        'destination': toController.text,
        'userLocation': {
          'lat': currentLocation?.latitude,
          'long': currentLocation?.longitude,
        },
        'destinationCoords': {
          'lat': dest.latitude,
          'long': dest.longitude,
        },
        'price': priceController.text,
        'status': 'waiting',
        'driverproposals': {},
        'createdAt': FieldValue.serverTimestamp(),
      });

      
      final passengerRef = firestore.collection('passengers').doc(passengerId);
      await passengerRef.update({'tripId': currentDocumentTrip?.id});

      tripStream = currentDocumentTrip?.snapshots();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDriverProposalsLocally(
    Map<String, Map<String, String>> driverEmailsWithProposalData) async {
  final List<DriverWithProposal> combined = [];

  for (final entry in driverEmailsWithProposalData.entries) {
    final docId = entry.key;
    final proposalMap = entry.value;

    // Convert to DriverProposal
    final proposal = DriverProposal.fromMap(proposalMap);

    try {
      final result = await firestore.doc(docId).get();

      if (result.exists) {
        final driverData = result.data();
        final driver = Driver.fromFirestore(result.id, driverData!);

        combined.add(DriverWithProposal(driver: driver, proposal: proposal));
      }
    } catch (e) {
      debugPrint('🔥 Failed to fetch driver data for $docId: $e');
    }
  }
  driverWithProposalList = combined;
  notifyListeners();
}



  Future<void> changePassengerProposalPrice(String docId, String newPrice) async {
    try {
      await currentDocumentTrip!.set({
        'driverproposals': {
          docId: {
            'passengerProposedPrice': newPrice,
            'proposedPriceStatus': 'pending',
          }
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating price: $e');
    }
  }

  // Get current status from snapshot
  String getCurrentStatus(DocumentSnapshot? snapshot) {
    if (snapshot == null || !snapshot.exists) return 'not_created';
    return (snapshot.data() as Map<String, dynamic>)['status'] ?? 'unknown';
  }
}
