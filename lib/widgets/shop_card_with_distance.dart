import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopCardWithDistance extends StatefulWidget {
  final Map<String, dynamic> shop;
  final Position? userLocation;
  final String productTitle;
  final String unit;
  final VoidCallback onTap;
  final VoidCallback onBuyNow;

  const ShopCardWithDistance({
    super.key,
    required this.shop,
    required this.userLocation,
    required this.productTitle,
    required this.unit,
    required this.onTap,
    required this.onBuyNow,
  });

  @override
  State<ShopCardWithDistance> createState() => _ShopCardWithDistanceState();
}

class _ShopCardWithDistanceState extends State<ShopCardWithDistance> {
  String? _distance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  Future<void> _calculateDistance() async {
    print('=== DISTANCE CALCULATION DEBUG ===');
    print('📍 User Location: ${widget.userLocation?.latitude}, ${widget.userLocation?.longitude}');
    print('🏪 Shop: ${widget.shop['name']}');
    print('🏪 Shop Latitude: ${widget.shop['latitude']} (type: ${widget.shop['latitude'].runtimeType})');
    print('🏪 Shop Longitude: ${widget.shop['longitude']} (type: ${widget.shop['longitude'].runtimeType})');
    print('=== Shop Data ===');
    widget.shop.forEach((key, value) => print('$key: $value'));
    print('================');
    
    if (widget.userLocation == null) {
      print('❌ User location is NULL');
      setState(() {
        _distance = 'No GPS';
        _isLoading = false;
      });
      return;
    }
    
    if (widget.shop['latitude'] == null || widget.shop['longitude'] == null) {
      print('❌ Shop coordinates are NULL');
      print('Shop latitude: ${widget.shop['latitude']}');
      print('Shop longitude: ${widget.shop['longitude']}');
      setState(() {
        _distance = 'No Coords';
        _isLoading = false;
      });
      return;
    }

    try {
      print('✅ Starting calculation...');
      final result = await _calculateDistanceHelper(
        widget.userLocation!.latitude,
        widget.userLocation!.longitude,
        double.tryParse(widget.shop['latitude'].toString()) ?? 0.0,
        double.tryParse(widget.shop['longitude'].toString()) ?? 0.0,
      );

      if (result != null) {
        print('✅ Distance calculated: ${result['distance']} KM');
        setState(() {
          _distance = result['distance'];
          _isLoading = false;
        });
      } else {
        print('❌ Distance calculation returned null');
        setState(() {
          _distance = 'Calc Error';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Distance calculation exception: $e');
      setState(() {
        _distance = 'Error';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, String>?> _calculateDistanceHelper(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      // Using OSRM for routing
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$startLng,$startLat;$endLng,$endLat?overview=false',
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final distanceKm = (route['distance'] / 1000).toStringAsFixed(1);

          return {
            'distance': distanceKm,
          };
        }
      }

      // Fallback to straight-line distance
      final distanceInMeters = Geolocator.distanceBetween(
        startLat,
        startLng,
        endLat,
        endLng,
      );

      final distanceKm = (distanceInMeters / 1000).toStringAsFixed(1);

      return {
        'distance': distanceKm,
      };
    } catch (e) {
      print('Error calculating distance: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.shop['unit_price']?.toString() ?? '0';
    final shopName = widget.shop['name']?.toString() ?? 'Unknown Shop';
    final shopAddress = widget.shop['address']?.toString() ?? 'Unknown Address';
    final shopPhone = widget.shop['phone']?.toString() ?? 'No Phone';
    final stockQuantity = widget.shop['stock_quantity']?.toString() ?? '0';
    final lowStockThreshold = widget.shop['low_stock_threshold']?.toString() ?? '10';

    // Determine stock status
    final stock = int.tryParse(stockQuantity) ?? 0;
    final threshold = int.tryParse(lowStockThreshold) ?? 10;
    final stockStatus = stock > 50
        ? 'High Stock'
        : stock > threshold
            ? 'Medium Stock'
            : 'Low Stock';
    final stockColor = stock > 50
        ? Colors.green
        : stock > threshold
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Left: Shop Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Center: Shop Info & Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop Name + Distance
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shopName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Distance with Icon
                        if (_isLoading)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 4),
                                Text('...', style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.near_me,
                                  size: 12,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${_distance ?? '0'} km',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Address with icon
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, 
                             size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            shopAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 3),
                    
                    // Phone with icon
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, 
                             size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Text(
                          shopPhone,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Price Display (Left Side)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade600],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "৳$price",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 10),
              
              // Right Side
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Medium Stock Text (Previous Style)
                  Text(
                    stockStatus,
                    style: TextStyle(
                      color: stockColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Buy Now Button (Side by side style)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: InkWell(
                      onTap: widget.onBuyNow,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Buy Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Stock Info
                  Text(
                    "Stock: $stockQuantity",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
