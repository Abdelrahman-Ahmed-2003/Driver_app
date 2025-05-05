class Driver {
  final String email;
  final String? name;
  final String? imageUrl;
  final String? vehicleType;
  final String? rating; // ✅ Now it's a String
  final String? proposedPrice;
  final String? proposedPriceStatus;
  final String?passengerProposedPrice;

  Driver({
    required this.email,
    this.name,
    this.imageUrl,
    this.vehicleType,
    this.rating,
    this.proposedPrice,
    this.proposedPriceStatus,
    this.passengerProposedPrice,
  });

  Driver copyWith({
    String? email,
    String? name,
    String? imageUrl,
    String? vehicleType,
    String? rating,
    String? proposedPrice,
    String? proposedPriceStatus,
    String? passengerProposedPrice,
  }) {
    return Driver(
      email: email ?? this.email,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      rating: rating ?? this.rating,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      proposedPriceStatus: proposedPriceStatus ?? this.proposedPriceStatus,
      passengerProposedPrice: passengerProposedPrice ?? this.passengerProposedPrice,
    );
  }

  factory Driver.fromMap(Map<String, dynamic>? data, String email) {
    
    return Driver(
      email: email,
      name: data?['name'],
      imageUrl: data?['imageUrl'],
      vehicleType: data?['vehicle'],
      rating: data?['rate']?.toString(), // ✅ Converts number to string
    );
  }
}
