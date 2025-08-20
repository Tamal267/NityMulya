import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapDebugScreen extends StatefulWidget {
  const MapDebugScreen({super.key});

  @override
  State<MapDebugScreen> createState() => _MapDebugScreenState();
}

class _MapDebugScreenState extends State<MapDebugScreen> {
  String _debugInfo = 'Starting debug...';

  @override
  void initState() {
    super.initState();
    _runDebugTests();
  }

  Future<void> _runDebugTests() async {
    String result = '';

    // Test 1: Check location permissions
    result += '=== LOCATION PERMISSION TEST ===\n';
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      result += 'Location services enabled: $serviceEnabled\n';

      LocationPermission permission = await Geolocator.checkPermission();
      result += 'Current permission: $permission\n';

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        result += 'Requested permission: $permission\n';
      }
    } catch (e) {
      result += 'Location permission error: $e\n';
    }

    // Test 2: Try to get current location
    result += '\n=== LOCATION FETCH TEST ===\n';
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      result += 'Location: ${position.latitude}, ${position.longitude}\n';
      result += 'Accuracy: ${position.accuracy}m\n';
    } catch (e) {
      result += 'Location fetch error: $e\n';
      result += 'Trying with low accuracy...\n';
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
        result +=
            'Low accuracy location: ${position.latitude}, ${position.longitude}\n';
      } catch (e2) {
        result += 'Low accuracy also failed: $e2\n';
      }
    }

    // Test 3: Test Geoapify API
    result += '\n=== GEOAPIFY API TEST ===\n';
    const String apiKey = 'a2621109b87d48c0a55f0c71dce604d8';
    try {
      final url =
          'https://api.geoapify.com/v1/geocode/search?text=Dhaka&apiKey=$apiKey';
      final response = await http.get(Uri.parse(url));
      result += 'API Response status: ${response.statusCode}\n';
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        result +=
            'API working! Found ${data['features']?.length ?? 0} results\n';
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coords = data['features'][0]['geometry']['coordinates'];
          result += 'Dhaka coordinates: ${coords[1]}, ${coords[0]}\n';
        }
      } else {
        result += 'API Error: ${response.body}\n';
      }
    } catch (e) {
      result += 'API request error: $e\n';
    }

    // Test 4: Platform info
    result += '\n=== PLATFORM INFO ===\n';
    result += 'Platform: ${Theme.of(context).platform}\n';

    setState(() {
      _debugInfo = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Map Debug Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _debugInfo,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _runDebugTests,
                child: const Text('Run Debug Tests Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
