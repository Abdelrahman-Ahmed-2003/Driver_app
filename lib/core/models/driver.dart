class Driver {
  final String email;
  final String? name;
  final String? phone;
  final String? vehicleType;
  final double? rating;
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
    return Driver(
      email: email,
      name: data?['name'],
      phone: data?['phone'],
      vehicleType: data?['vehicleType'],
      rating: data?['rating']?.toDouble(),
      imageUrl: data?['imageUrl'],
    );
  }
}