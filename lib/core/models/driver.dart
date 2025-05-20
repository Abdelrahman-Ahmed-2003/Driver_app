// driver_model.dart
class Driver {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? imageUrl;
  final bool isAvailable;
  final String rating;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.imageUrl,
    required this.isAvailable,
    required this.rating,
  });

  factory Driver.fromFirestore(String id, Map<String, dynamic> data) {
    return Driver(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'] ?? true,
      rating: data['rate'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'rate': rating,
    };
  }
}
