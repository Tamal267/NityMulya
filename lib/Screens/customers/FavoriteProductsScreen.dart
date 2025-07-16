import 'package:flutter/material.dart';

class FavoriteProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Favorites")),
      body: Center(child: Text("Favorite products list")),
    );
  }
}
