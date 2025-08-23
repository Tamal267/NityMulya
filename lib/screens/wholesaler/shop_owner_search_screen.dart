import 'package:flutter/material.dart';
import 'package:nitymulya/network/wholesaler_api.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_chat_screen.dart';

class ShopOwnerSearchScreen extends StatefulWidget {
  const ShopOwnerSearchScreen({super.key});

  @override
  State<ShopOwnerSearchScreen> createState() => _ShopOwnerSearchScreenState();
}

class _ShopOwnerSearchScreenState extends State<ShopOwnerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _shopOwners = [];
  List<Map<String, dynamic>> _filteredShopOwners = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShopOwners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShopOwners() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await WholesalerApiService.getShopOwners();
      
      if (result['success'] == true) {
        setState(() {
          _shopOwners = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _filteredShopOwners = _shopOwners;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load shop owners';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading shop owners: $e';
        _isLoading = false;
      });
    }
  }

  void _filterShopOwners(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredShopOwners = _shopOwners;
      } else {
        _filteredShopOwners = _shopOwners.where((shopOwner) {
          final name = shopOwner['full_name']?.toString().toLowerCase() ?? '';
          final shopName = shopOwner['shop_name']?.toString().toLowerCase() ?? '';
          final email = shopOwner['email']?.toString().toLowerCase() ?? '';
          final contact = shopOwner['contact']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          
          return name.contains(searchLower) || 
                 shopName.contains(searchLower) ||
                 email.contains(searchLower) || 
                 contact.contains(searchLower);
        }).toList();
      }
    });
  }

  void _openChatWithShopOwner(Map<String, dynamic> shopOwner) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WholesalerChatScreen(
          contactId: shopOwner['id'].toString(),
          contactType: 'shop_owner',
          contactName: shopOwner['shop_name']?.toString() ?? shopOwner['full_name']?.toString() ?? 'Shop Owner',
          contactPhone: shopOwner['contact']?.toString(),
        ),
      ),
    );
  }

  String _getShopOwnerInitial(String name) {
    if (name.isEmpty) return 'S';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Search Shop Owners",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search shop owners by name, shop name, email, or phone...",
                prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterShopOwners('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterShopOwners,
            ),
          ),
          
          // Results
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading shop owners..."),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadShopOwners,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_filteredShopOwners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty 
                  ? "No shop owners found matching your search"
                  : "No shop owners available",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty 
                  ? "Try different search terms"
                  : "Check back later for shop owners",
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredShopOwners.length,
      itemBuilder: (context, index) {
        return _buildShopOwnerCard(_filteredShopOwners[index]);
      },
    );
  }

  Widget _buildShopOwnerCard(Map<String, dynamic> shopOwner) {
    final name = shopOwner['full_name']?.toString() ?? 'Unknown Owner';
    final shopName = shopOwner['shop_name']?.toString() ?? '';
    final email = shopOwner['email']?.toString() ?? '';
    final contact = shopOwner['contact']?.toString() ?? '';
    final address = shopOwner['address']?.toString() ?? '';
    final displayName = shopName.isNotEmpty ? shopName : name;
    final initial = _getShopOwnerInitial(displayName);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openChatWithShopOwner(shopOwner),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green[100],
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (shopName.isNotEmpty && shopName != name)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "Owner: $name",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (email.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.email, 
                              size: 14, 
                              color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (contact.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.phone, 
                              size: 14, 
                              color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            contact,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    if (address.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on, 
                              size: 14, 
                              color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              // Chat Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.green[600],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
