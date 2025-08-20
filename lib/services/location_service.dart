import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/location_models.dart';
import '../network/network_helper.dart';

class LocationService {
  static const String _geoapifyApiKey = 'a2621109b87d48c0a55f0c71dce604d8';
  static const String _baseUrl = 'https://api.geoapify.com/v1';
  static final NetworkHelper _apiClient = NetworkHelper();

  // Get current location with permission handling
  static Future<UserLocation?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
            'Location services are disabled. Please enable location services.');
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
              'Location permissions are denied. Please grant location permission.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied. Please enable location permission in settings.');
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Get address for the location
      String? address =
          await reverseGeocode(position.latitude, position.longitude);

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        lastUpdated: DateTime.now(),
        type: 'current',
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Convert address to coordinates using Geoapify
  static Future<UserLocation?> geocodeAddress(String address) async {
    try {
      final url =
          '$_baseUrl/geocode/search?text=${Uri.encodeComponent(address)}&apiKey=$_geoapifyApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['geometry']['coordinates'];
          final properties = data['features'][0]['properties'];

          return UserLocation(
            latitude: coordinates[1].toDouble(),
            longitude: coordinates[0].toDouble(),
            address: properties['formatted'] ?? properties['name'] ?? address,
            lastUpdated: DateTime.now(),
            type: 'geocoded',
          );
        }
      }
      return null;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }

  // Convert coordinates to address using Geoapify
  static Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final url =
          '$_baseUrl/geocode/reverse?lat=$lat&lon=$lng&apiKey=$_geoapifyApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final properties = data['features'][0]['properties'];
          return properties['formatted'] ?? properties['name'];
        }
      }
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  // Get route between two locations using Geoapify
  static Future<Map<String, dynamic>?> getRoute(
    UserLocation from,
    UserLocation to, {
    String mode = 'drive', // drive, walk, bike
  }) async {
    try {
      final url =
          '$_baseUrl/routing?waypoints=${from.latitude},${from.longitude}|${to.latitude},${to.longitude}&mode=$mode&apiKey=$_geoapifyApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final route = data['features'][0];
          final geometry = route['geometry'];
          final properties = route['properties'];

          return {
            'coordinates': geometry['coordinates'],
            'distance': properties['distance'] / 1000, // Convert to km
            'duration': properties['time'] / 60, // Convert to minutes
            'instructions': properties['legs']?[0]?['steps'] ?? [],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }

  // Update customer location
  static Future<bool> updateCustomerLocation(
      String customerId, UserLocation location, String locationType) async {
    try {
      final data = {
        'customer_id': customerId,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': location.address,
        'location_type': locationType, // 'permanent' or 'current'
      };

      final response = await _apiClient.post('/customer/update-location', data);
      return response['success'] == true;
    } catch (e) {
      print('Error updating customer location: $e');
      return false;
    }
  }

  // Get nearby shops for customer
  static Future<List<Map<String, dynamic>>> getNearbyShops(
      UserLocation customerLocation,
      {double radiusKm = 10.0}) async {
    try {
      final data = {
        'latitude': customerLocation.latitude,
        'longitude': customerLocation.longitude,
        'radius': radiusKm,
      };

      final response = await _apiClient.post('/shops/nearby', data);
      if (response['success'] == true && response['shops'] != null) {
        List<Map<String, dynamic>> shops =
            List<Map<String, dynamic>>.from(response['shops']);

        // Calculate distances and sort by distance
        for (var shop in shops) {
          if (shop['latitude'] != null && shop['longitude'] != null) {
            final shopLocation = UserLocation(
              latitude: shop['latitude'].toDouble(),
              longitude: shop['longitude'].toDouble(),
            );
            shop['distance'] = customerLocation.distanceTo(shopLocation);
          }
        }

        shops.sort((a, b) => (a['distance'] ?? double.infinity)
            .compareTo(b['distance'] ?? double.infinity));
        return shops;
      }
      return [];
    } catch (e) {
      print('Error getting nearby shops: $e');
      return [];
    }
  }

  // Get customer orders with delivery locations
  static Future<List<Map<String, dynamic>>> getShopOwnerOrders(
      String shopOwnerId) async {
    try {
      final response = await _apiClient.get('/shop-owner/orders/$shopOwnerId');
      if (response['success'] == true && response['orders'] != null) {
        return List<Map<String, dynamic>>.from(response['orders']);
      }
      return [];
    } catch (e) {
      print('Error getting shop owner orders: $e');
      return [];
    }
  }

  // Get wholesaler deliveries to shops
  static Future<List<Map<String, dynamic>>> getWholesalerDeliveries(
      String wholesalerId) async {
    try {
      final response =
          await _apiClient.get('/wholesaler/deliveries/$wholesalerId');
      if (response['success'] == true && response['deliveries'] != null) {
        return List<Map<String, dynamic>>.from(response['deliveries']);
      }
      return [];
    } catch (e) {
      print('Error getting wholesaler deliveries: $e');
      return [];
    }
  }

  // Calculate delivery route and time
  static Future<Map<String, dynamic>?> calculateDeliveryRoute({
    required UserLocation from,
    required UserLocation to,
    String vehicleType = 'drive',
  }) async {
    final route = await getRoute(from, to, mode: vehicleType);
    if (route != null) {
      return {
        'distance_km': route['distance'],
        'duration_minutes': route['duration'],
        'estimated_cost': _calculateDeliveryCost(route['distance']),
        'route_coordinates': route['coordinates'],
        'instructions': route['instructions'],
      };
    }
    return null;
  }

  // Calculate delivery cost based on distance
  static double _calculateDeliveryCost(double distanceKm) {
    // Base cost + per km cost
    const double baseCost = 20.0; // BDT
    const double perKmCost = 5.0; // BDT per km
    return baseCost + (distanceKm * perKmCost);
  }

  // Save order with delivery location
  static Future<bool> createOrderWithLocation({
    required String customerId,
    required String shopOwnerId,
    required UserLocation deliveryLocation,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
  }) async {
    try {
      final data = {
        'customer_id': customerId,
        'shop_owner_id': shopOwnerId,
        'delivery_latitude': deliveryLocation.latitude,
        'delivery_longitude': deliveryLocation.longitude,
        'delivery_address': deliveryLocation.address,
        'items': items,
        'special_instructions': specialInstructions,
        'order_type': 'delivery',
      };

      final response = await _apiClient.post('/orders/create', data);
      return response['success'] == true;
    } catch (e) {
      print('Error creating order with location: $e');
      return false;
    }
  }

  // Track delivery status
  static Future<Map<String, dynamic>?> trackDelivery(String orderId) async {
    try {
      final response = await _apiClient.get('/orders/track/$orderId');
      if (response['success'] == true) {
        return response['tracking_info'];
      }
      return null;
    } catch (e) {
      print('Error tracking delivery: $e');
      return null;
    }
  }

  // Update delivery status (for shop owners)
  static Future<bool> updateDeliveryStatus({
    required String orderId,
    required String status, // 'preparing', 'on_the_way', 'delivered'
    UserLocation? currentLocation,
  }) async {
    try {
      final data = {
        'order_id': orderId,
        'status': status,
        'delivery_latitude': currentLocation?.latitude,
        'delivery_longitude': currentLocation?.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response =
          await _apiClient.post('/orders/update-delivery-status', data);
      return response['success'] == true;
    } catch (e) {
      print('Error updating delivery status: $e');
      return false;
    }
  }

  // Search shops by product and location
  static Future<List<Map<String, dynamic>>> searchShopsByProduct({
    required String productName,
    required UserLocation customerLocation,
    double radiusKm = 20.0,
  }) async {
    try {
      final data = {
        'product_name': productName,
        'latitude': customerLocation.latitude,
        'longitude': customerLocation.longitude,
        'radius': radiusKm,
      };

      final response = await _apiClient.post('/shops/search-by-product', data);
      if (response['success'] == true && response['shops'] != null) {
        List<Map<String, dynamic>> shops =
            List<Map<String, dynamic>>.from(response['shops']);

        // Add distance calculation
        for (var shop in shops) {
          if (shop['latitude'] != null && shop['longitude'] != null) {
            final shopLocation = UserLocation(
              latitude: shop['latitude'].toDouble(),
              longitude: shop['longitude'].toDouble(),
            );
            shop['distance'] = customerLocation.distanceTo(shopLocation);
          }
        }

        shops.sort((a, b) => (a['distance'] ?? double.infinity)
            .compareTo(b['distance'] ?? double.infinity));
        return shops;
      }
      return [];
    } catch (e) {
      print('Error searching shops by product: $e');
      return [];
    }
  }

  // Get user profile with location
  static Future<Map<String, dynamic>?> getUserProfile(
      String userId, String userType) async {
    try {
      final response = await _apiClient.get('/$userType/profile/$userId');
      if (response['success'] == true) {
        return response['profile'];
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile location
  static Future<bool> updateUserProfileLocation({
    required String userId,
    required String userType,
    required UserLocation location,
  }) async {
    try {
      final data = {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': location.address,
      };

      final response =
          await _apiClient.put('/$userType/profile/$userId/location', data);
      return response['success'] == true;
    } catch (e) {
      print('Error updating user profile location: $e');
      return false;
    }
  }

  // Check if location is within delivery area
  static bool isWithinDeliveryArea(UserLocation shopLocation,
      UserLocation customerLocation, double maxDeliveryRadius) {
    final distance = shopLocation.distanceTo(customerLocation);
    return distance <= maxDeliveryRadius;
  }

  // Get estimated delivery time
  static String getEstimatedDeliveryTime(double distanceKm) {
    // Base time + time per km
    const int baseTimeMinutes = 30;
    const int timePerKmMinutes = 3;

    final totalMinutes =
        baseTimeMinutes + (distanceKm * timePerKmMinutes).round();

    if (totalMinutes < 60) {
      return '$totalMinutes minutes';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }
}
