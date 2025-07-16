import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String title;
  final String unit;
  final int low;
  final int high;

  const ProductDetailScreen({
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Unit: $unit", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Current Price Range:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Low: ৳$low", style: TextStyle(color: Colors.green)),
            Text("High: ৳$high", style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            Text("Price History", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
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
