import 'package:flutter/material.dart';
import '../../widgets/custom_drawer.dart';
import 'product_detail_screen.dart';
import 'shop_items_screen.dart';
import '../../models/shop.dart';
import '../../services/shop_service.dart';

class FavoriteProductsScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userRole;

  const FavoriteProductsScreen({
    super.key,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  @override
  State<FavoriteProductsScreen> createState() => _FavoriteProductsScreenState();
}

class _FavoriteProductsScreenState extends State<FavoriteProductsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock favorite products data
  final List<Map<String, dynamic>> favoriteProducts = [
    {
      'title': 'চাল সরু (নাজির/মিনিকেট)',
      'unit': 'প্রতি কেজি',
      'currentPrice': '৳55',
      'image': 'assets/image/1.jpg',
      'subcat_id': 'rice_fine',
      'priceHistory': [
        {'date': '২০২৫-০১-০১', 'price': 52},
        {'date': '২০২৫-০১-১৫', 'price': 54},
        {'date': '২০২৫-০২-০১', 'price': 55},
      ],
    },
    {
      'title': 'সয়াবিন তেল',
      'unit': 'প্রতি লিটার',
      'currentPrice': '৳140',
      'image': 'assets/image/tel1liter.jpeg',
      'subcat_id': 'oil_soybean',
      'priceHistory': [
        {'date': '২০২৫-০১-০১', 'price': 135},
        {'date': '২০২৫-০১-১৫', 'price': 138},
        {'date': '২০২৫-০২-০১', 'price': 140},
      ],
    },
    {
      'title': 'চিনি স্থানীয়',
      'unit': 'প্রতি কেজি',
      'currentPrice': '৳78',
      'image': 'assets/image/suger.jpeg',
      'subcat_id': 'sugar_local',
      'priceHistory': [
        {'date': '২০২৫-০১-০১', 'price': 75},
        {'date': '২০২৫-০১-১৫', 'price': 76},
        {'date': '২০২৫-০২-০১', 'price': 78},
      ],
    },
  ];

  // Mock favorite shops data
  final List<Shop> favoriteShops = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavoriteShops();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFavoriteShops() {
    // Mock favorite shops - in real app this would come from database
    final allShops = ShopService.getMockShops();
    favoriteShops.addAll(allShops.take(3)); // Add first 3 shops as favorites
  }

  String _getPriceChange(List<dynamic> priceHistory) {
    if (priceHistory.length < 2) return '';
    
    final latest = priceHistory.last['price'] as int;
    final previous = priceHistory[priceHistory.length - 2]['price'] as int;
    final change = latest - previous;
    
    if (change > 0) {
      return '+৳$change';
    } else if (change < 0) {
      return '৳$change';
    }
    return 'No change';
  }

  Color _getPriceChangeColor(List<dynamic> priceHistory) {
    if (priceHistory.length < 2) return Colors.grey;
    
    final latest = priceHistory.last['price'] as int;
    final previous = priceHistory[priceHistory.length - 2]['price'] as int;
    final change = latest - previous;
    
    if (change > 0) return Colors.red;
    if (change < 0) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        userName: widget.userName ?? 'Guest User',
        userEmail: widget.userEmail ?? 'guest@example.com',
        userRole: widget.userRole ?? 'Customer',
      ),
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: const Color(0xFF079b11),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.shopping_basket),
              text: 'Favorite Products',
            ),
            Tab(
              icon: Icon(Icons.store),
              text: 'Favorite Shops',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Favorite Products Tab
          _buildFavoriteProductsTab(),
          
          // Favorite Shops Tab
          _buildFavoriteShopsTab(),
        ],
      ),
    );
  }

  Widget _buildFavoriteProductsTab() {
    if (favoriteProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite products yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding products to your favorites!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = favoriteProducts[index];
        final priceHistory = product['priceHistory'] as List<dynamic>;
        final priceChange = _getPriceChange(priceHistory);
        final priceChangeColor = _getPriceChangeColor(priceHistory);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    title: product['title'],
                    unit: product['unit'],
                    low: priceHistory.last['price'] - 3,
                    high: priceHistory.last['price'] + 3,
                    subcatId: product['subcat_id'],
                    userEmail: widget.userEmail,
                    userName: widget.userName,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Product Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        product['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  favoriteProducts.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product['title']} removed from favorites'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Text(
                          product['unit'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Current Price and Change
                        Row(
                          children: [
                            Text(
                              product['currentPrice'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF079b11),
                              ),
                            ),
                            if (priceChange.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: priceChangeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: priceChangeColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  priceChange,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: priceChangeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        // Price History Preview
                        if (priceHistory.length > 1) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Price History:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  priceHistory.reversed.take(3).map((h) => 
                                    '${h['date']}: ৳${h['price']}'
                                  ).join(' • '),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteShopsTab() {
    if (favoriteShops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite shops yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding shops to your favorites!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteShops.length,
      itemBuilder: (context, index) {
        final shop = favoriteShops[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopItemsScreen(shop: shop),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Shop Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        shop.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.store,
                            size: 40,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Shop Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shop.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  favoriteShops.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${shop.name} removed from favorites'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                shop.address,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber[600], size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${shop.rating}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            if (shop.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, color: Colors.green, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Products: ${shop.availableProducts.length} items',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
