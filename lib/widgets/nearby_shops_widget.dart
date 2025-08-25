import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNearbyShops();
  }

  Future<void> _loadNearbyShops() async {
    setState(() => _isLoading = true);

    try {
      // Always show sample shops for now
      final shopsWithLocation = MapService.getShopsWithLocations();

      setState(() {
        _nearbyShops = shopsWithLocation.take(widget.maxShops).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading nearby shops: $e');
      // Even if everything fails, show some default shops
      setState(() {
        _isLoading = false;
        _nearbyShops = [
          {
            'id': 'shop_001',
            'name': 'রহমান গ্রোসারি',
            'address': 'ধানমন্ডি-৩২, ঢাকা',
            'phone': '01711123456',
            'category': 'গ্রোসারি',
            'rating': 4.5,
            'distance': 1.2,
          },
          {
            'id': 'shop_002',
            'name': 'করিম স্টোর',
            'address': 'গুলশান-১, ঢাকা',
            'phone': '01812345678',
            'category': 'সুপার শপ',
            'rating': 4.2,
            'distance': 2.5,
          },
          {
            'id': 'shop_003',
            'name': 'নিউ মার্কেট শপ',
            'address': 'নিউমার্কেট, ঢাকা',
            'phone': '01913456789',
            'category': 'খুচরা',
            'rating': 4.0,
            'distance': 3.1,
          }
        ].take(widget.maxShops).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'NearbyShopsWidget: Building with ${_nearbyShops.length} shops, isLoading: $_isLoading');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                onPressed: () => Navigator.pushNamed(context, '/map'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_nearbyShops.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('No nearby shops found'),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nearbyShops.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final shop = _nearbyShops[index];
              return _buildShopCard(shop);
            },
          ),
      ],
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo,
              child: Text(
                shop['name'][0],
                style: const TextStyle(color: Colors.white),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${shop['distance'].toStringAsFixed(1)} km away',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        shop['rating'].toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          shop['category'],
                          style: const TextStyle(
                            fontSize: 10,
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
                  onPressed: () => Navigator.pushNamed(context, '/map'),
                  icon: const Icon(Icons.map, color: Colors.indigo),
                  iconSize: 20,
                  tooltip: 'View on map',
                ),
                IconButton(
                  onPressed: () => _callShop(shop),
                  icon: const Icon(Icons.phone, color: Colors.green),
                  iconSize: 20,
                  tooltip: 'Call shop',
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
