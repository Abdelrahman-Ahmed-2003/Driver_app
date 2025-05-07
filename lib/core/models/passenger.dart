// passenger_model.dart
class Passenger {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? tripId;

  Passenger({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.tripId,
  });

  factory Passenger.fromFirestore(String id, Map<String, dynamic> data) {
    return Passenger(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      tripId: data['tripId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'tripId': tripId,
    };
  }
}
