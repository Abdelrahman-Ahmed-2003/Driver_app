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
  final toController = TextEditingController();
  final priceController = TextEditingController();

  bool isLoading = false;
  Stream<DocumentSnapshot>? tripStream;
  DocumentReference? currentDocumentTrip;
  Trip? currentTrip;

  String from = '';
  LatLng dest = const LatLng(0, 0);
  List<LatLng> points = [];
  LatLng? currentLocation;
  LatLng? lastDest;
  String status = 'not_created';

  List<DriverWithProposal> driverWithProposalList=[];

  void setFrom(String value) {
    from = value;
    notifyListeners();
  }

  void setDest(LatLng value) {
    dest = value;
    notifyListeners();
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
    if (currentLocation != null) {
      points = [currentLocation!, ...newPoints];
    } else {
      points = [...newPoints];
    }
    notifyListeners();
  }

  Future<void> setCoordinatesPoint(LatLng location) async {
    if (lastDest != location) {
      lastDest = location;
      setDest(location);
      debugPrint('setCoordinatesPoint: $location');
      await fetchRoute();
    }
  }

  Future<void> updatePoints() async {
    if (dest != const LatLng(0, 0)) {
      await fetchRoute();
    }
  }

  Future<void> fetchRoute() async {
    if (currentLocation == null || dest == const LatLng(0, 0)) return;

    points.clear();
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${currentLocation!.longitude},${currentLocation!.latitude};'
      '${dest.longitude},${dest.latitude}?overview=full&geometries=polyline&steps=true',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    }
  }

  void _decodePolyline(String geometry) {
    final polylinePoints = PolylinePoints();
    final result = polylinePoints.decodePolyline(geometry);
    setDestinations(result.map((e) => LatLng(e.latitude, e.longitude)).toList());
  }

  void _initializeTripStream() {
    tripStream = currentDocumentTrip?.snapshots().asyncMap((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        currentTrip = Trip.fromMap(data);
        status = currentTrip?.status ?? 'unknown';
        notifyListeners();
      }
      return snapshot;
    });
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

  Future<void> deleteTrip() async {
    if (currentDocumentTrip != null) {
      await currentDocumentTrip!.delete();
      cancelStream();
    }
  }

  void cancelStream() {
    tripStream = null;
    currentDocumentTrip = null;
    driverWithProposalList = [];
    status = 'not_created';
    notifyListeners();
  }

  void clear() {
    from = '';
    dest = const LatLng(0, 0);
    points = [];
    currentLocation = null;
    lastDest = null;
    toController.clear();
    priceController.clear();
    cancelStream();
  }
}
