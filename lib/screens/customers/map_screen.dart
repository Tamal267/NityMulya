import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/shop.dart';
import '../../services/map_service.dart';
import 'shop_items_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _shopsWithLocation = [];
  List<Map<String, dynamic>> _nearbyShops = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _searchRadius = 5.0; // km

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current location
      Position? position = await MapService.getCurrentLocation();
      if (position != null) {
        _currentLocation = LatLng(position.latitude, position.longitude);
      } else {
        // Fallback to Dhaka center if location not available
        _currentLocation = const LatLng(23.8103, 90.4125); // Dhaka center
      }

      // Get shops with location data
      _shopsWithLocation = MapService.getShopsWithLocations();

      // Find nearby shops
      if (_currentLocation != null) {
        _nearbyShops = MapService.findNearbyShops(
          _currentLocation!,
          _shopsWithLocation,
          _searchRadius,
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading map: $e';
      });
    }
  }

  void _updateSearchRadius(double radius) {
    setState(() {
      _searchRadius = radius;
      if (_currentLocation != null) {
        _nearbyShops = MapService.findNearbyShops(
          _currentLocation!,
          _shopsWithLocation,
          _searchRadius,
        );
      }
    });
  }

  void _centerOnCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    }
  }

  void _showShopDetails(Map<String, dynamic> shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildShopBottomSheet(shop),
    );
  }

  Widget _buildShopBottomSheet(Map<String, dynamic> shop) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Text(
                          shop['name'][0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              shop['category'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              shop['rating'].toString(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Distance and address
                  _buildInfoRow(Icons.location_on, 'Distance',
                      '${shop['distance'].toStringAsFixed(1)} km away'),
                  _buildInfoRow(Icons.home, 'Address', shop['address']),
                  _buildInfoRow(Icons.phone, 'Phone', shop['phone']),

                  const SizedBox(height: 20),

                  // Available products
                  const Text(
                    'Available Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (shop['availableProducts'] as List<String>)
                        .take(3)
                        .map((product) => Chip(
                              label: Text(
                                product,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: Colors.indigo.withOpacity(0.1),
                            ))
                        .toList(),
                  ),

                  const Spacer(),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openDirections(shop),
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _visitShop(shop),
                          icon: const Icon(Icons.store),
                          label: const Text('Visit Shop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _openDirections(Map<String, dynamic> shop) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${shop['latitude']},${shop['longitude']}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _visitShop(Map<String, dynamic> shop) {
    Navigator.pop(context); // Close bottom sheet

    // Convert map data to Shop model
    final shopModel = Shop(
      id: shop['id'] ?? 'unknown',
      name: shop['name'],
      address: shop['address'],
      phone: shop['phone'],
      category: shop['category'],
      rating: shop['rating'].toDouble(),
      image: 'assets/image/logo.jpeg', // Default image
      availableProducts: List<String>.from(shop['availableProducts']),
      openingHours: '9:00 AM - 9:00 PM', // Default hours
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopItemsScreen(shop: shopModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading map...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeMap,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Shops'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _centerOnCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: 'Center on my location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search radius slider
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Radius: ${_searchRadius.toStringAsFixed(1)} km',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Slider(
                  value: _searchRadius,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  onChanged: _updateSearchRadius,
                  activeColor: Colors.indigo,
                ),
                Text(
                  '${_nearbyShops.length} shops found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _currentLocation ?? const LatLng(23.8103, 90.4125),
                initialZoom: 13.0,
                maxZoom: 18.0,
                minZoom: 5.0,
              ),
              children: [
                // Map tiles
                TileLayer(
                  urlTemplate:
                      'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=a2621109b87d48c0a55f0c71dce604d8',
                  userAgentPackageName: 'com.example.nitymulya',
                ),

                // Current location marker
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Shop markers
                MarkerLayer(
                  markers: _nearbyShops.map((shop) {
                    return Marker(
                      point: LatLng(shop['latitude'], shop['longitude']),
                      child: GestureDetector(
                        onTap: () => _showShopDetails(shop),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.indigo, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.store,
                                color: Colors.indigo,
                                size: 20,
                              ),
                              Text(
                                shop['name'].toString().length > 8
                                    ? '${shop['name'].toString().substring(0, 8)}...'
                                    : shop['name'].toString(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Search radius circle
                if (_currentLocation != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _currentLocation!,
                        radius: _searchRadius * 1000, // Convert km to meters
                        useRadiusInMeter: true,
                        color: Colors.indigo.withOpacity(0.1),
                        borderColor: Colors.indigo.withOpacity(0.3),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnCurrentLocation,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
