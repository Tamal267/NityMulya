import 'package:flutter/material.dart';

import '../../models/location_models.dart';
import '../../services/location_service.dart';
import '../../utils/user_session.dart';
import 'location_update_screen.dart';

class OrderWithLocationScreen extends StatefulWidget {
  final String shopId;
  final String shopName;
  final List<Map<String, dynamic>> cartItems;

  const OrderWithLocationScreen({
    super.key,
    required this.shopId,
    required this.shopName,
    required this.cartItems,
  });

  @override
  State<OrderWithLocationScreen> createState() =>
      _OrderWithLocationScreenState();
}

class _OrderWithLocationScreenState extends State<OrderWithLocationScreen> {
  Customer? _customer;
  UserLocation? _selectedDeliveryLocation;
  Map<String, dynamic>? _deliveryDetails;
  bool _isLoading = true;
  bool _isPlacingOrder = false;
  String? _errorMessage;
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await UserSession.getCurrentUser();
      if (user is Customer) {
        setState(() {
          _customer = user;
          // Use current location if available, otherwise permanent location
          _selectedDeliveryLocation = user.orderLocation;
        });

        if (_selectedDeliveryLocation != null) {
          await _calculateDeliveryDetails();
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid user type';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading customer data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateDeliveryDetails() async {
    if (_selectedDeliveryLocation == null) return;

    try {
      // Get shop location (you would fetch this from your API)
      final shopLocation = UserLocation(
        latitude: 23.8103, // Example shop coordinates
        longitude: 90.4125,
        address: 'Shop Address',
        type: 'shop',
      );

      final deliveryInfo = await LocationService.calculateDeliveryRoute(
        from: shopLocation,
        to: _selectedDeliveryLocation!,
      );

      setState(() {
        _deliveryDetails = deliveryInfo;
      });
    } catch (e) {
      print('Error calculating delivery details: $e');
    }
  }

  Future<void> _selectDeliveryLocation() async {
    final result = await Navigator.push<UserLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationUpdateScreen(
          currentLocation: _selectedDeliveryLocation,
          locationType: 'delivery',
          onLocationUpdated: (location) {
            Navigator.pop(context, location);
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDeliveryLocation = result;
      });
      await _calculateDeliveryDetails();
    }
  }

  Future<void> _placeOrder() async {
    if (_customer == null || _selectedDeliveryLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery location')),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final success = await LocationService.createOrderWithLocation(
        customerId: _customer!.id,
        shopOwnerId: widget.shopId,
        deliveryLocation: _selectedDeliveryLocation!,
        items: widget.cartItems,
        specialInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.pop(context, true); // Return success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to place order')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  double _calculateTotal() {
    return widget.cartItems.fold(0.0, (sum, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      return sum + (price * quantity);
    });
  }

  Widget _buildOrderSummary() {
    final subtotal = _calculateTotal();
    final deliveryCost = _deliveryDetails?['estimated_cost'] ?? 0.0;
    final total = subtotal + deliveryCost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.cartItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item['name'] ?? 'Item'),
                      ),
                      Text('${item['quantity']}x'),
                      const SizedBox(width: 8),
                      Text(
                          '৳${((item['price'] ?? 0) * (item['quantity'] ?? 0)).toStringAsFixed(2)}'),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              children: [
                const Expanded(child: Text('Subtotal:')),
                Text('৳${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text('Delivery Charge:')),
                Text('৳${deliveryCost.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '৳${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Delivery Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectDeliveryLocation,
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedDeliveryLocation != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDeliveryLocation!.address ??
                              'Delivery Address',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Lat: ${_selectedDeliveryLocation!.latitude.toStringAsFixed(6)}, '
                          'Lng: ${_selectedDeliveryLocation!.longitude.toStringAsFixed(6)}',
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
              if (_deliveryDetails != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 16, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Estimated Time: ${LocationService.getEstimatedDeliveryTime(_deliveryDetails!['distance_km'])}',
                            style: TextStyle(color: Colors.green.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.directions,
                              size: 16, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Distance: ${_deliveryDetails!['distance_km'].toStringAsFixed(1)} km',
                            style: TextStyle(color: Colors.green.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Please select a delivery location'),
                    ),
                    TextButton(
                      onPressed: _selectDeliveryLocation,
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order from ${widget.shopName}'),
        backgroundColor: const Color(0xFF079b11),
        foregroundColor: Colors.white,
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
                        onPressed: _loadCustomerData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderSummary(),
                      const SizedBox(height: 16),
                      _buildDeliveryInfo(),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Special Instructions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _instructionsController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Any special delivery instructions...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedDeliveryLocation != null &&
                                  !_isPlacingOrder
                              ? _placeOrder
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF079b11),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isPlacingOrder
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Placing Order...'),
                                  ],
                                )
                              : const Text(
                                  'Place Order',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
