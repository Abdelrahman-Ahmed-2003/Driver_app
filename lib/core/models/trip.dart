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
      id: data['tripId'] ?? '',
      passengerId: data['passengerdocId'] ?? '',
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

  Trip copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    String? destination,
    LatLng? userLocation,
    LatLng? destinationCoords,
    String? price,
    String? status,
    Map<String, DriverProposal>? drivers,
  }) {
    return Trip(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      destination: destination ?? this.destination,
      userLocation: userLocation ?? this.userLocation,
      destinationCoords: destinationCoords ?? this.destinationCoords,
      price: price ?? this.price,
      status: status ?? this.status,
      drivers: drivers ?? Map.from(this.drivers),
    );
  }
   @override
  String toString() {
    return 'Trip(id: $id, passengerId: $passengerId, driverId: $driverId, destination: $destination, price: $price)';
  }
}

class DriverProposal {
  final String proposedPrice;

  DriverProposal({
    required this.proposedPrice,
  });

  factory DriverProposal.fromMap(Map<String, dynamic> data) {
    return DriverProposal(
      proposedPrice: data['proposedPrice'] ?? '',
    );
  }

  DriverProposal copyWith({
    String? proposedPrice,
  }) {
    return DriverProposal(
      proposedPrice: proposedPrice ?? this.proposedPrice,
    );
  }
}