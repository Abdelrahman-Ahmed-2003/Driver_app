import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/driver.dart';
import 'package:dirver/core/models/driver_with_proposal.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class PassengerTripProvider extends TripProvider {
  String? passengerDocId;
  bool isPassengerDocIdFetched = false;

  PassengerTripProvider() {
    fetchPassengerDocId();
  }

  
  Future<void> fetchPassengerDocId() async {
    passengerDocId = await StoreUserType.getPassengerDocId();
    isPassengerDocIdFetched = true;
    notifyListeners();
  }

  Future<void> createTrip() async {
    isLoading = true;
    notifyListeners();
    try {
      if (!isPassengerDocIdFetched) {
        passengerDocId = await StoreUserType.getPassengerDocId();
      }
      currentDocumentTrip = await firestore.collection('trips').add({
        'passengerdocId': passengerDocId,
        'destination': currentTrip.destination,
        'userLocation': {
          'lat': currentTrip.userLocation?.latitude,
          'long': currentTrip.userLocation?.longitude,
        },
        'destinationCoords': {
          'lat': currentTrip.destinationCoords.latitude,
          'long': currentTrip.destinationCoords.longitude,
        },
        'price': currentTrip.price,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final passengerRef =
          firestore.collection('passengers').doc(passengerDocId);
      await passengerRef.update({'tripId': currentDocumentTrip?.id});

      tripStream = currentDocumentTrip?.snapshots();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSelectedDriver(DriverWithProposal driver) async {
    if (currentDocumentTrip == null) return;
    await currentDocumentTrip!.update({
      'driverDocId': driver.driver.id,
      'driverDistination': 'toUser',
      'status': 'started',
      'price':driver.proposal.proposedPrice,
      'driverProposals': FieldValue.delete(),
      'driverLocation': {
        'latitude': currentTrip.userLocation!.latitude,
        'longitude': currentTrip.userLocation!.longitude,
      },
    });
    await firestore
        .collection('drivers')
        .doc(driver.driver.id)
        .update({'tripId': currentDocumentTrip!.id});
    currentTrip = Trip.fromFirestore(await currentDocumentTrip!.get());
  }

  Future<void> updateDriverProposalsLocally(
      Map<String, Map<String, String>> driverEmailsWithProposalData) async {
    final List<DriverWithProposal> combined = [];
    debugPrint(
        'Driver emails with proposal data: $driverEmailsWithProposalData');

    for (final entry in driverEmailsWithProposalData.entries) {
      final docId = entry.key;
      final proposalMap = entry.value;

      // Convert to DriverProposal
      final proposal = DriverProposal.fromMap(proposalMap);

      try {
        final result = await firestore.collection('drivers').doc(docId).get();
        debugPrint('Driver document ID: $docId');
        if (result.exists) {
          debugPrint('Driver document exists');
          final driverData = result.data();
          debugPrint('Driver data result id: ${result.data()}');
          final driver = Driver.fromFirestore(result.id, driverData!);
          debugPrint('Driverrrrrrrrrr: $driver');

          combined.add(DriverWithProposal(driver: driver, proposal: proposal));
          debugPrint('Driver with proposal: $driver');
        }
      } catch (e) {
        debugPrint('🔥 Failed to fetch driver data for $docId: $e');
      }
    }
    driverWithProposalList = combined;
    notifyListeners();
  }

  void updateTripDestination(String newDest) {
    currentTrip = currentTrip.copyWith(destination: newDest);
    notifyListeners();
  }

  Future<void> changePassengerPrice(String newData) async {
    if (currentDocumentTrip == null) {
      currentTrip.price = newData;
      notifyListeners();
      return;
    }
    try {
      await currentDocumentTrip!.update({
        'price': newData,
      });
      currentTrip.price = newData;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating data: $e');
    }
  }

  Future<void> changePassengerStraemdestination(String newData) async {
    try {
      await currentDocumentTrip!.set({
        'destination': newData,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating data: $e');
    }
  }

  Future<void> changePassengerStraemdestinationCoords(LatLng newData) async {
    try {
      await currentDocumentTrip!.set({
        'destinationCoords': {
          'lat': newData.latitude,
          'long': newData.longitude,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating data: $e');
    }
  }

  // Get current status from snapshot
  String getCurrentStatus(DocumentSnapshot? snapshot) {
    if (snapshot == null || !snapshot.exists) return 'not_created';
    return (snapshot.data() as Map<String, dynamic>)['status'] ?? 'unknown';
  }

  Future<void> fetchTripData() async {
    debugPrint("Fetching trip data...");

    try {
      passengerDocId ??= await StoreUserType.getPassengerDocId();
      final passengerSnapshot =
          await firestore.collection('passengers').doc(passengerDocId).get();
      debugPrint("Passenger document ID: $passengerDocId");
      if (passengerSnapshot.exists) {
        debugPrint("Passenger document exists");
      } else {
        debugPrint("Passenger document does not exist");
        return;
      }

      final passengerData = passengerSnapshot.data() as Map<String, dynamic>;
      final String? tripId = passengerData['tripId'];
      debugPrint("Trip ID: $tripId");
      if (tripId == null) return;

      // Save the trip document reference and stream
      currentDocumentTrip = firestore.collection('trips').doc(tripId);
      tripStream = currentDocumentTrip?.snapshots();

      final tripSnapshot = await currentDocumentTrip!.get();

      if (!tripSnapshot.exists) return;

      // Convert Firestore document to Trip model
      currentTrip = Trip.fromFirestore(tripSnapshot);
      debugPrint("Current Trip: $currentTrip");

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching trip data: $e');
    }
  }

  Future<void> deleteTrip() async {
    await firestore.collection('passengers').doc(passengerDocId).update({
      'tripId': null,
    });
    if (currentDocumentTrip != null) {
      await currentDocumentTrip!.delete();
      cancelStream();
    }
  }

  void cancelStream() {
    tripStream = null;
    currentDocumentTrip = null;
    driverWithProposalList = [];
    notifyListeners();
  }
}
