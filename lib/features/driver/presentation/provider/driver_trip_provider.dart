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
  StreamSubscription<LocationData>? _gpsSub;

  DriverTripProvider() {
    _fetchDriverDocId();
  }

  /* ───────────── init driver id ───────────── */
  Future<void> _fetchDriverDocId() async {
    driverId = await StoreUserType.getDriverDocId();
    isDriverDocIdFetched = true;
    notifyListeners();
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

  /* ──────────── available-trips stream ──────────── */
  Stream<List<Map<String, dynamic>>> listenForAvailableTrips() {
    // If already listening, just return the existing broadcast stream
    if (_tripsCtr != null) return _tripsCtr!.stream;

    _tripsCtr = StreamController<List<Map<String, dynamic>>>.broadcast();

    _tripsSub = FirebaseFirestore.instance
        .collection('trips')
        .where('status', isEqualTo: 'waiting')
        .snapshots()
        .listen((snap) {
      final trips = snap.docs
          .where((d) => d['passengerdocId'] != driverId)
          .map((d) => {'tripId': d.id, ...d.data()})
          .toList();

      updateAvailableTrips(trips);   // keep List<Trip> updated
      _tripsCtr?.add(trips);        // push to StreamBuilder
    });

    return _tripsCtr!.stream;
  }

  void _stopTripsStream() {
    _tripsSub?.cancel();
    _tripsSub = null;
    _tripsCtr?.close();
    _tripsCtr = null;
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

  /* ────────────── live GPS tracking ────────────── */
  void _startGpsTracker() {
    final location = Location();

    _gpsSub?.cancel();
    _gpsSub = location.onLocationChanged.listen((d) {
      if (d.latitude == null || d.longitude == null) return;
      if (currentDocumentTrip == null) return;

      currentDocumentTrip!.update({
        'driverLocation': {'latitude': d.latitude, 'longitude': d.longitude}
      });
    });
  }

  void _stopGpsTracker() {
    _gpsSub?.cancel();
    _gpsSub = null;
  }

  /* ─────────── driver selects a trip ─────────── */
  Future<void> selectTrip() async {
    if (currentDocumentTrip == null) return;
    if (!isDriverDocIdFetched) driverId = await StoreUserType.getDriverDocId();
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

  Future<void> updateTripStatus(String status) async =>
      currentDocumentTrip?.update({'status': status});

  Future<void> updateTripPrice(String id, String price) async =>
      FirebaseFirestore.instance.collection('trips').doc(id).update({'price': price});

  Future<void> updateDriverProposal(
      String tripId, String driverId, String price) async {
    await firestore.collection('trips').doc(tripId).update({
      'driverProposals.$driverId.proposedPrice': price,
      'driverProposals.$driverId.proposedPriceStatus': 'refused',
    });
    currentTrip.drivers[driverId]?.proposedPrice = price;
    driverProposal = currentTrip.drivers[driverId];
    notifyListeners();
  }

  /* ───────────── cleanup ───────────── */
  @override
  void dispose() {
    _stopTripsStream();
    _stopGpsTracker();
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
}
