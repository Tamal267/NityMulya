class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? shopName;
  final String? phone;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.shopName,
    this.phone,
    this.isVerified = false,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Customer',
      shopName: map['shopName'],
      phone: map['phone'],
      isVerified: map['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'shopName': shopName,
      'phone': phone,
      'isVerified': isVerified,
    };
  }

  bool get isCustomer => role == 'Customer';
  bool get isShopOwner => role == 'Shop Owner';
  bool get isWholesaler => role == 'Wholesaler';
}
