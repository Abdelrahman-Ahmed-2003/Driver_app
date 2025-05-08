import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/driver_with_proposal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:free_map/free_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/trip.dart';

abstract class TripProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // These controllers are UI-related, so they can stay here
  final toController = TextEditingController();
  final priceController = TextEditingController();

  bool isLoading = false;

  // Core Firestore trip document state
  Stream<DocumentSnapshot>? tripStream;
  DocumentReference? currentDocumentTrip;
  Trip currentTrip =Trip();

  // Keep only variables not part of Trip model
  List<LatLng> points = [];
  LatLng? lastDest;

  // UI-related proposals list
  List<DriverWithProposal> driverWithProposalList = [];

  void setCurrentUserLocation(LatLng location) {
    
      currentTrip.userLocation = location;
      // notifyListeners(); // Notify listeners of the update
  
  }

  void setDest(LatLng location) {
    currentTrip.destinationCoords = location;
    notifyListeners(); // Notify listeners of the update
  }

  void setCurrentPoints(LatLng newPoints) async {
    if (points.isEmpty) {
      points.add(newPoints);
    } else {
      points[0] = newPoints;
    }
    await updatePoints();
    notifyListeners();
  }

  void setDestinations(List<LatLng> newPoints) {
    if (currentTrip.userLocation != null) {
      points = [currentTrip.userLocation!, ...newPoints];
    } else {
      points = [...newPoints];
    }
    notifyListeners();
  }

  Future<void> updatePoints() async {
    if (currentTrip.destinationCoords != const LatLng(0, 0)) {
      await fetchRoute();
    }
  }

  Future<void> setCoordinatesPoint(LatLng location) async {
    if (lastDest != location) {
      lastDest = location;
      setDest(location);
      debugPrint('setCoordinatesPoint: $location');
      await fetchRoute();
    }
  }


  /// Update route points based on currentTrip.userLocation and new destination
  Future<void> fetchRoute() async {
    if (currentTrip.destinationCoords == const LatLng(0, 0)|| currentTrip.userLocation == null) return;

    points.clear();
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${currentTrip.userLocation!.longitude},${currentTrip.userLocation!.latitude};'
      '${currentTrip.destinationCoords.longitude},${currentTrip.destinationCoords.latitude}?overview=full&geometries=polyline&steps=true',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    }
  }

  /// Decode polyline and set new route
  void _decodePolyline(String geometry) {
    final polylinePoints = PolylinePoints();
    final result = polylinePoints.decodePolyline(geometry);
    setDestinations(result.map((e) => LatLng(e.latitude, e.longitude)).toList());
  }

  void reconnectTripStream() {
    tripStream = currentDocumentTrip?.snapshots();
  }

  Future<void> updateSelectedDriver(String driverEmail) async {
    if (currentDocumentTrip == null) return;
    await currentDocumentTrip!.update({
      'selectedDriver': driverEmail,
      'driverDistination': 'toUser',
      'status': 'accepted',
    });
  }

  Future<String?> checkUserInTrip(String id, String iam) async {
    final doc = await firestore.collection(iam).doc(id).get();
    return doc.data()?['tripId'];
  }

  

  void clear() {
    toController.clear();
    priceController.clear();
    points = [];
    lastDest = null;
  }
}
