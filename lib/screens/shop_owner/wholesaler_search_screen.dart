import 'package:flutter/material.dart';
import 'package:nitymulya/network/shop_owner_api.dart';
import 'package:nitymulya/screens/shop_owner/chat_screen.dart';

class WholesalerSearchScreen extends StatefulWidget {
  const WholesalerSearchScreen({super.key});

  @override
  State<WholesalerSearchScreen> createState() => _WholesalerSearchScreenState();
}

class _WholesalerSearchScreenState extends State<WholesalerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _wholesalers = [];
  List<Map<String, dynamic>> _filteredWholesalers = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWholesalers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWholesalers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ShopOwnerApiService.searchWholesalers();
      
      if (result['success'] == true) {
        setState(() {
          _wholesalers = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _filteredWholesalers = _wholesalers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load wholesalers';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading wholesalers: $e';
        _isLoading = false;
      });
    }
  }

  void _filterWholesalers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWholesalers = _wholesalers;
      } else {
        _filteredWholesalers = _wholesalers.where((wholesaler) {
          final name = wholesaler['full_name']?.toString().toLowerCase() ?? '';
          final email = wholesaler['email']?.toString().toLowerCase() ?? '';
          final contact = wholesaler['contact']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          
          return name.contains(searchLower) || 
                 email.contains(searchLower) || 
                 contact.contains(searchLower);
        }).toList();
      }
    });
  }

  void _openChatWithWholesaler(Map<String, dynamic> wholesaler) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          contactId: wholesaler['id'].toString(),
          contactType: 'wholesaler',
          contactName: wholesaler['full_name']?.toString() ?? 'Wholesaler',
          contactPhone: wholesaler['contact']?.toString(),
        ),
      ),
    );
  }

  String _getWholesalerInitial(String name) {
    if (name.isEmpty) return 'W';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Search Wholesalers",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[600],
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
                hintText: "Search wholesalers by name, email, or phone...",
                prefixIcon: Icon(Icons.search, color: Colors.purple[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterWholesalers('');
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
              onChanged: _filterWholesalers,
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
            Text("Loading wholesalers..."),
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
              onPressed: _loadWholesalers,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_filteredWholesalers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty 
                  ? "No wholesalers found matching your search"
                  : "No wholesalers available",
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
                  : "Check back later for wholesalers",
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
      itemCount: _filteredWholesalers.length,
      itemBuilder: (context, index) {
        return _buildWholesalerCard(_filteredWholesalers[index]);
      },
    );
  }

  Widget _buildWholesalerCard(Map<String, dynamic> wholesaler) {
    final name = wholesaler['full_name']?.toString() ?? 'Unknown Wholesaler';
    final email = wholesaler['email']?.toString() ?? '';
    final contact = wholesaler['contact']?.toString() ?? '';
    final address = wholesaler['address']?.toString() ?? '';
    final initial = _getWholesalerInitial(name);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openChatWithWholesaler(wholesaler),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.purple[100],
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.purple[600],
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
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.purple[600],
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
