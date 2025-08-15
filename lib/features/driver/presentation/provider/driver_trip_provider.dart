import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/services/sharedPref/store_proposed_trips.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class DriverTripProvider extends TripProvider {
  // ─────────────────── basic fields ───────────────────
  String? driverId;
  bool isDriverDocIdFetched = false;
  List<Trip> availableTrips = [];
  bool updated = false;
  Map <String, String> propsedTrips = {};  // {tripId: price}
  // Firestore + GPS

  // DriverTripProvider() {
  //   fetchDriverDocId();
  // }

  /* ───────────── init driver id ───────────── */
  Future<void> fetchDriverDocId() async {
    driverId = await StoreUserType.getDriverDocId();
    debugPrint('driverIdselecteTrip: ${driverId}');
    isDriverDocIdFetched = true;
    // notifyListeners();
  }



 set CurrentTrip(Trip trip){
   currentTrip = trip;
   notifyListeners();
 }

  /* ───────────── current location once ───────────── */
  Future<LocationData?> _getCurrentLocation() async {
    final location = Location();

    if (!await location.serviceEnabled() && !await location.requestService()) {
      return null;
    }
    var perm = await location.hasPermission();
    if (perm == PermissionStatus.denied) {
      perm = await location.requestPermission();
      if (perm != PermissionStatus.granted) return null;
    }
    return location.getLocation();
  }

  /* ─────────── driver selects a trip ─────────── */
  Future<void> selectTrip(String tripId) async {
  debugPrint('selectTrip');
  
  driverId = await StoreUserType.getDriverDocId();
  var locationData = await _getCurrentLocation();
  if (locationData == null) {
    throw Exception('Location not available');
  }

  // ✅ Await this so we don't continue until it's done
  await firestore.collection('trips').doc(tripId).update({
    'driverDocId': driverId,
    'driverDistination': 'toUser',
    'status': 'started',
    'driverProposals': FieldValue.delete(),
    'driverLocation': {
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
    },
  });

  await firestore.collection('drivers').doc(driverId).update({
    'tripId': tripId,
  });

  CurrentTrip = Trip.fromFirestore(
    await firestore.collection('trips').doc(tripId).get(),
    'driver',
  );
}


  /* ─────────── update helpers you already had ─────────── */
  Future<void> updateAvailableTrips(List<Map<String, dynamic>> maps) async {
    availableTrips.clear();
    if(driverId == null) await fetchDriverDocId();
    for(var map in maps){
      final trip = Trip.fromMap(map,driverId!);
      availableTrips.add(trip);
      
    }
    // availableTrips = maps.map(Trip.fromMap).toList();
    // notifyListeners();
  }

  Future<void> updateDriverProposal(
      String tripId, String driverId, String price) async {
    await firestore.collection('trips').doc(tripId).update({
      'driverProposals.$driverId.proposedPrice': price,
    });
  }

  

  Future<void> deleteDriverProposal() async {
  WriteBatch batch = FirebaseFirestore.instance.batch();
  debugPrint('Deleting driver proposal');
  debugPrint('Deleting driver proposal: $propsedTrips');
  for (var entry in propsedTrips.entries) {
    final tripId = entry.key;

    final tripDocRef = FirebaseFirestore.instance.collection('trips').doc(tripId);

    // Delete driver's proposal for this trip
    batch.update(tripDocRef, {
      'driverProposals.$driverId': FieldValue.delete(),
    });
    debugPrint('Deleted driver proposal for trip $tripId');
  }

  // Commit all deletions at once for better performance
  await batch.commit();
  await StoreProposedTrips.clear();

  // Clear the local map and reset trip state
  propsedTrips.clear();
  currentTrip = Trip();
}


  @override
  String toString() {
    return 'DriverTripProvider(driverId: '
        ' [32m$driverId [0m, isDriverDocIdFetched: $isDriverDocIdFetched, '
        'availableTrips: $availableTrips';
  }

  @override
  void clear() {
    
    driverId = null;
    isDriverDocIdFetched = false;
    availableTrips = [];
    super.clear();
  }

  void listenTrips() {
    // isLoading = true;
    FirebaseFirestore.instance
        .collection('trips')
        .snapshots()
        .listen((snapshot) {
      debugPrint('Listening to trips...');
      updated = false;
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          debugPrint('Adding trip to availableTrips: ${change.doc.id}');
          availableTrips.add(Trip.fromFirestore(change.doc, driverId!));
          updated = true;
        } else if (change.type == DocumentChangeType.removed) {
          debugPrint('Removing trip from availableTrips: ${change.doc.id}');
          propsedTrips.removeWhere((key, value) => key == change.doc.id);
          availableTrips.removeWhere((t) => t.id == change.doc.id);
          updated = true;
        }
      }
      if(updated == true || isLoading == true) {
        isLoading = false;
        notifyListeners();
      }
      
      
    });
  }
}
