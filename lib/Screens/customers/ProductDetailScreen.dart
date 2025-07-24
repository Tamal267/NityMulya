import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String title;
  final String unit;
  final int low;
  final int high;

  const ProductDetailScreen({super.key, 
    required this.title,
    required this.unit,
    required this.low,
    required this.high,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Unit: $unit", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text("Current Price Range:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Low: ৳$low", style: const TextStyle(color: Colors.green)),
            Text("High: ৳$high", style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            const Text("Price History", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(title: Text("2025-07-14"), subtitle: Text("৳75 - 85")),
                  ListTile(title: Text("2025-07-13"), subtitle: Text("৳74 - 84")),
                  ListTile(title: Text("2025-07-12"), subtitle: Text("৳73 - 82")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
