import 'package:flutter/material.dart';

import '../../widgets/global_bottom_nav.dart';

class FavoriteProductsScreen extends StatelessWidget {
  const FavoriteProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Favorite products list",
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: const GlobalBottomNav(
        currentIndex: 2,
      ),
    );
  }
}
