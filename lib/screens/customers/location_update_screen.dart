import 'package:flutter/material.dart';

import '../../models/location_models.dart';
import '../../services/location_service.dart';

class LocationUpdateScreen extends StatefulWidget {
  final UserLocation? currentLocation;
  final String locationType; // 'permanent', 'current'
  final Function(UserLocation) onLocationUpdated;

  const LocationUpdateScreen({
    super.key,
    this.currentLocation,
    required this.locationType,
    required this.onLocationUpdated,
  });

  @override
  State<LocationUpdateScreen> createState() => _LocationUpdateScreenState();
}

class _LocationUpdateScreenState extends State<LocationUpdateScreen> {
  final TextEditingController _addressController = TextEditingController();
  UserLocation? _selectedLocation;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.currentLocation;
    if (_selectedLocation?.address != null) {
      _addressController.text = _selectedLocation!.address!;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _selectedLocation = location.copyWith(type: widget.locationType);
          _addressController.text = location.address ?? '';
        });
      } else {
        setState(() {
          _errorMessage =
              'Could not get current location. Please check your location settings.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchAddress() async {
    if (_addressController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an address to search';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location =
          await LocationService.geocodeAddress(_addressController.text.trim());
      if (location != null) {
        setState(() {
          _selectedLocation = location.copyWith(
            type: widget.locationType,
            address: _addressController.text.trim(),
          );
        });
      } else {
        setState(() {
          _errorMessage =
              'Could not find the address. Please try a different address.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching address: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveLocation() {
    if (_selectedLocation != null) {
      widget.onLocationUpdated(_selectedLocation!);
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = 'Please select a location first';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update ${widget.locationType.capitalize()} Location'),
        backgroundColor: const Color(0xFF079b11),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Your Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Current location section
            if (_selectedLocation != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}'),
                    Text(
                        'Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}'),
                    if (_selectedLocation!.address != null)
                      Text('Address: ${_selectedLocation!.address}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Address input
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Enter Address',
                hintText: 'e.g., Dhaka, Bangladesh',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchAddress,
                ),
              ),
              onSubmitted: (_) => _searchAddress(),
            ),
            const SizedBox(height: 16),

            // Get current location button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isLoading
                    ? 'Getting Location...'
                    : 'Use Current Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Spacer(),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedLocation != null ? _saveLocation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF079b11),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
