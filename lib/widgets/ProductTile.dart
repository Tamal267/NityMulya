import 'package:flutter/material.dart';

class ProductTile extends StatelessWidget {
  final String title;
  final String unit;
  final int lowPrice;
  final int highPrice;
  final VoidCallback onTap;

  const ProductTile({
    required this.title,
    required this.unit,
    required this.lowPrice,
    required this.highPrice,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Unit: $unit"),
              Spacer(),
              Text("৳ $lowPrice - $highPrice", style: TextStyle(fontSize: 16, color: Colors.indigo)),
            ],
          ),
        ),
      ),
    );
  }
}
