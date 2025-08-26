import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../network/shop_api.dart';

class NearbyShopsMapScreenEnhanced extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userRole;

  const NearbyShopsMapScreenEnhanced({
    super.key,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  @override
  State<NearbyShopsMapScreenEnhanced> createState() => _NearbyShopsMapScreenEnhancedState();
}

class _NearbyShopsMapScreenEnhancedState extends State<NearbyShopsMapScreenEnhanced> {
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
  Map<String, Map<String, dynamic>> _realDistanceCache = {};

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

      for (int i = 0; i < closestShops.length; i++) {
        final shop = closestShops[i];
        final distanceData = await _getRealDistance(shop);

        if (distanceData.containsKey('coordinates') && distanceData['coordinates'] is List) {
          final coordinates = distanceData['coordinates'] as List;
          
          if (coordinates.isNotEmpty) {
            final points = coordinates
                .map((coord) => LatLng(coord[1] as double, coord[0] as double))
                .toList();

            // Use different colors for different routes
            final colors = [
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.teal,
            ];

            allRoutes.add(Polyline(
              points: points,
              color: colors[i % colors.length].withOpacity(0.7),
              strokeWidth: 3.0,
            ));
          }
        } else {
          // Fallback to straight line if no route coordinates available
          final shopLat = ShopApi.parseDouble(shop['latitude']);
          final shopLon = ShopApi.parseDouble(shop['longitude']);

          if (shopLat != null && shopLon != null) {
            allRoutes.add(Polyline(
              points: [
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                LatLng(shopLat, shopLon),
              ],
              color: Colors.grey.withOpacity(0.5),
              strokeWidth: 2.0,
              pattern: StrokePattern.dashed(segments: [8, 4]),
            ));
          }
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

  // Get real distance and duration using OSRM (free routing service)
  Future<Map<String, dynamic>> _getRealDistance(
      Map<String, dynamic> shop) async {
    if (_currentPosition == null) {
      return {'distance': 'Unknown', 'duration': 'Unknown'};
    }

    final shopLat = ShopApi.parseDouble(shop['latitude']);
    final shopLon = ShopApi.parseDouble(shop['longitude']);

    if (shopLat == null || shopLon == null) {
      return {'distance': 'Unknown', 'duration': 'Unknown'};
    }

    // Create a unique key for caching
    final key =
        '${_currentPosition!.latitude},${_currentPosition!.longitude}-$shopLat,$shopLon';

    // Check cache first
    if (_realDistanceCache.containsKey(key)) {
      return _realDistanceCache[key]!;
    }

    try {
      // Using OSRM (free routing service) - no API key required
      final url = 'https://router.project-osrm.org/route/v1/driving/${_currentPosition!.longitude},${_currentPosition!.latitude};$shopLon,$shopLat?overview=full&geometries=geojson';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          
          final distanceMeters = route['distance'] as num;
          final durationSeconds = route['duration'] as num;
          
          final distanceKm = (distanceMeters / 1000).toStringAsFixed(1);
          final durationMin = (durationSeconds / 60).toStringAsFixed(0);

          // Extract route coordinates for drawing
          List<dynamic> coordinates = [];
          if (route['geometry'] != null && route['geometry']['coordinates'] != null) {
            coordinates = route['geometry']['coordinates'] as List;
          }

          final result = {
            'distance': '${distanceKm} km',
            'duration': '${durationMin} min',
            'coordinates': coordinates,
            'real_distance_meters': distanceMeters,
            'duration_seconds': durationSeconds,
          };

          // Cache the result
          _realDistanceCache[key] = result;

          return result;
        }
      }
    } catch (e) {
      print('Error getting real distance from OSRM: $e');
    }

    // Fallback to straight line distance with estimated time
    final straightDistance = ShopApi.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      shopLat,
      shopLon,
    );

    // Estimate time based on average speed (assume 30 km/h in city)
    final estimatedTimeMinutes = ((straightDistance * 1000) / (30000 / 60)).round();

    final fallback = {
      'distance': '~${straightDistance.toStringAsFixed(1)} km',
      'duration': '~${estimatedTimeMinutes} min',
      'real_distance_meters': straightDistance * 1000,
      'duration_seconds': estimatedTimeMinutes * 60,
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
            width: 80, // Increased width to prevent overflow
            height: 100, // Increased height to accommodate both icon and distance
            child: GestureDetector(
              onTap: () => _showShopDetails(shop, distance),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Distance and time label - positioned above the marker
                  if (distance != null)
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getRealDistance(shop),
                      builder: (context, snapshot) {
                        return Container(
                          constraints: const BoxConstraints(
                            maxWidth: 75, 
                            minHeight: 20,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                snapshot.hasData 
                                    ? snapshot.data!['distance'] ?? '${distance?.toStringAsFixed(1) ?? '0'} km'
                                    : '${distance?.toStringAsFixed(1) ?? '0'} km',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (snapshot.hasData && snapshot.data!['duration'] != 'Unknown') ...[
                                const SizedBox(height: 1),
                                Text(
                                  snapshot.data!['duration'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  if (distance != null) const SizedBox(height: 4),
                  // Shop icon
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
                          blurRadius: 4,
                          offset: const Offset(0, 2),
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

  // Build route polylines
  List<Polyline> _buildRoutePolylines() {
    List<Polyline> polylines = [];
    
    // Add bulk routes if showing routes to multiple shops
    polylines.addAll(_routePolylines);
    
    if (_currentPosition == null || _selectedShop == null || !_showRoute) {
      return polylines;
    }

    final shopLat = ShopApi.parseDouble(_selectedShop!['latitude']);
    final shopLon = ShopApi.parseDouble(_selectedShop!['longitude']);

    if (shopLat == null || shopLon == null) return polylines;

    // Add the selected shop route (this will be a straight line for now)
    polylines.add(
      Polyline(
        points: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          LatLng(shopLat, shopLon),
        ],
        strokeWidth: 4.0,
        color: Colors.blue,
        pattern: StrokePattern.dashed(segments: [10, 5]),
      ),
    );
    
    return polylines;
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
            Expanded(
              child: Text(
                shop['name'] ?? 'Unknown Shop',
                style: const TextStyle(fontSize: 18),
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
            // Enhanced distance and time info
            FutureBuilder<Map<String, dynamic>>(
              future: _getRealDistance(shop),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions,
                                size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Route Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.straighten,
                                size: 14, color: Colors.blue.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Distance: ${snapshot.data!['distance']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.blue.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Time: ${snapshot.data!['duration']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Calculating route...'),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
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
        title: const Text('Nearby Shops - Enhanced'),
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
                    // Search radius control with enhanced features
                    Positioned(
                      bottom: _selectedShop != null ? 90 : 20,
                      left: 16,
                      right: 16,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 60),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Radius: ${_searchRadius.toInt()} km',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
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
                                  height: 28,
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
                                      minimumSize: const Size(0, 28),
                                      textStyle: const TextStyle(fontSize: 10),
                                      backgroundColor: _showRoutes 
                                          ? const Color(0xFF079b11) 
                                          : Colors.grey.shade300,
                                    ),
                                    child: Text(
                                      _showRoutes ? 'Hide Routes' : 'Show Routes',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: _showRoutes ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Selected shop info with enhanced details
                    if (_selectedShop != null && _currentPosition != null)
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 50),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
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
                              Icon(Icons.store,
                                  color: Colors.blue.shade700, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedShop!['name'] ?? 'Unknown Shop',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    FutureBuilder<Map<String, dynamic>>(
                                      future: _getRealDistance(_selectedShop!),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Text(
                                            '${snapshot.data!['distance']} • ${snapshot.data!['duration']} • Tap to see route',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                        return Text(
                                          'Calculating route...',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue.shade600,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedShop = null;
                                      _showRoute = false;
                                    });
                                  },
                                  icon: Icon(Icons.close,
                                      color: Colors.blue.shade700, size: 14),
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
