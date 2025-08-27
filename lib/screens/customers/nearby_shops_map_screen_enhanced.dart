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
      if (mounted) {
        setState(() {
          _fabX = MediaQuery.of(context).size.width - 72; // 56 (FAB size) + 16 (margin)
          _fabY = MediaQuery.of(context).size.height - 200; // From bottom with some margin
        });
      }
    });
  }

  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _currentPosition = position;
        _mapCenter = LatLng(position.latitude, position.longitude);
      });

      // Move map to current location
      _mapController.move(_mapCenter, 14.0);

      // Fetch nearby shops
      await _fetchShops();

    } catch (e) {
      print('Error initializing map: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchShops() async {
    if (_currentPosition == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final shops = await ShopApi.getNearbyShops(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radius: _searchRadius,
      );

      setState(() {
        _shops = shops;
        _isLoading = false;
      });

    } catch (e) {
      print('Error fetching shops: $e');
      setState(() {
        _errorMessage = 'Failed to fetch nearby shops: $e';
        _isLoading = false;
      });
    }
  }

  void _onShopTap(Map<String, dynamic> shop) {
    setState(() {
      _selectedShop = shop;
      _showRoute = true;
    });

    _showShopDialog(
      context: context,
      shop: shop,
    );
  }

  Future<Map<String, dynamic>> _getRealDistance(Map<String, dynamic> shop) async {
    if (_currentPosition == null) {
      return {'distance': 'Unknown', 'duration': 'Unknown'};
    }

    final shopId = shop['id'].toString();
    
    // Check cache first
    if (_realDistanceCache.containsKey(shopId)) {
      return _realDistanceCache[shopId]!;
    }

    try {
      final shopLat = double.parse(shop['latitude'].toString());
      final shopLon = double.parse(shop['longitude'].toString());
      
      // For now, use straight-line distance (you can integrate with routing APIs later)
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        shopLat,
        shopLon,
      );

      final distanceKm = distance / 1000;
      final durationMinutes = (distanceKm / 5) * 60; // Assuming 5 km/h walking speed

      final result = {
        'distance': '${distanceKm.toStringAsFixed(1)} km',
        'duration': '${durationMinutes.toInt()} min walking',
      };

      // Cache the result
      _realDistanceCache[shopId] = result;
      
      return result;

    } catch (e) {
      print('Error calculating distance: $e');
      return {'distance': 'Unknown', 'duration': 'Unknown'};
    }
  }

  void _showShopDialog({
    required BuildContext context,
    required Map<String, dynamic> shop,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(shop['name'] ?? 'Unknown Shop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${shop['address'] ?? 'Unknown'}'),
              Text('Phone: ${shop['phone'] ?? 'No phone'}'),
              if (shop['description'] != null && shop['description'].toString().isNotEmpty)
                Text('Description: ${shop['description']}'),
              const SizedBox(height: 8),
              FutureBuilder<Map<String, dynamic>>(
                future: _getRealDistance(shop),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Calculating distance...');
                  }
                  if (snapshot.hasError) {
                    return const Text('Distance: Unknown');
                  }
                  final data = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distance: ${data['distance']}'),
                      Text('Duration: ${data['duration']}'),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedShop = null;
                _showRoute = false;
              });
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _centerMapOnRoute(shop);
            },
            child: const Text('Show Route'),
          ),
        ],
      ),
    );
  }

  void _centerMapOnRoute(Map<String, dynamic> shop) {
    if (_currentPosition == null) return;

    try {
      final shopLat = double.parse(shop['latitude'].toString());
      final shopLon = double.parse(shop['longitude'].toString());

      // Calculate center point between current location and shop
      final centerLat = (_currentPosition!.latitude + shopLat) / 2;
      final centerLon = (_currentPosition!.longitude + shopLon) / 2;

      // Calculate zoom level based on distance
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        shopLat,
        shopLon,
      );

      double zoom = 15.0;
      if (distance > 5000) zoom = 12.0;
      else if (distance > 2000) zoom = 13.0;
      else if (distance > 1000) zoom = 14.0;

      _mapController.move(LatLng(centerLat, centerLon), zoom);

    } catch (e) {
      print('Error centering map: $e');
    }
  }

  List<Marker> _buildShopMarkers() {
    final markers = <Marker>[];

    // Add current position marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    // Add shop markers
    for (final shop in _shops) {
      try {
        final lat = double.parse(shop['latitude'].toString());
        final lng = double.parse(shop['longitude'].toString());
        
        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _onShopTap(shop),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedShop != null && _selectedShop!['id'] == shop['id']
                      ? Colors.red
                      : Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        print('Error parsing shop coordinates: $e');
      }
    }

    return markers;
  }

  List<Polyline> _buildRoutePolylines() {
    if (!_showRoute || _selectedShop == null || _currentPosition == null) {
      return [];
    }

    try {
      final shopLat = double.parse(_selectedShop!['latitude'].toString());
      final shopLon = double.parse(_selectedShop!['longitude'].toString());

      return [
        Polyline(
          points: [
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            LatLng(shopLat, shopLon),
          ],
          color: Colors.red,
          strokeWidth: 4.0,
        ),
      ];
    } catch (e) {
      print('Error building route polylines: $e');
      return [];
    }
  }

  void _drawRoutes() {
    if (_currentPosition == null || _shops.isEmpty) return;

    final polylines = <Polyline>[];

    for (final shop in _shops) {
      try {
        final shopLat = double.parse(shop['latitude'].toString());
        final shopLon = double.parse(shop['longitude'].toString());

        polylines.add(
          Polyline(
            points: [
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              LatLng(shopLat, shopLon),
            ],
            color: Colors.blue.withOpacity(0.6),
            strokeWidth: 2.0,
          ),
        );
      } catch (e) {
        print('Error drawing route to shop: $e');
      }
    }

    setState(() {
      _routePolylines = polylines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Shops Map'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
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
                  Text('Loading map and nearby shops...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
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
                        minZoom: 5.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.nitymulya',
                        ),
                        PolylineLayer(polylines: _buildRoutePolylines()),
                        PolylineLayer(polylines: _routePolylines),
                        MarkerLayer(markers: _buildShopMarkers()),
                      ],
                    ),

                    // Shop count indicator
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_shops.length} shops found',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Controls panel
                    Positioned(
                      top: 70,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Route info
                            if (_showRoute && _selectedShop != null) ...[
                              FutureBuilder<Map<String, dynamic>>(
                                future: _getRealDistance(_selectedShop!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Text('Calculating...');
                                  }
                                  if (snapshot.hasError || !snapshot.hasData) {
                                    return const Text('Distance: Unknown');
                                  }
                                  final data = snapshot.data!;
                                  return Column(
                                    children: [
                                      Text('${data['distance']}'),
                                      Text('${data['duration']}'),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Radius control
                    Positioned(
                      bottom: _selectedShop != null ? 90 : 20,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Radius: ${_searchRadius.toInt()} km',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 200,
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
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showRoutes = !_showRoutes;
                                });
                                if (_showRoutes) _drawRoutes();
                              },
                              child: Text(
                                _showRoutes ? 'Hide' : 'Routes',
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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedShop!['name'] ?? 'Unknown Shop',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _selectedShop = null;
                                        _showRoute = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<Map<String, dynamic>>(
                                future: _getRealDistance(_selectedShop!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Text('Calculating distance...');
                                  }
                                  if (snapshot.hasError || !snapshot.hasData) {
                                    return const Text('Distance: Unknown');
                                  }
                                  final data = snapshot.data!;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Distance: ${data['distance']}'),
                                      Text('Duration: ${data['duration']}'),
                                    ],
                                  );
                                },
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
                          feedback: FloatingActionButton(
                            onPressed: null,
                            backgroundColor: Colors.blue.withOpacity(0.8),
                            child: const Icon(Icons.my_location, color: Colors.white),
                          ),
                          childWhenDragging: Container(),
                          onDragEnd: (details) {
                            setState(() {
                              _fabX = (details.offset.dx - 28)
                                  .clamp(0, MediaQuery.of(context).size.width - 56);
                              _fabY = (details.offset.dy - 28 - kToolbarHeight)
                                  .clamp(0, MediaQuery.of(context).size.height - 56 - kToolbarHeight);
                            });
                          },
                          child: FloatingActionButton(
                            heroTag: "myLocationFab",
                            onPressed: () {
                              if (_currentPosition != null) {
                                _mapController.move(
                                  LatLng(_currentPosition!.latitude,
                                      _currentPosition!.longitude),
                                  16.0,
                                );
                              }
                            },
                            backgroundColor: Colors.blue,
                            child: const Icon(Icons.my_location, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
