import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:free_map/free_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  // Trip management properties
  Stream<DocumentSnapshot>? _tripStream;
  DocumentReference? _currentTrip;
  String? _currentTripId;
  
  // Driver management
  List<Driver> _drivers = [];
  List<Driver> get drivers => _drivers;
  
  // Trip content properties
  final TextEditingController toController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String _from = '';
  LatLng _dest = const LatLng(0, 0);
  String _price = '';
  List<LatLng> _points = [];
  LatLng? currentLocation;
  LatLng? lastDest;
  String _status = 'not_created';

  // Getters
  bool get isLoading => _isLoading;
  Stream<DocumentSnapshot>? get tripStream => _tripStream;
  String get from => _from;
  LatLng get dest => _dest;
  String get price => _price;
  List<LatLng> get points => _points;
  String get status => _status;
  String? get currentTripId => _currentTripId;

  // Initialize trip stream
  void _initializeTripStream() {
    _tripStream = _currentTrip?.snapshots().asyncMap((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _status = data['status'] ?? 'unknown';
        _price = data['price']?.toString() ?? '';
        
        // Update drivers list
        // final driverEmails = Map<String, String>.from(data['drivers'] ?? {});
        // await updateDrivers(driverEmails);
        
        notifyListeners();
      }
      return snapshot;
    });
  }
  void reconnectTripStream() {
  
    _tripStream = _currentTrip!.snapshots();
    // notifyListeners();
  
}

  // Fetch and update drivers details
  Future<void> updateDrivers(Map<String, Map<String, String>> driverEmailsWithPrices) async {
  final List<Driver> updatedDrivers = [];

  for (final entry in driverEmailsWithPrices.entries) {
    var email = entry.key;
    final priceMap = entry.value;

    try {
      email = email.replaceAll('_', '.');
      debugPrint('🔍 Fetching driver with email: $email');
      final result = await _firestore
          .collection('drivers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final driverData = result.docs.first.data();
        
        // You can either extend the Driver model to include proposedPrice
        final driver = Driver.fromMap(driverData, email).copyWith(
          proposedPrice: priceMap['proposedPrice'],
          proposedPriceStatus: priceMap['proposedPriceStatus'],
          passengerProposedPrice: priceMap['passengerProposedPrice'],
        );

        debugPrint('✅ Driver found: ${driver.name} with rank: ${driver.rating}');
        updatedDrivers.add(driver);
      } else {
        debugPrint('❌ No driver found with email: $email');
      }
    } catch (e) {
      debugPrint('🔥 Error fetching driver $email: $e');
    }
  }

  _drivers = updatedDrivers;
  notifyListeners(); // Trigger UI update
}




  // Trip creation and management
  Future<void> createNewTrip() async {
    _isLoading = true;
    notifyListeners();
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
        'drivers': {},
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      _currentTripId = _currentTrip?.id;
      _initializeTripStream();
      notifyListeners();
    } catch (e) {
      notifyListeners();
      debugPrint("Error creating trip: $e");
      rethrow;
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSelectedDriver(String driverEmail) async {
  if (_currentTrip == null) return;
  
  await _currentTrip!.update({
    'selectedDriver': driverEmail,
    'status': 'accepted',
    // 'updatedAt': FieldValue.serverTimestamp(),
  });
}



Future<void> changePassengerProposalPrice(String email, String newPrice) async {
  try {
    email = email.replaceAll('.', '_'); // Replace '.' with '_' in email
    await _currentTrip!.update({
      FieldPath.fromString('drivers.$email.passengerProposedPrice'): newPrice,
      FieldPath.fromString('drivers.$email.proposedPriceStatus'): 'pending',
    });
  } catch (e) {
    debugPrint('Error updating price: $e');
  }
}




Future<void> updateUserPrice(String newPrice) async {
    if (_currentTrip == null) return;
    
    await _currentTrip!.update({
      'price': newPrice,
    });
  }

  Future<void> updateTripStatus(String newStatus) async {
    if (_currentTrip == null) return;
    
    await _currentTrip!.update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

    Future<void> deleteTrip() async {
    if (_currentTrip != null) {
      await _currentTrip!.delete();
      cancelStream();
    }
  }

  // Get current status from snapshot
  String getCurrentStatus(DocumentSnapshot? snapshot) {
    if (snapshot == null || !snapshot.exists) return 'not_created';
    return (snapshot.data() as Map<String, dynamic>)['status'] ?? 'unknown';
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

  // Clean up
  void cancelStream() {
    _tripStream = null;
    _currentTrip = null;
    _currentTripId = null;
    _drivers = [];
    _price = '';
    _status = 'not_created';
    notifyListeners();
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
    cancelStream();
  }
}