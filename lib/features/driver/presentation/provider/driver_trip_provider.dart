import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class DriverTripProvider extends TripProvider {
  // ─────────────────── basic fields ───────────────────
  String? driverId;
  bool isDriverDocIdFetched = false;
  List<Trip> availableTrips = [];
  DriverProposal? driverProposal;

  // Firestore + GPS
  StreamSubscription<QuerySnapshot>? _tripsSub;
  StreamController<List<Map<String, dynamic>>>? _tripsCtr;

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

  bool fetchOnlineProposedTrip(Trip trip){
    for (var driver in trip.drivers.entries) {
      if (driver.key == driverId) {
        driverProposal = driver.value;
        currentTrip = trip;
        notifyListeners();
        return true;
      }
    }
    notifyListeners();
    return false;
  }

  Future<void> fetchInitialTrips() async {
  final snap = await FirebaseFirestore.instance.collection('trips').get();

  final filtered = snap.docs
      .where((d) {
        final data = d.data();
        if (data['passengerdocId'] == driverId) return false;
        if (!data.containsKey('driverDocId')) {
          return true;
        }
        return false;
      })
      .map((d) => {'tripId': d.id, ...d.data()})
      .toList();

  updateAvailableTrips(filtered);
}



  void _stopTripsStream() {
    _tripsSub?.cancel();
    _tripsSub = null;
    _tripsCtr?.close();
    _tripsCtr = null;
    debugPrint('tripCTr is nullllllll $_tripsCtr');
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
  Future<void> selectTrip() async {
    if (currentDocumentTrip == null) return;
    debugPrint('selectTrip');
    debugPrint('selectTrip: ${isDriverDocIdFetched}');
    driverId = await StoreUserType.getDriverDocId();
    debugPrint('selectTrip: ${driverId}');
    var locationData = await _getCurrentLocation();
    if (locationData == null) {
      throw Exception('Location not available');
    }
    await currentDocumentTrip!.update({
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
      'tripId': currentDocumentTrip!.id,
    });

    currentTrip = Trip.fromFirestore(await currentDocumentTrip!.get());
    currentDocumentTrip = FirebaseFirestore.instance
        .collection('trips')
        .doc(currentTrip.id);
    // tripStream = currentDocumentTrip!.snapshots();
    debugPrint('Selected tripppppppppppppppppp:');
    _stopTripsStream();  // 🚫 stop listening to “waiting” trips
    debugPrint('end of funcitonnnnnnnnnnn:');
    // _startGpsTracker();  // 🚀 start location push
  }

  /* ─────────── update helpers you already had ─────────── */
  void updateAvailableTrips(List<Map<String, dynamic>> maps) {
    availableTrips = maps.map(Trip.fromMap).toList();
    notifyListeners();
  }

  Future<void> updateDriverProposal(
      String tripId, String driverId, String price) async {
    await firestore.collection('trips').doc(tripId).update({
      'driverProposals.$driverId.proposedPrice': price,
    });
    DriverProposal proposal = DriverProposal(
            proposedPrice: price,
    );
    currentTrip.drivers[driverId] = proposal;
    driverProposal = currentTrip.drivers[driverId];
    debugPrint('Updated driver proposal: $driverId with price: $price');
    debugPrint('Current trip drivers: ${currentTrip.drivers[driverId]?.proposedPrice ?? 'nullllllll'}');
    notifyListeners();
  }

  /* ───────────── cleanup ───────────── */
  @override
  void dispose() {
    _stopTripsStream();
    super.dispose();
  }

  Future<void> deleteDriverProposal() async {
    await FirebaseFirestore.instance.collection('trips').doc(currentTrip.id).update({
      'driverProposals.$driverId': FieldValue.delete(),
    });
    currentTrip = Trip();
    currentDocumentTrip = null;
    tripStream = null;
    driverProposal = null;
    notifyListeners();
  }

  @override
  String toString() {
    return 'DriverTripProvider(driverId: '
        ' [32m$driverId [0m, isDriverDocIdFetched: $isDriverDocIdFetched, '
        'availableTrips: $availableTrips, driverProposal: $driverProposal, ';
  }

  @override
  void clear() {
    
    driverId = null;
    isDriverDocIdFetched = false;
    availableTrips = [];
    driverProposal = null;
    _stopTripsStream();
    super.clear();
  }
}
