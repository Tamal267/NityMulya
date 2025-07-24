import 'package:flutter/material.dart';

import '../screens/customers/favorite_products_screen.dart';
import '../screens/customers/home_screen.dart';
import '../screens/customers/shop_list_screen.dart';

class GlobalBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const GlobalBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  void _handleNavigation(BuildContext context, int index) {
    // If onTap is provided, use it (for custom handling)
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // Default navigation logic
    switch (index) {
      case 0:
        // Home - Navigate to home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        // Shop - Navigate to shop list screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ShopListScreen()),
          (route) => false,
        );
        break;
      case 2:
        // Favorites - Navigate to favorites screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FavoriteProductsScreen()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF079b11),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _handleNavigation(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: "Shops",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Favorites",
        ),
      ],
    );
  }
}
