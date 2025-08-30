import 'package:flutter/material.dart';
import 'package:nitymulya/screens/customers/favorite_products_screen.dart';
import 'package:nitymulya/screens/customers/home_screen.dart';
import 'package:nitymulya/screens/customers/my_orders_screen.dart';
import 'package:nitymulya/screens/customers/shop_list_screen.dart';

class MainCustomerScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userRole;

  const MainCustomerScreen({
    super.key,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  @override
  State<MainCustomerScreen> createState() => _MainCustomerScreenState();
}

class _MainCustomerScreenState extends State<MainCustomerScreen> {
  int currentBottomNavIndex = 0;

  // List of screens for each tab
  List<Widget> get _screens => [
        HomeScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
          userRole: widget.userRole,
        ),
        _buildOrdersScreen(),
        const ShopListScreen(),
        _buildFavoritesScreen(),
      ];

  Widget _buildOrdersScreen() {
    if (widget.userName == null) {
      return _buildLoginRequiredScreen('My Orders');
    }
    return MyOrdersScreen(
      customerId: null, // You may need to pass actual customer ID
      userName: widget.userName,
      userEmail: widget.userEmail,
      userRole: widget.userRole,
      isInBottomNav: true,
      onNavigateToHome: () {
        setState(() {
          currentBottomNavIndex = 0; // Switch to Home tab
        });
      },
    );
  }

  Widget _buildFavoritesScreen() {
    if (widget.userName == null) {
      return _buildLoginRequiredScreen('Favorites');
    }
    return const FavoriteProductsScreen();
  }

  Widget _buildLoginRequiredScreen(String feature) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.login,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              'Login Required',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Please login to access $feature',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF079b11),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 45),
              ),
              child: const Text('Login / Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentBottomNavIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentBottomNavIndex,
        selectedItemColor: const Color(0xFF079b11),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentBottomNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "My Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.store_mall_directory), label: "Shops"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"),
        ],
      ),
    );
  }
}
