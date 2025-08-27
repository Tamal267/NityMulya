import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/map_service.dart';

class AllNearbyShopsScreen extends StatefulWidget {
  const AllNearbyShopsScreen({super.key});

  @override
  State<AllNearbyShopsScreen> createState() => _AllNearbyShopsScreenState();
}

class _AllNearbyShopsScreenState extends State<AllNearbyShopsScreen> {
  List<Map<String, dynamic>> _allShops = [];
  List<Map<String, dynamic>> _filteredShops = [];
  bool _isLoading = true;
  LatLng? _currentLocation;
  String _searchQuery = "";
  String _selectedCategory = "All";
  List<String> _categories = ["All"];

  @override
  void initState() {
    super.initState();
    _loadAllShops();
  }

  Future<void> _loadAllShops() async {
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

      // Get all shops with location data
      final shopsWithLocation = MapService.getShopsWithLocations();

      // Find nearby shops within 50km (larger radius for "View All")
      if (_currentLocation != null) {
        final allShops = MapService.findNearbyShops(
          _currentLocation!,
          shopsWithLocation,
          50.0, // 50km radius for comprehensive view
        );

        // Extract unique categories
        final categories = {"All"};
        for (final shop in allShops) {
          if (shop['category'] != null) {
            categories.add(shop['category']);
          }
        }

        setState(() {
          _allShops = allShops;
          _filteredShops = allShops;
          _categories = categories.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Use sample data if location fails
        _allShops = MapService.getShopsWithLocations();
        _filteredShops = _allShops;

        // Extract categories from sample data
        final categories = {"All"};
        for (final shop in _allShops) {
          if (shop['category'] != null) {
            categories.add(shop['category']);
          }
        }
        _categories = categories.toList();
      });
    }
  }

  void _filterShops() {
    setState(() {
      _filteredShops = _allShops.where((shop) {
        final matchesCategory =
            _selectedCategory == "All" || shop['category'] == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            shop['name'].toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF079b11),
        title: const Text('All Nearby Shops'),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterShops();
                  },
                  decoration: InputDecoration(
                    hintText: "Search shops...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = "";
                              });
                              _filterShops();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(_categories[index]),
                          selected: _selectedCategory == _categories[index],
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = _categories[index];
                            });
                            _filterShops();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredShops.length} shops found',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (_currentLocation != null)
                  IconButton(
                    onPressed: _loadAllShops,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh location',
                  ),
              ],
            ),
          ),
          // Shops List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredShops.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No shops found'),
                            Text('Try adjusting your search or filters'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredShops.length,
                        itemBuilder: (context, index) {
                          final shop = _filteredShops[index];
                          return _buildShopCard(shop);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.indigo,
              child: Text(
                shop['name'][0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${shop['distance'].toStringAsFixed(1)} km away',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        shop['rating'].toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          shop['category'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/enhanced-map'),
                  icon: const Icon(Icons.map, color: Colors.indigo),
                  tooltip: 'View on map',
                ),
                IconButton(
                  onPressed: () => _callShop(shop),
                  icon: const Icon(Icons.phone, color: Colors.green),
                  tooltip: 'Call shop',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
