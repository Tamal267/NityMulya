import 'package:latlong2/latlong.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime? lastUpdated;
  final String type; // 'permanent', 'current', 'delivery'

  UserLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.lastUpdated,
    this.type = 'current',
  });

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      latitude: double.tryParse(map['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(map['longitude'].toString()) ?? 0.0,
      address: map['address'],
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'].toString())
          : null,
      type: map['type'] ?? 'current',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'last_updated': lastUpdated?.toIso8601String(),
      'type': type,
    };
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  // Calculate distance to another location in kilometers
  double distanceTo(UserLocation other) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, toLatLng(), other.toLatLng());
  }

  UserLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    DateTime? lastUpdated,
    String? type,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      type: type ?? this.type,
    );
  }
}

class Customer {
  final String id;
  final String fullName;
  final String email;
  final String contact;
  final UserLocation? permanentLocation; // Set during signup
  final UserLocation? currentLocation; // Updated when placing orders
  final String? profileImage;
  final bool isVerified;
  final DateTime? createdAt;

  Customer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.contact,
    this.permanentLocation,
    this.currentLocation,
    this.profileImage,
    this.isVerified = false,
    this.createdAt,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      contact: map['contact'] ?? map['phone'] ?? '',
      permanentLocation: map['latitude'] != null && map['longitude'] != null
          ? UserLocation(
              latitude: double.tryParse(map['latitude'].toString()) ?? 0.0,
              longitude: double.tryParse(map['longitude'].toString()) ?? 0.0,
              address: map['address'],
              type: 'permanent',
            )
          : null,
      currentLocation:
          map['current_latitude'] != null && map['current_longitude'] != null
              ? UserLocation(
                  latitude: double.tryParse(map['current_latitude'].toString()) ?? 0.0,
                  longitude: double.tryParse(map['current_longitude'].toString()) ?? 0.0,
                  address: map['current_address'],
                  type: 'current',
                )
              : null,
      profileImage: map['profile_image'],
      isVerified: map['is_verified'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'contact': contact,
      'latitude': permanentLocation?.latitude,
      'longitude': permanentLocation?.longitude,
      'address': permanentLocation?.address,
      'current_latitude': currentLocation?.latitude,
      'current_longitude': currentLocation?.longitude,
      'current_address': currentLocation?.address,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? fullName,
    String? email,
    String? contact,
    UserLocation? permanentLocation,
    UserLocation? currentLocation,
    String? profileImage,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      permanentLocation: permanentLocation ?? this.permanentLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get the location to use for orders (current if available, otherwise permanent)
  UserLocation? get orderLocation => currentLocation ?? permanentLocation;
}

class ShopOwner {
  final String id;
  final String fullName;
  final String email;
  final String contact;
  final UserLocation location; // Fixed location set during signup
  final String shopName;
  final String? shopDescription;
  final String? profileImage;
  final bool isVerified;
  final DateTime? createdAt;

  ShopOwner({
    required this.id,
    required this.fullName,
    required this.email,
    required this.contact,
    required this.location,
    required this.shopName,
    this.shopDescription,
    this.profileImage,
    this.isVerified = false,
    this.createdAt,
  });

  factory ShopOwner.fromMap(Map<String, dynamic> map) {
    return ShopOwner(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      contact: map['contact'] ?? map['phone'] ?? '',
      location: UserLocation(
        latitude: double.tryParse(map['latitude'].toString()) ?? 0.0,
        longitude: double.tryParse(map['longitude'].toString()) ?? 0.0,
        address: map['address'],
        type: 'permanent',
      ),
      shopName: map['shop_name'] ?? map['shopName'] ?? '',
      shopDescription: map['shop_description'],
      profileImage: map['profile_image'],
      isVerified: map['is_verified'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'contact': contact,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': location.address,
      'shop_name': shopName,
      'shop_description': shopDescription,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Wholesaler {
  final String id;
  final String fullName;
  final String email;
  final String contact;
  final UserLocation location; // Fixed location set during signup
  final String companyName;
  final String? companyDescription;
  final String? profileImage;
  final bool isVerified;
  final DateTime? createdAt;

  Wholesaler({
    required this.id,
    required this.fullName,
    required this.email,
    required this.contact,
    required this.location,
    required this.companyName,
    this.companyDescription,
    this.profileImage,
    this.isVerified = false,
    this.createdAt,
  });

  factory Wholesaler.fromMap(Map<String, dynamic> map) {
    return Wholesaler(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      contact: map['contact'] ?? map['phone'] ?? '',
      location: UserLocation(
        latitude: double.tryParse(map['latitude'].toString()) ?? 0.0,
        longitude: double.tryParse(map['longitude'].toString()) ?? 0.0,
        address: map['address'],
        type: 'permanent',
      ),
      companyName: map['company_name'] ?? map['companyName'] ?? '',
      companyDescription: map['company_description'],
      profileImage: map['profile_image'],
      isVerified: map['is_verified'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'contact': contact,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': location.address,
      'company_name': companyName,
      'company_description': companyDescription,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
