class Shop {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String category;
  final double rating;
  final String image;
  final List<String> availableProducts;
  final bool isVerified;
  final String openingHours;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.category,
    required this.rating,
    required this.image,
    required this.availableProducts,
    this.isVerified = false,
    required this.openingHours,
  });

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      image: map['image'] ?? '',
      availableProducts: List<String>.from(map['availableProducts'] ?? []),
      isVerified: map['isVerified'] ?? false,
      openingHours: map['openingHours'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'category': category,
      'rating': rating,
      'image': image,
      'availableProducts': availableProducts,
      'isVerified': isVerified,
      'openingHours': openingHours,
    };
  }
}
