import 'package:flutter/material.dart';

class FavoriteProductsScreen extends StatelessWidget {
  const FavoriteProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: const Color(0xFF079b11),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Favorite products list",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
