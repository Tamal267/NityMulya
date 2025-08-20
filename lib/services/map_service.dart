import 'dart:convert';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapService {
  static const String _geoapifyApiKey = 'a2621109b87d48c0a55f0c71dce604d8';
  static const String _baseUrl = 'https://api.geoapify.com/v1';

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Convert address to coordinates using Geoapify
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final url =
          '$_baseUrl/geocode/search?text=${Uri.encodeComponent(address)}&apiKey=$_geoapifyApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['geometry']['coordinates'];
          return LatLng(coordinates[1], coordinates[0]); // lat, lng
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

  // Calculate distance between two points in kilometers
  static double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  // Find nearby shops within radius (km)
  static List<Map<String, dynamic>> findNearbyShops(
    LatLng userLocation,
    List<Map<String, dynamic>> shops,
    double radiusKm,
  ) {
    List<Map<String, dynamic>> nearbyShops = [];

    for (var shop in shops) {
      if (shop['latitude'] != null && shop['longitude'] != null) {
        LatLng shopLocation = LatLng(shop['latitude'], shop['longitude']);
        double distance = calculateDistance(userLocation, shopLocation);

        if (distance <= radiusKm) {
          shop['distance'] = distance;
          nearbyShops.add(shop);
        }
      }
    }

    // Sort by distance
    nearbyShops.sort((a, b) => a['distance'].compareTo(b['distance']));
    return nearbyShops;
  }

  // Generate Dhaka area coordinates for demo shops
  static LatLng generateDhakaCoordinates() {
    final Random random = Random();

    // Dhaka city bounds (approximate)
    const double dhakaLatMin = 23.7000;
    const double dhakaLatMax = 23.8500;
    const double dhakaLngMin = 90.3500;
    const double dhakaLngMax = 90.4500;

    double lat =
        dhakaLatMin + (dhakaLatMax - dhakaLatMin) * random.nextDouble();
    double lng =
        dhakaLngMin + (dhakaLngMax - dhakaLngMin) * random.nextDouble();

    return LatLng(lat, lng);
  }

  // Get shops with coordinates (mock data with realistic Dhaka locations)
  static List<Map<String, dynamic>> getShopsWithLocations() {
    return [
      {
        'id': 'shop_001',
        'name': 'রহমান গ্রোসারি',
        'address': 'ধানমন্ডি-৩২, ঢাকা',
        'phone': '01711123456',
        'category': 'গ্রোসারি',
        'rating': 4.5,
        'latitude': 23.7465,
        'longitude': 90.3765,
        'distance': 0.0, // Will be calculated based on user location
        'availableProducts': [
          'চাল সরু (নাজির/মিনিকেট)',
          'সয়াবিন তেল (পিউর)',
          'আটা সাদা'
        ],
      },
      {
        'id': 'shop_002',
        'name': 'করিম স্টোর',
        'address': 'গুলশান-১, ঢাকা',
        'phone': '01812345678',
        'category': 'সুপার শপ',
        'rating': 4.2,
        'latitude': 23.7925,
        'longitude': 90.4078,
        'distance': 0.0,
        'availableProducts': [
          'চাল মোটা (পাইলস)',
          'গমের আটা (প্রিমিয়াম)',
          'মসুর ডাল'
        ],
      },
      {
        'id': 'shop_003',
        'name': 'নিউ মার্কেট শপ',
        'address': 'নিউমার্কেট, ঢাকা',
        'phone': '01913456789',
        'category': 'খুচরা',
        'rating': 4.0,
        'latitude': 23.7289,
        'longitude': 90.3910,
        'distance': 0.0,
        'availableProducts': ['পেঁয়াজ (দেশি)', 'রুই মাছ', 'গরুর দুধ'],
      },
      {
        'id': 'shop_004',
        'name': 'আলী এন্টারপ্রাইজ',
        'address': 'মিরপুর-১০, ঢাকা',
        'phone': '01714567890',
        'category': 'পাইকারি',
        'rating': 4.7,
        'latitude': 23.8000,
        'longitude': 90.3537,
        'distance': 0.0,
        'availableProducts': [
          'চাল সরু (নাজির/মিনিকেট)',
          'গমের আটা (প্রিমিয়াম)',
          'সয়াবিন তেল (পিউর)'
        ],
      },
      {
        'id': 'shop_005',
        'name': 'হাসান ভ্যারাইটিজ',
        'address': 'উত্তরা সেক্টর-৭, ঢাকা',
        'phone': '01815678901',
        'category': 'গ্রোসারি',
        'rating': 4.3,
        'latitude': 23.8759,
        'longitude': 90.3795,
        'distance': 0.0,
        'availableProducts': ['মসুর ডাল', 'পেঁয়াজ (দেশি)', 'চাল মোটা (পাইলস)'],
      },
    ];
  }

  // Get route between two points using Geoapify
  static Future<List<LatLng>?> getRoute(LatLng start, LatLng end) async {
    try {
      final url =
          '$_baseUrl/routing?waypoints=${start.latitude},${start.longitude}|${end.latitude},${end.longitude}&mode=drive&apiKey=$_geoapifyApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['geometry']['coordinates'][0];
          return coordinates
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
        }
      }
      return null;
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }
}
