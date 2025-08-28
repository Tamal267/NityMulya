import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/location_models.dart';
import '../../services/location_service.dart';

class EnhancedMapScreen extends StatefulWidget {
  final String? userType; // 'customer', 'shop_owner', 'wholesaler'
  final String? userId;
  final UserLocation? initialLocation;
  final bool showNearbyShops;
  final bool showRoutes;

  const EnhancedMapScreen({
    super.key,
    this.userType,
    this.userId,
    this.initialLocation,
    this.showNearbyShops = true,
    this.showRoutes = false,
  });

  @override
  State<EnhancedMapScreen> createState() => _EnhancedMapScreenState();
}

class _EnhancedMapScreenState extends State<EnhancedMapScreen> {
  final MapController _mapController = MapController();
  UserLocation? _currentLocation;
  List<Map<String, dynamic>> _nearbyShops = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _deliveries = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _searchRadius = 10.0;
  String _mapMode = 'shops'; // 'shops', 'orders', 'deliveries'

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use provided location or get current location
      if (widget.initialLocation != null) {
        _currentLocation = widget.initialLocation;
      } else {
        _currentLocation = await LocationService.getCurrentLocation();
        _currentLocation ??= UserLocation(
            latitude: 23.8103,
            longitude: 90.4125,
            address: 'Dhaka, Bangladesh',
            type: 'fallback',
          );
      }

