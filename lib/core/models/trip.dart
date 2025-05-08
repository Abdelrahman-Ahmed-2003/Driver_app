// trip_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Trip {
   String id;
   String passengerId;
   String driverId;
   String destination;
   LatLng? userLocation;
   LatLng destinationCoords = LatLng(0, 0);
   String price;
   String status;
  Map<String, DriverProposal> drivers;
   

  Trip({
    this.id = '',
    this.passengerId = '',
    this.driverId = '',
    this.destination = '',
    this.userLocation = const LatLng(0, 0),
    this.destinationCoords = const LatLng(0, 0),
    this.price = '',
    this.status = 'wating',
    this.drivers = const {},
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Trip(
      id: doc.id,
      passengerId: data['passengerId'] ?? '',
      driverId: data['driverId'] ?? '',
      destination: data['destination'] ?? '',
      userLocation: LatLng(
        data['userLocation']?['lat'] ?? 0.0,
        data['userLocation']?['long'] ?? 0.0,
      ),
      destinationCoords: LatLng(
        data['destinationCoords']?['lat'] ?? 0.0,
        data['destinationCoords']?['long'] ?? 0.0,
      ),
      price: data['price'] ?? '',
      status: data['status'] ?? '',
      drivers: (data['driverproposals'] as Map<String, dynamic>? ?? {}).map(
        (email, value) => MapEntry(email, DriverProposal.fromMap(value)),
      ),
    );
  }

  factory Trip.fromMap(Map<String, dynamic> data) {
    return Trip(
      id: data['id'] ?? '',
      passengerId: data['passengerId'] ?? '',
      driverId: data['driverId'] ?? '',
      destination: data['destination'] ?? '',
      userLocation: LatLng(
        data['userLocation']?['lat'] ?? 0.0,
        data['userLocation']?['long'] ?? 0.0,
      ),
      destinationCoords: LatLng(
        data['destinationCoords']?['lat'] ?? 0.0,
        data['destinationCoords']?['long'] ?? 0.0,
      ),
      price: data['price'] ?? '',
      status: data['status'] ?? '',
      drivers: (data['driverProposals'] as Map<String, dynamic>? ?? {}).map(
        (email, value) => MapEntry(email, DriverProposal.fromMap(value)),
      ),
    );
  }
}

class DriverProposal {
  final String passengerProposedPrice;
  final String proposedPrice;
  final String proposedPriceStatus;

  DriverProposal({
    required this.passengerProposedPrice,
    required this.proposedPrice,
    required this.proposedPriceStatus,
  });

  factory DriverProposal.fromMap(Map<String, dynamic> data) {
    return DriverProposal(
      passengerProposedPrice: data['passengerProposedPrice'] ?? '',
      proposedPrice: data['proposedPrice'] ?? '',
      proposedPriceStatus: data['proposedPriceStatus'] ?? '',
    );
  }
}