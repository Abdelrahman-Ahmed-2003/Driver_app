// trip_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Trip {
  final String id;
  final String passengerId;
  final String driverId;
  final String destination;
  final LatLng userLocation;
  final LatLng destinationCoords;
  final String price;
  final String status;
  Map<String, DriverProposal> drivers;
  final Timestamp? createdAt;

  Trip({
    required this.id,
    required this.passengerId,
    required this.driverId,
    required this.destination,
    required this.userLocation,
    required this.destinationCoords,
    required this.price,
    required this.status,
    required this.drivers,
    required this.createdAt,
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
      createdAt: data['createdAt'],
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
      createdAt: data['createdAt'],
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