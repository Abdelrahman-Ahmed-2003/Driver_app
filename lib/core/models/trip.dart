// trip_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Trip {
   String id;
   String passengerId;
   String driverId;
   String destination;
   String driverDistination = 'toUser';
   LatLng? userLocation;
   LatLng? driverLocation;
   LatLng destinationCoords = LatLng(0, 0);
   String price;
   String status;
   String? driverProposalPrice;
   

  Trip({
    this.id = '',
    this.passengerId = '',
    this.driverDistination = 'toUser',
    this.driverId = '',
    this.destination = '',
    this.userLocation = const LatLng(0, 0),
    this.driverLocation = const LatLng(0, 0),
    this.destinationCoords = const LatLng(0, 0),
    this.price = '',
    this.status = 'wating',
    this.driverProposalPrice,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trip &&
        other.id == id &&
        other.status == status &&
        other.price == price;
  }

  @override
  int get hashCode => Object.hash(id, status, price);

  factory Trip.fromFirestore(DocumentSnapshot doc, String driverId) {
  final data = doc.data() as Map<String, dynamic>;

  final allProposals = data['driverProposals'] as Map<String, dynamic>? ?? {};

  // ✅ Only get your driver's proposal
  String? myProposal = allProposals.containsKey(driverId)
      ? allProposals[driverId]['proposedPrice']
      : null;
    debugPrint('myProposal: $myProposal');

  return Trip(
    id: doc.id,
    passengerId: data['passengerdocId'] ?? '',
    driverId: data['driverDocId'] ?? '',
    destination: data['destination'] ?? '',
    driverDistination: data['driverDistination'] ?? 'toUser',
    userLocation: LatLng(
      data['userLocation']?['lat'] ?? 0.0,
      data['userLocation']?['long'] ?? 0.0,
    ),
    driverLocation: LatLng(
      data['driverLocation']?['lat'] ?? 0.0,
      data['driverLocation']?['long'] ?? 0.0,
    ),
    destinationCoords: LatLng(
      data['destinationCoords']?['lat'] ?? 0.0,
      data['destinationCoords']?['long'] ?? 0.0,
    ),
    price: data['price'] ?? '',
    status: data['status'] ?? '',
    driverProposalPrice: myProposal
  );
}


  factory Trip.fromMap(Map<String, dynamic> data, String driverId) {
    final allProposals = data['driverProposals'] as Map<String, dynamic>? ?? {};

  // ✅ Only get your driver's proposal
  String? myProposal = allProposals.containsKey(driverId)
      ? allProposals[driverId]['proposedPrice']
      : null;
    return Trip(
      id: data['tripId'] ?? '',
      passengerId: data['passengerdocId'] ?? '',
      driverId: data['driverId'] ?? '',
      destination: data['destination'] ?? '',
      driverDistination: data['driverDistination'] ?? 'toUser',
      userLocation: LatLng(
        data['userLocation']?['lat'] ?? 0.0,
        data['userLocation']?['long'] ?? 0.0,
      ),
      driverLocation: LatLng(
        data['driverLocation']?['lat'] ?? 0.0,
        data['driverLocation']?['long'] ?? 0.0,
      ),
      destinationCoords: LatLng(
        data['destinationCoords']?['lat'] ?? 0.0,
        data['destinationCoords']?['long'] ?? 0.0,
      ),
      price: data['price'] ?? '',
      status: data['status'] ?? '',
      driverProposalPrice: myProposal,
      
    );
  }

  Trip copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    String? destination,
    String? driverDistination,
    LatLng? userLocation,
    LatLng? driverLocation,
    LatLng? destinationCoords,
    String? price,

    String? status,
    String? driverProposalPrice,
  }) {
    return Trip(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      destination: destination ?? this.destination,
      driverDistination: driverDistination ?? this.driverDistination,
      userLocation: userLocation ?? this.userLocation,
      driverLocation: userLocation ?? this.driverLocation,
      destinationCoords: destinationCoords ?? this.destinationCoords,
      price: price ?? this.price,
      status: status ?? this.status,
      driverProposalPrice: driverProposalPrice ?? this.driverProposalPrice,
    );
  }
   @override
  String toString() {
    return 'Trip(id: $id, passengerId: $passengerId, driverId: $driverId, destination: $destination, price: $price , driverProposalPrice: $driverProposalPrice)';
  }
}

class DriverProposal {
  String proposedPrice;

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