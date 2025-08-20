import 'package:flutter/material.dart';

import 'lib/screens/customers/map_screen.dart';
import 'lib/services/map_service.dart';
import 'lib/widgets/nearby_shops_widget.dart';

void main() {
  runApp(const MapTestApp());
}

class MapTestApp extends StatelessWidget {
  const MapTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Integration Test',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MapTestScreen(),
    );
  }
}

class MapTestScreen extends StatelessWidget {
  const MapTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Integration Test'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Map Integration Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Test MapService
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MapService Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final location = await MapService.getCurrentLocation();
                        if (location != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Location: ${location.latitude}, ${location.longitude}',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to get location'),
                            ),
                          );
                        }
                      },
                      child: const Text('Test Location'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final shops = MapService.getShopsWithLocations();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Found ${shops.length} shops'),
                          ),
                        );
                      },
                      child: const Text('Test Shop Data'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nearby Shops Widget Test
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Shops Widget Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    NearbyShopsWidget(maxShops: 3),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Map Screen Test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Full Map Screen Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        );
                      },
                      child: const Text('Open Map Screen'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // API Integration Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Geoapify API Integration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('API Key: a2621109b87d48c0a55f0c71dce604d8'),
                    const SizedBox(height: 5),
                    const Text('Features:'),
                    const Text('• Interactive map with shop markers'),
                    const Text('• Current location detection'),
                    const Text('• Distance calculation'),
                    const Text('• Nearby shops search'),
                    const Text('• Shop details bottom sheet'),
                    const Text('• Directions integration'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
