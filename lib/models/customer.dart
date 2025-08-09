class Customer {
  final int? id;
  final String fullName;
  final String email;
  final String contact;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? profileImageUrl;

  Customer({
    this.id,
    required this.fullName,
    required this.email,
    required this.contact,
    this.address,
    this.latitude,
    this.longitude,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.dateOfBirth,
    this.gender,
    this.profileImageUrl,
  });

  // Factory constructor to create Customer from JSON (API response)
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      gender: json['gender'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  // Convert Customer to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      'email': email,
      'contact': contact,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_verified': isVerified,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T')[0], // Date only
      'gender': gender,
      'profile_image_url': profileImageUrl,
    };
  }

  // For registration/signup - only the required fields
  Map<String, dynamic> toRegistrationJson(String password) {
    return {
      'full_name': fullName,
      'email': email,
      'contact': contact,
      'password': password,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Create a copy with modified fields
  Customer copyWith({
    int? id,
    String? fullName,
    String? email,
    String? contact,
    String? address,
    double? latitude,
    double? longitude,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImageUrl,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, fullName: $fullName, email: $email, contact: $contact, address: $address, lat: $latitude, lng: $longitude)';
  }
}

// Location utility class
class CustomerLocation {
  final double latitude;
  final double longitude;
  final String? address;

  CustomerLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory CustomerLocation.fromJson(Map<String, dynamic> json) {
    return CustomerLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'Location(lat: $latitude, lng: $longitude, address: $address)';
  }
}