      // Load data based on user type
      await _loadUserTypeSpecificData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading map: $e';
      });
    }
  }

  Future<void> _loadUserTypeSpecificData() async {
    if (widget.userType == null || _currentLocation == null) return;

    switch (widget.userType!.toLowerCase()) {
      case 'customer':
        await _loadCustomerData();
        break;
      case 'shop_owner':
        await _loadShopOwnerData();
        break;
      case 'wholesaler':
        await _loadWholesalerData();
        break;
    }
  }

  Future<void> _loadCustomerData() async {
    if (_currentLocation != null && widget.showNearbyShops) {
      _nearbyShops = await LocationService.getNearbyShops(
        _currentLocation!,
        radiusKm: _searchRadius,
      );
    }
  }

  Future<void> _loadShopOwnerData() async {
    if (widget.userId != null) {
      _orders = await LocationService.getShopOwnerOrders(widget.userId!);
    }
  }

  Future<void> _loadWholesalerData() async {
    if (widget.userId != null) {
      _deliveries =
          await LocationService.getWholesalerDeliveries(widget.userId!);
    }
  }

  void _updateSearchRadius(double radius) {
    setState(() {
      _searchRadius = radius;
    });
    _loadUserTypeSpecificData();
  }

  void _centerOnCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!.toLatLng(), 15.0);
    }
  }

  void _showLocationDetails(Map<String, dynamic> item, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailsBottomSheet(item, type),
    );
  }

  Widget _buildDetailsBottomSheet(Map<String, dynamic> item, String type) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildDetailContent(item, type),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(Map<String, dynamic> item, String type) {
    switch (type) {
      case 'shop':
        return _buildShopDetails(item);
      case 'order':
        return _buildOrderDetails(item);
      case 'delivery':
        return _buildDeliveryDetails(item);
      default:
        return const Center(child: Text('Unknown item type'));
    }
  }

  Widget _buildShopDetails(Map<String, dynamic> shop) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Text(
                  shop['shop_name']?.substring(0, 1).toUpperCase() ?? 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
                      shop['shop_name'] ?? 'Unknown Shop',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      shop['owner_name'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (shop['distance'] != null)
                      Text(
                        '${shop['distance'].toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (shop['address'] != null) ...[
            const Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(shop['address']),
            const SizedBox(height: 16),
          ],
          if (shop['contact'] != null) ...[
            const Text(
              'Contact',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(shop['contact']),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callShop(shop['contact']),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _getDirections(shop),
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
              ),
            ],
          ),
          if (widget.userType == 'customer') ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _viewShopProducts(shop),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('View Products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> order) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${order['id']?.toString().substring(0, 8) ?? 'Unknown'}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildOrderInfoRow('Customer', order['customer_name']),
          _buildOrderInfoRow('Status', order['status']?.toUpperCase()),
          _buildOrderInfoRow('Order Date', order['created_at']),
          if (order['delivery_address'] != null)
            _buildOrderInfoRow('Delivery Address', order['delivery_address']),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callCustomer(order['customer_contact']),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _getDirectionsToCustomer(order),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(order),
              icon: const Icon(Icons.update),
              label: const Text('Update Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails(Map<String, dynamic> delivery) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery to ${delivery['shop_name'] ?? 'Shop'}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildOrderInfoRow('Shop Owner', delivery['shop_owner_name']),
          _buildOrderInfoRow('Status', delivery['status']?.toUpperCase()),
          _buildOrderInfoRow('Delivery Date', delivery['delivery_date']),
          if (delivery['shop_address'] != null)
            _buildOrderInfoRow('Shop Address', delivery['shop_address']),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callShopOwner(delivery['shop_contact']),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Shop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _getDirectionsToShop(delivery),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Add current location marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!.toLatLng(),
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 30,
          ),
        ),
      );
    }

    // Add markers based on current mode
    switch (_mapMode) {
      case 'shops':
        markers.addAll(_buildShopMarkers());
        break;
      case 'orders':
        markers.addAll(_buildOrderMarkers());
        break;
      case 'deliveries':
        markers.addAll(_buildDeliveryMarkers());
        break;
    }

    return markers;
  }

  List<Marker> _buildShopMarkers() {
    return _nearbyShops
        .map((shop) {
          if (shop['latitude'] == null || shop['longitude'] == null) {
            return null;
          }

          return Marker(
            point: LatLng(
                shop['latitude'].toDouble(), shop['longitude'].toDouble()),
            child: GestureDetector(
              onTap: () => _showLocationDetails(shop, 'shop'),
              child: const Icon(
                Icons.store,
                color: Colors.red,
                size: 30,
              ),
            ),
          );
        })
        .where((marker) => marker != null)
        .cast<Marker>()
        .toList();
  }

  List<Marker> _buildOrderMarkers() {
    return _orders
        .map((order) {
          if (order['delivery_latitude'] == null ||
              order['delivery_longitude'] == null) {
            return null;
          }

          return Marker(
            point: LatLng(order['delivery_latitude'].toDouble(),
                order['delivery_longitude'].toDouble()),
            child: GestureDetector(
              onTap: () => _showLocationDetails(order, 'order'),
              child: const Icon(
                Icons.delivery_dining,
                color: Colors.orange,
                size: 30,
              ),
            ),
          );
        })
        .where((marker) => marker != null)
        .cast<Marker>()
        .toList();
  }

  List<Marker> _buildDeliveryMarkers() {
    return _deliveries
        .map((delivery) {
          if (delivery['shop_latitude'] == null ||
              delivery['shop_longitude'] == null) {
            return null;
          }

          return Marker(
            point: LatLng(delivery['shop_latitude'].toDouble(),
                delivery['shop_longitude'].toDouble()),
            child: GestureDetector(
              onTap: () => _showLocationDetails(delivery, 'delivery'),
              child: const Icon(
                Icons.local_shipping,
                color: Colors.purple,
                size: 30,
              ),
            ),
          );
        })
        .where((marker) => marker != null)
        .cast<Marker>()
        .toList();
  }

  Widget _buildMapModeSelector() {
    if (widget.userType == null) return const SizedBox.shrink();

    List<String> modes = [];
    switch (widget.userType!.toLowerCase()) {
      case 'customer':
        modes = ['shops'];
        break;
      case 'shop_owner':
        modes = ['orders'];
        break;
      case 'wholesaler':
        modes = ['deliveries'];
        break;
    }

    if (modes.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: SegmentedButton<String>(
        segments: modes
            .map((mode) => ButtonSegment<String>(
                  value: mode,
                  label: Text(mode.capitalize()),
                ))
            .toList(),
        selected: {_mapMode},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _mapMode = newSelection.first;
          });
          _loadUserTypeSpecificData();
        },
      ),
    );
  }

  Widget _buildSearchRadiusSlider() {
    if (widget.userType != 'customer' || !widget.showNearbyShops) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Radius: ${_searchRadius.toStringAsFixed(1)} km',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _searchRadius,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            onChanged: _updateSearchRadius,
          ),
        ],
      ),
    );
  }

  void _callShop(String? contact) async {
    if (contact != null) {
      final Uri phoneUri = Uri(scheme: 'tel', path: contact);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    }
  }

  void _callCustomer(String? contact) async {
    if (contact != null) {
      final Uri phoneUri = Uri(scheme: 'tel', path: contact);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    }
  }

  void _callShopOwner(String? contact) async {
    if (contact != null) {
      final Uri phoneUri = Uri(scheme: 'tel', path: contact);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    }
  }

  void _getDirections(Map<String, dynamic> location) async {
    if (location['latitude'] != null && location['longitude'] != null) {
      final lat = location['latitude'];
      final lng = location['longitude'];
      final Uri mapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      }
    }
  }

  void _getDirectionsToCustomer(Map<String, dynamic> order) async {
    if (order['delivery_latitude'] != null &&
        order['delivery_longitude'] != null) {
      final lat = order['delivery_latitude'];
      final lng = order['delivery_longitude'];
      final Uri mapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      }
    }
  }

  void _getDirectionsToShop(Map<String, dynamic> delivery) async {
    if (delivery['shop_latitude'] != null &&
        delivery['shop_longitude'] != null) {
      final lat = delivery['shop_latitude'];
      final lng = delivery['shop_longitude'];
      final Uri mapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      }
    }
  }

  void _viewShopProducts(Map<String, dynamic> shop) {
    Navigator.pop(context);
    // Navigate to shop products screen
    // This would be implemented based on your existing shop products screen
  }

  void _updateOrderStatus(Map<String, dynamic> order) {
    // Show dialog to update order status
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Preparing'),
              leading: Radio<String>(
                value: 'preparing',
                groupValue: order['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateStatus(order['id'], 'preparing');
                },
              ),
            ),
            ListTile(
              title: const Text('On the Way'),
              leading: Radio<String>(
                value: 'on_the_way',
                groupValue: order['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateStatus(order['id'], 'on_the_way');
                },
              ),
            ),
            ListTile(
              title: const Text('Delivered'),
              leading: Radio<String>(
                value: 'delivered',
                groupValue: order['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateStatus(order['id'], 'delivered');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(String orderId, String status) async {
    final success = await LocationService.updateDeliveryStatus(
      orderId: orderId,
      status: status,
      currentLocation: _currentLocation,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated successfully')),
      );
      _loadUserTypeSpecificData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: const Color(0xFF079b11),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        initialCenter: _currentLocation?.toLatLng() ??
                            const LatLng(23.8103, 90.4125),
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=a2621109b87d48c0a55f0c71dce604d8',
                          userAgentPackageName: 'com.example.nitymulya',
                        ),
                        MarkerLayer(markers: _buildMarkers()),
                      ],
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _buildMapModeSelector(),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: _buildSearchRadiusSlider(),
                    ),
                  ],
                ),
    );
  }

  String _getAppBarTitle() {
    switch (widget.userType?.toLowerCase()) {
      case 'customer':
        return 'Nearby Shops';
      case 'shop_owner':
        return 'Customer Orders';
      case 'wholesaler':
        return 'Shop Deliveries';
      default:
        return 'Map';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
