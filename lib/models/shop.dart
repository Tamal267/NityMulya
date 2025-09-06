class Shop {
  final String id;
  final String name;
  final String address;
  final String location; // Added location field for area/city (optional)
  final String phone;
  final String category;
  final double rating;
  final String image;
  final List<String> availableProducts;
  final bool isVerified;
  final String openingHours;
  final double? latitude;
  final double? longitude;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    this.location = '',
    required this.phone,
    required this.category,
    required this.rating,
    required this.image,
    required this.availableProducts,
    this.isVerified = false,
    required this.openingHours,
    this.latitude,
    this.longitude,
  });

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      image: map['image'] ?? '',
      availableProducts: List<String>.from(map['availableProducts'] ?? []),
      isVerified: map['isVerified'] ?? false,
      openingHours: map['openingHours'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': location,
      'phone': phone,
      'category': category,
      'rating': rating,
      'image': image,
      'availableProducts': availableProducts,
      'isVerified': isVerified,
      'openingHours': openingHours,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
