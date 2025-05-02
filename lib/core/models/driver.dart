import 'package:flutter/material.dart';

class Driver {
  final String email;
  final String? name;
  final String? phone;
  final String? vehicleType;
  final String? rating;
  final String? imageUrl;

  Driver({
    required this.email,
    this.name,
    this.phone,
    this.vehicleType,
    this.rating,
    this.imageUrl,
  });

  factory Driver.fromMap(Map<String, dynamic>? data, String email) {
    debugPrint('Driver data: $data');
    return Driver(
      email: email,
      name: data?['name'],
      phone: data?['phone'],
      vehicleType: data?['vehicle'],
      rating: data?['rate'],
      imageUrl: data?['imageUrl'],
    );
  }
}