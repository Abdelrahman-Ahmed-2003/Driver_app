import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:free_map/free_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripProvider with ChangeNotifier {
  // Firestore and Auth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Trip management properties
  Stream<DocumentSnapshot>? _tripStream;
  DocumentReference? _currentTrip;
  
  // Trip content properties
  final TextEditingController toController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String _from = '';
  LatLng _dest = const LatLng(0, 0);
  String _price = '';
  List<LatLng> _points = [];
  LatLng? currentLocation;
  LatLng? lastDest;

  // Getters
  Stream<DocumentSnapshot>? get tripStream => _tripStream;
  String get from => _from;
  LatLng get dest => _dest;
  String get price => _price;
  List<LatLng> get points => _points;

  // Trip status methods
  String getCurrentStatus(DocumentSnapshot? snapshot) {
    if (snapshot == null || !snapshot.exists) return 'not_created';
    return (snapshot.data() as Map<String, dynamic>)['status'] ?? 'unknown';
  }

  // Trip creation and management
  Future<void> createNewTrip() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      _currentTrip = await _firestore.collection('trips').add({
        'passengerEmail': user?.email,
        'passengerName': user?.displayName,
        'destination': toController.text,
        'userLocation': {
          'lat': currentLocation?.latitude,
          'long': currentLocation?.longitude,
        },
        'destinationCoords': {
          'lat': _dest.latitude,
          'long': _dest.longitude,
        },
        'price': priceController.text,
        'status': 'waiting',
        'driversMails': [],
      });

      _tripStream = _currentTrip?.snapshots();
      notifyListeners();
    } catch (e) {
      debugPrint("Error creating trip: $e");
      rethrow;
    }
  }

  Future<void> deleteTrip() async {
    if (_currentTrip != null) {
      await _currentTrip!.delete();
      cancelStream();
    }
  }

  void cancelStream() {
    _tripStream = null;
    _currentTrip = null;
    notifyListeners();
  }

  // Trip content methods
  void setFrom(String value) {
    _from = value;
    notifyListeners();
  }

  void setDest(LatLng value) {
    _dest = value;
    notifyListeners();
  }

  void setPrice(String value) {
    _price = value;
  }

  void setCurrentPoints(LatLng newPoints) async {
    if (_points.isEmpty) {
      _points.add(newPoints);
    } else {
      _points[0] = newPoints;
    }
    await updatePoints();
    notifyListeners();
  }

  void setDestinations(List<LatLng> newPoints) {
    if (currentLocation != null) {
      _points = [currentLocation!, ...newPoints];
    } else {
      _points = [...newPoints];
    }
    notifyListeners();
  }

  Future<void> setCoordinatesPoint(LatLng location) async {
    if (lastDest != location) {
      lastDest = location;
      setDest(location);
      await fetchRoute();
    }
  }

  Future<void> updatePoints() async {
    if (_dest != const LatLng(0, 0)) {
      await fetchRoute();
    }
  }

  Future<void> fetchRoute() async {
    if (currentLocation == null || _dest == const LatLng(0, 0)) return;

    _points.clear();

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${currentLocation!.longitude},${currentLocation!.latitude};'
      '${_dest.longitude},${_dest.latitude}?overview=full&geometries=polyline&steps=true'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    } else {
      debugPrint('Error in fetch route');
    }
  }

  void _decodePolyline(String geometry) {
    final polylinePoints = PolylinePoints();
    final result = polylinePoints.decodePolyline(geometry);
    setDestinations(result.map((e) => LatLng(e.latitude, e.longitude)).toList());
  }

  void clear() {
    _from = '';
    _dest = const LatLng(0, 0);
    _price = '';
    _points = [];
    currentLocation = null;
    lastDest = null;
    toController.clear();
    priceController.clear();
    notifyListeners();
  }
}