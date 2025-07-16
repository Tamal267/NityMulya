import 'package:flutter/material.dart';

class ShopListScreen extends StatelessWidget {
  const ShopListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa6d58a),
        title: const Text("Shops"),
      ),
      body: Center(
        child: Text(
          "Shop list will be displayed here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
