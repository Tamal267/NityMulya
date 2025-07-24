import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/customers/complaint_form_screen.dart';
import '../screens/customers/favorite_products_screen.dart';
import '../screens/customers/price_alert_screen.dart';
import '../screens/customers/profile_screen.dart';
import '../screens/customers/review_screen.dart';
import '../screens/customers/rewarded_shops_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const CustomDrawer({
    super.key,
    this.userName = 'Guest User',
    this.userEmail = 'guest@example.com',
    this.userRole = 'Customer',
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.indigo,
            ),
            accountName: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      userName: userName,
                      userEmail: userEmail,
                      userRole: userRole,
                    ),
                  ),
                );
              },
              child: Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      userName: userName,
                      userEmail: userEmail,
                      userRole: userRole,
                    ),
                  ),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.indigo,
                  size: 40,
                ),
              ),
            ),
          ),
          
          // Profile
          ListTile(
            leading: const Icon(Icons.person, color: Colors.indigo),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userName: userName,
                    userEmail: userEmail,
                    userRole: userRole,
                  ),
                ),
              );
            },
          ),
          
          const Divider(),
          
          // Favorites
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text('Favorite Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteProductsScreen()),
              );
            },
          ),
          
          // Price Alerts
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text('Price Alerts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PriceAlertScreen()),
              );
            },
          ),
          
          // Reviews
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Reviews'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReviewScreen()),
              );
            },
          ),
          
          // Rewarded Shops
          ListTile(
            leading: const Icon(Icons.card_giftcard, color: Colors.green),
            title: const Text('Rewarded Shops'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RewardedShopsScreen()),
              );
            },
          ),
          
          const Divider(),
          
          // Complaints
          ListTile(
            leading: const Icon(Icons.report_problem, color: Colors.red),
            title: const Text('File Complaint'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComplaintFormScreen()),
              );
            },
          ),
          
          const Divider(),
          
          // Settings
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userName: userName,
                    userEmail: userEmail,
                    userRole: userRole,
                  ),
                ),
              );
            },
          ),
          
          // Help
          ListTile(
            leading: const Icon(Icons.help, color: Colors.blue),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support feature coming soon')),
              );
            },
          ),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
