import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../network/shop_api.dart';

class NearbyShopsMapScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userRole;

  const NearbyShopsMapScreen({
    super.key,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  @override
  State<NearbyShopsMapScreen> createState() => _NearbyShopsMapScreenState();
}

class _NearbyShopsMapScreenState extends State<NearbyShopsMapScreen> {
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _shops = [];
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  double _searchRadius = 10.0; // km
  Map<String, dynamic>? _selectedShop;
  bool _showRoute = false;
  bool _showRoutes = false;
  List<Polyline> _routePolylines = [];
  final Map<String, Map<String, dynamic>> _realDistanceCache = {};

  // Draggable FAB position
  double _fabX = 300.0;
  double _fabY = 500.0;

  // Default center (Dhaka, Bangladesh)
  LatLng _mapCenter = const LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();
    _initializeMap();

    // Initialize FAB position to bottom-right corner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _fabX = screenSize.width - 72; // 56 + 16 margin
        _fabY = screenSize.height - 200; // Account for bottom panels
      });
    });
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current location
      await _getCurrentLocation();

      // Fetch shops from database
      await _fetchShops();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load map: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
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

      setState(() {
        _currentPosition = position;
        _mapCenter = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
      // Use default location (Dhaka) if location access fails
    }
  }

  Future<void> _fetchShops() async {
    try {
      final shops = await ShopApi.fetchShops();

      // Filter shops by distance if user location is available
      List<Map<String, dynamic>> filteredShops = shops;
      if (_currentPosition != null) {
        filteredShops = ShopApi.filterShopsByDistance(
          shops,
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          _searchRadius,
        );
      }

      setState(() {
        _shops = filteredShops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load shops: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _drawRoutes() async {
    // Draw routes to all visible shops if enabled
    if (_showRoutes && _currentPosition != null) {
      List<Polyline> allRoutes = [];

      // Draw routes to first 5 closest shops to avoid clutter
      final closestShops = _shops.take(5).toList();

      for (final shop in closestShops) {
        final distanceData = await _getRealDistance(shop);

        if (distanceData.containsKey('coordinates')) {
          final coordinates = distanceData['coordinates'] as List;
          final points =
              coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

          allRoutes.add(Polyline(
            points: points,
            color: Colors.blue.withOpacity(0.6),
            strokeWidth: 2.0,
          ));
        }
      }

      setState(() {
        _routePolylines = allRoutes;
      });
    } else {
      setState(() {
        _routePolylines = [];
      });
    }
  }

  // Get real distance and duration using OpenRouteService (free alternative to Google Maps)
  Future<Map<String, dynamic>> _getRealDistance(
      Map<String, dynamic> shop) async {
    if (_currentPosition == null) {
      return {'distance': 'No location', 'duration': ''};
    }

    final shopLat = ShopApi.parseDouble(shop['latitude']);
    final shopLon = ShopApi.parseDouble(shop['longitude']);

    if (shopLat == null || shopLon == null) {
      return {'distance': 'Location unavailable', 'duration': ''};
    }

    // Create a unique key for caching
    final key =
        '${_currentPosition!.latitude},${_currentPosition!.longitude}-$shopLat,$shopLon';

    // Check cache first
    if (_realDistanceCache.containsKey(key)) {
      return _realDistanceCache[key]!;
    }

    try {
      // Using OpenRouteService (free alternative)
      final url = 'https://api.openrouteservice.org/v2/directions/driving-car';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'YOUR_API_KEY_HERE', // Replace with your API key
        },
        body: json.encode({
          'coordinates': [
            [_currentPosition!.longitude, _currentPosition!.latitude],
            [shopLon, shopLat],
          ],
          'format': 'json',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final summary = route['summary'];

        final distanceKm = (summary['distance'] / 1000).toStringAsFixed(1);
        final durationMin = (summary['duration'] / 60).toStringAsFixed(0);

        final result = {
          'distance': '$distanceKm km',
          'duration': '$durationMin min',
          'coordinates': route['geometry']['coordinates'],
        };

        // Cache the result
        _realDistanceCache[key] = result;

        return result;
      }
    } catch (e) {
      print('Error getting real distance: $e');
    }

    // Fallback to straight line distance
    final straightDistance = ShopApi.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      shopLat,
      shopLon,
    );

    // Estimate duration based on distance (assuming 30 km/h average speed)
    final estimatedMinutes = (straightDistance / 30 * 60).round();
    String durationText = '~${estimatedMinutes}min';

    // Use more realistic duration estimates
    if (estimatedMinutes > 60) {
      final hours = (estimatedMinutes / 60).floor();
      final minutes = estimatedMinutes % 60;
      durationText = '~${hours}h ${minutes}min';
    }

    final fallback = {
      'distance': '~${straightDistance.toStringAsFixed(1)} km',
      'duration': durationText,
    };

    _realDistanceCache[key] = fallback;
    return fallback;
  }

  List<Marker> _buildShopMarkers() {
    List<Marker> markers = [];

    // Add user location marker if available
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }

    // Add shop markers with distance labels
    for (final shop in _shops) {
      final latitude = ShopApi.parseDouble(shop['latitude']);
      final longitude = ShopApi.parseDouble(shop['longitude']);

      if (latitude != null && longitude != null) {
        double? distance;
        if (_currentPosition != null) {
          distance = ShopApi.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            latitude,
            longitude,
          );
        }

        markers.add(
          Marker(
            point: LatLng(latitude, longitude),
            width: 120, // Increased width to accommodate shop name and distance
            height: 80, // Increased height for all elements
            child: GestureDetector(
              onTap: () => _showShopDetails(shop, distance),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Shop name - positioned at top
                  if (shop['name'] != null &&
                      shop['name'].toString().trim().isNotEmpty)
                    Container(
                      constraints:
                          const BoxConstraints(maxWidth: 120, minHeight: 18),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.blue.shade200, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        shop['name'].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 2),
                  // Distance label - positioned middle
                  if (distance != null)
                    Container(
                      constraints:
                          const BoxConstraints(maxWidth: 80, minHeight: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 2),
                  // Shop icon - positioned at bottom
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  // Build route polyline between user and shop
  List<Polyline> _buildRoutePolylines() {
    if (_currentPosition == null || _selectedShop == null || !_showRoute) {
      return [];
    }

    final shopLat = ShopApi.parseDouble(_selectedShop!['latitude']);
    final shopLon = ShopApi.parseDouble(_selectedShop!['longitude']);

    if (shopLat == null || shopLon == null) return [];

    return [
      Polyline(
        points: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          LatLng(shopLat, shopLon),
        ],
        strokeWidth: 4.0,
        color: Colors.blue,
        pattern: StrokePattern.dashed(segments: [10, 5]),
      ),
    ];
  }

  void _showShopDetails(Map<String, dynamic> shop, double? distance) {
    setState(() {
      _selectedShop = shop;
      _showRoute = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.store, color: Colors.red),
            const SizedBox(width: 8),
            if (shop['name'] != null &&
                shop['name'].toString().trim().isNotEmpty)
              Expanded(
                child: Text(
                  shop['name'].toString(),
                  style: const TextStyle(fontSize: 18),
                ),
              )
            else
              const Expanded(
                child: Text(
                  'Shop Details',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shop['address'] != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Address: ${shop['address']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (shop['phone'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Phone: ${shop['phone']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (distance != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions,
                        size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Distance: ${distance.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'Route is shown on the map with blue dashed line',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showRoute = false;
                _selectedShop = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          if (_currentPosition != null &&
              shop['latitude'] != null &&
              shop['longitude'] != null)
            ElevatedButton.icon(
              onPressed: () {
                _centerMapOnRoute(shop);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Center on Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF079b11),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _centerMapOnRoute(Map<String, dynamic> shop) {
    if (_currentPosition == null) return;

    final shopLat = ShopApi.parseDouble(shop['latitude']);
    final shopLon = ShopApi.parseDouble(shop['longitude']);

    if (shopLat == null || shopLon == null) return;

    // Calculate the center point between user and shop
    final centerLat = (_currentPosition!.latitude + shopLat) / 2;
    final centerLon = (_currentPosition!.longitude + shopLon) / 2;

    // Calculate appropriate zoom level based on distance
    final distance = ShopApi.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      shopLat,
      shopLon,
    );

    double zoom = 15.0;
    if (distance > 10) zoom = 12.0;
    if (distance > 25) zoom = 11.0;
    if (distance > 50) zoom = 10.0;

    _mapController.move(LatLng(centerLat, centerLon), zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF079b11),
        title: const Text('Nearby Shops'),
        actions: [
          // Toggle route visibility
          IconButton(
            icon: Icon(
              _showRoute ? Icons.route : Icons.route_outlined,
              color: _showRoute ? Colors.white : Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _showRoute = !_showRoute;
                if (!_showRoute) {
                  _selectedShop = null;
                }
              });
            },
            tooltip: _showRoute ? 'Hide Route' : 'Show Route',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading nearby shops...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeMap,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _mapCenter,
                        initialZoom: 14.0,
                        maxZoom: 18.0,
                        minZoom: 10.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.nitymulya.app',
                        ),
                        PolylineLayer(polylines: _buildRoutePolylines()),
                        MarkerLayer(markers: _buildShopMarkers()),
                      ],
                    ),
                    // Shop count and legend overlay
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_shops.length} shops found',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Legend
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('You',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('Shops',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            if (_showRoute && _selectedShop != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('Route',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Search radius control
                    Positioned(
                      bottom: _selectedShop != null ? 90 : 20,
                      left: 16,
                      right: 16,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 50),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Radius: ${_searchRadius.toInt()} km',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 20,
                                child: Slider(
                                  value: _searchRadius,
                                  min: 1.0,
                                  max: 50.0,
                                  divisions: 49,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchRadius = value;
                                    });
                                    _fetchShops();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              height: 24,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showRoutes = !_showRoutes;
                                  });
                                  if (_showRoutes) _drawRoutes();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  minimumSize: const Size(0, 20),
                                  textStyle: const TextStyle(fontSize: 9),
                                ),
                                child: Text(
                                  _showRoutes ? 'Hide' : 'Routes',
                                  style: const TextStyle(fontSize: 9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Selected shop info
                    if (_selectedShop != null && _currentPosition != null)
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 35),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.directions_rounded,
                                  color: Colors.blue.shade700, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: FutureBuilder<Map<String, dynamic>>(
                                  future: _getRealDistance(_selectedShop!),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final distance =
                                          snapshot.data!['distance'];
                                      final duration =
                                          snapshot.data!['duration'];

                                      // Create display text
                                      String displayText = 'Route: $distance';
                                      if (duration != 'Unknown' &&
                                          duration.toString().isNotEmpty) {
                                        displayText += ' • $duration';
                                      }

                                      return Text(
                                        displayText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    }
                                    return Text(
                                      'Calculating route...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedShop = null;
                                      _showRoute = false;
                                    });
                                  },
                                  icon: Icon(Icons.close,
                                      color: Colors.blue.shade700, size: 12),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Draggable My Location FAB
                    if (_currentPosition != null)
                      Positioned(
                        left: _fabX,
                        top: _fabY,
                        child: Draggable(
                          feedback: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFF079b11),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          childWhenDragging: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF079b11).withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.my_location,
                              color: Colors.white.withOpacity(0.7),
                              size: 24,
                            ),
                          ),
                          onDragEnd: (details) {
                            setState(() {
                              // Get screen size
                              final screenSize = MediaQuery.of(context).size;

                              // Calculate new position within screen bounds
                              _fabX = (details.offset.dx - 28)
                                  .clamp(0, screenSize.width - 56);
                              _fabY = (details.offset.dy - 28 - kToolbarHeight)
                                  .clamp(
                                      0,
                                      screenSize.height -
                                          156); // Account for app bar and bottom padding
                            });
                          },
                          child: GestureDetector(
                            onTap: () {
                              _mapController.move(
                                LatLng(_currentPosition!.latitude,
                                    _currentPosition!.longitude),
                                15.0,
                              );
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFF079b11),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
