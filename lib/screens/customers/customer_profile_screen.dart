import 'package:flutter/material.dart';

import '../../models/location_models.dart';
import '../../services/location_service.dart';
import '../../utils/user_session.dart';
import 'enhanced_map_screen.dart';
import 'location_update_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  Customer? _customer;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCustomerProfile();
  }

  Future<void> _loadCustomerProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await UserSession.getCurrentUser();
      if (user is Customer) {
        setState(() {
          _customer = user;
        });
      } else {
        setState(() {
          _errorMessage = 'Invalid user type';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePermanentLocation() async {
    if (_customer == null) return;

    final result = await Navigator.push<UserLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationUpdateScreen(
          currentLocation: _customer!.permanentLocation,
          locationType: 'permanent',
          onLocationUpdated: (location) {
            Navigator.pop(context, location);
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _customer = _customer!.copyWith(permanentLocation: result);
      });

      // Save to backend
      final success = await LocationService.updateUserProfileLocation(
        userId: _customer!.id,
        userType: 'customer',
        location: result,
      );

      if (success) {
        // Update session
        await UserSession.updateUserData(_customer!.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Permanent location updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update location')),
        );
      }
    }
  }

  Future<void> _updateCurrentLocation() async {
    if (_customer == null) return;

    final result = await Navigator.push<UserLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationUpdateScreen(
          currentLocation: _customer!.currentLocation,
          locationType: 'current',
          onLocationUpdated: (location) {
            Navigator.pop(context, location);
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _customer = _customer!.copyWith(currentLocation: result);
      });

      // Save current location separately
      final success = await LocationService.updateCustomerLocation(
        _customer!.id,
        result,
        'current',
      );

      if (success) {
        // Update session
        await UserSession.updateUserData(_customer!.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Current location updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update current location')),
        );
      }
    }
  }

  void _viewOnMap() {
    if (_customer?.orderLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnhancedMapScreen(
            userType: 'customer',
            userId: _customer!.id,
            initialLocation: _customer!.orderLocation,
            showNearbyShops: true,
          ),
        ),
      );
    }
  }

  Widget _buildLocationCard(
      String title, UserLocation? location, VoidCallback onUpdate) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  title == 'Permanent Address' ? Icons.home : Icons.location_on,
                  color: const Color(0xFF079b11),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onUpdate,
                  child: Text(location == null ? 'Add' : 'Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (location != null) ...[
              Text(
                location.address ?? 'Address not available',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Lat: ${location.latitude.toStringAsFixed(6)}, '
                'Lng: ${location.longitude.toStringAsFixed(6)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (location.lastUpdated != null)
                Text(
                  'Updated: ${_formatDateTime(location.lastUpdated!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ] else ...[
              Text(
                'No $title set',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF079b11),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _viewOnMap,
            tooltip: 'View on Map',
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
                        onPressed: _loadCustomerProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCustomerProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile header
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFF079b11),
                                child: Text(
                                  _customer?.fullName
                                          .substring(0, 1)
                                          .toUpperCase() ??
                                      'C',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _customer?.fullName ?? 'Customer',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _customer?.email ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Personal Information
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Full Name', _customer?.fullName),
                                _buildInfoRow('Email', _customer?.email),
                                _buildInfoRow('Contact', _customer?.contact),
                                _buildInfoRow(
                                    'Member Since',
                                    _customer?.createdAt != null
                                        ? _formatDateTime(_customer!.createdAt!)
                                        : null),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Location Information
                        const Text(
                          'Location Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLocationCard(
                          'Permanent Address',
                          _customer?.permanentLocation,
                          _updatePermanentLocation,
                        ),
                        _buildLocationCard(
                          'Current Location',
                          _customer?.currentLocation,
                          _updateCurrentLocation,
                        ),
                        const SizedBox(height: 16),

                        // Location info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info, color: Colors.blue.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Location Usage',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• Permanent Address: Used as your default delivery location\n'
                                '• Current Location: Updated when placing orders for accurate delivery\n'
                                '• You can edit both locations anytime from your profile',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Quick Actions
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _viewOnMap,
                                icon: const Icon(Icons.map),
                                label: const Text('View on Map'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF079b11),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/my-orders');
                                },
                                icon: const Icon(Icons.receipt_long),
                                label: const Text('My Orders'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
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

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            child: Text(value ?? 'Not provided'),
          ),
        ],
      ),
    );
  }
}
