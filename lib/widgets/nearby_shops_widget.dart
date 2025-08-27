import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../screens/all_nearby_shops_screen.dart';
import '../services/map_service.dart';

class NearbyShopsWidget extends StatefulWidget {
  final bool showHeader;
  final int maxShops;

  const NearbyShopsWidget({
    super.key,
    this.showHeader = true,
    this.maxShops = 3,
  });

  @override
  State<NearbyShopsWidget> createState() => _NearbyShopsWidgetState();
}

class _NearbyShopsWidgetState extends State<NearbyShopsWidget> {
  List<Map<String, dynamic>> _nearbyShops = [];
  bool _isLoading = true;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadNearbyShops();
  }

  Future<void> _loadNearbyShops() async {
    setState(() => _isLoading = true);

    try {
      // Get current location
      Position? position = await MapService.getCurrentLocation();
      if (position != null) {
        _currentLocation = LatLng(position.latitude, position.longitude);
      } else {
        // Fallback to Dhaka center
        _currentLocation = const LatLng(23.8103, 90.4125);
      }

      // Get shops with location data
      final shopsWithLocation = MapService.getShopsWithLocations();

      // Find nearby shops within 10km
      if (_currentLocation != null) {
        final nearbyShops = MapService.findNearbyShops(
          _currentLocation!,
          shopsWithLocation,
          10.0, // 10km radius
        );

        setState(() {
          _nearbyShops = nearbyShops.take(widget.maxShops).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Use sample data if location fails
        _nearbyShops =
            MapService.getShopsWithLocations().take(widget.maxShops).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize:
          MainAxisSize.min, // Important: don't take more space than needed
      children: [
        if (widget.showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nearby Shops',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllNearbyShopsScreen(),
                  ),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8), // Reduced from 12
        ],
        Expanded(
          // Use expanded to take remaining available space
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _nearbyShops.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('No nearby shops found'),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: _nearbyShops.asMap().entries.map((entry) {
                          final index = entry.key;
                          final shop = entry.value;
                          return Column(
                            children: [
                              _buildShopCard(shop),
                              if (index < _nearbyShops.length - 1)
                                const SizedBox(
                                    height: 6), // Spacing between cards
                            ],
                          );
                        }).toList(),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero, // Remove default margin
      child: Padding(
        padding: const EdgeInsets.all(8), // Reduced from 12
        child: Row(
          children: [
            CircleAvatar(
              radius: 16, // Slightly smaller
              backgroundColor: Colors.indigo,
              child: Text(
                shop['name'][0],
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10), // Reduced from 12
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Important for compact layout
                children: [
                  Text(
                    shop['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // Slightly smaller
                    ),
                    maxLines: 1, // Prevent text overflow
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 11, color: Colors.grey[600]),
                      const SizedBox(width: 3),
                      Text(
                        '${shop['distance'].toStringAsFixed(1)} km away',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Icon(Icons.star, size: 11, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        shop['rating'].toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        // Wrap in Flexible to prevent overflow
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            shop['category'],
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.indigo,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllNearbyShopsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.map, color: Colors.indigo),
                  iconSize: 18, // Smaller icons
                  tooltip: 'View all shops',
                  padding: EdgeInsets.zero, // Remove padding
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: () => _callShop(shop),
                  icon: const Icon(Icons.phone, color: Colors.green),
                  iconSize: 18,
                  tooltip: 'Call shop',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _callShop(Map<String, dynamic> shop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Call ${shop['name']}"),
        content: Text("Phone: ${shop['phone']}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Calling ${shop['phone']}"),
                ),
              );
            },
            child: const Text("Call"),
          ),
        ],
      ),
    );
  }
}
