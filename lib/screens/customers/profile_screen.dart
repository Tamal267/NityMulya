import 'package:flutter/material.dart';

import '../../network/customer_api.dart';
import '../../services/order_service.dart';
import '../../services/review_service.dart';
import '../auth/login_screen.dart';
import 'my_orders_screen.dart';
import 'reviews_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;
  bool enableNotifications = true;
  bool enableLocationServices = true;
  int totalOrders = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;
  int cancelledOrders = 0;
  double totalSpent = 0.0;
  int totalReviews = 0;
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadOrderStats();
    _loadReviewStats();
  }

  Future<void> _loadReviewStats() async {
    try {
      final reviewService = ReviewService();
      final productReviews =
          await reviewService.getCustomerReviews('customer_current');
      final shopReviews =
          await reviewService.getShopReviews('customer_current');

      final allReviews = [...productReviews, ...shopReviews];

      if (allReviews.isNotEmpty) {
        final totalRating = allReviews.fold<double>(
            0.0, (sum, review) => sum + (review['rating'] ?? 0).toDouble());
        setState(() {
          totalReviews = allReviews.length;
          averageRating = totalRating / allReviews.length;
        });
      } else {
        // Use sample data for demonstration
        setState(() {
          totalReviews = 8;
          averageRating = 4.3;
        });
      }
    } catch (e) {
      // Fallback to sample data
      setState(() {
        totalReviews = 8;
        averageRating = 4.3;
      });
    }
  }

  Future<void> _loadOrderStats() async {
    try {
      // First, try to get stats from database
      final dbStats = await CustomerApi.getOrderStats();

      if (dbStats['success'] == true) {
        setState(() {
          totalOrders = dbStats['totalOrders'] ?? 0;
          pendingOrders = dbStats['pendingOrders'] ?? 0;
          deliveredOrders = dbStats['deliveredOrders'] ?? 0;
          cancelledOrders = dbStats['cancelledOrders'] ?? 0;
          totalSpent = (dbStats['totalSpent'] ?? 0.0).toDouble();
        });
        return;
      }

      // Fallback to local orders if database fails
      final orders = await OrderService().getOrders();
      setState(() {
        totalOrders = orders.length;
        pendingOrders = orders
            .where((order) =>
                order['status'] == 'pending' || order['status'] == 'confirmed')
            .length;
        deliveredOrders =
            orders.where((order) => order['status'] == 'delivered').length;
        cancelledOrders =
            orders.where((order) => order['status'] == 'cancelled').length;
        totalSpent = orders
            .where((order) => order['status'] != 'cancelled')
            .fold(0.0, (sum, order) => sum + (order['totalPrice'] ?? 0.0));
      });
    } catch (e) {
      print('Error loading order stats: $e');

      // Final fallback - try local orders
      try {
        final orders = await OrderService().getOrders();
        setState(() {
          totalOrders = orders.length;
          pendingOrders = orders
              .where((order) =>
                  order['status'] == 'pending' ||
                  order['status'] == 'confirmed')
              .length;
          deliveredOrders =
              orders.where((order) => order['status'] == 'delivered').length;
          cancelledOrders =
              orders.where((order) => order['status'] == 'cancelled').length;
          totalSpent = orders
              .where((order) => order['status'] != 'cancelled')
              .fold(0.0, (sum, order) => sum + (order['totalPrice'] ?? 0.0));
        });
      } catch (localError) {
        // Set to zero if all fails
        setState(() {
          totalOrders = 0;
          pendingOrders = 0;
          deliveredOrders = 0;
          cancelledOrders = 0;
          totalSpent = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.userRole,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Summary Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyOrdersScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.shopping_bag,
                              color: Colors.indigo,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$totalOrders',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const Text(
                              'Total Orders',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyOrdersScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.pending_actions,
                              color: Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$pendingOrders',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text(
                              'Pending Orders',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Additional Order Statistics
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$deliveredOrders',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text(
                          'Delivered',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$cancelledOrders',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const Text(
                          'Cancelled',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.purple,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '৳${totalSpent.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const Text(
                          'Total Spent',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reviews Summary Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReviewsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$totalReviews',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            const Text(
                              'My Reviews',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReviewsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Avg Rating',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Options
            _buildProfileSection('Account', [
              _buildProfileTile(
                icon: Icons.shopping_bag,
                title: 'My Orders',
                subtitle: 'View purchase history & track orders',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrdersScreen(),
                    ),
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.edit,
                title: 'Edit Profile',
                onTap: () {
                  // TODO: Navigate to edit profile screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Edit Profile feature coming soon')),
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () {
                  // TODO: Navigate to change password screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Change Password feature coming soon')),
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.location_on,
                title: 'Address',
                onTap: () {
                  // TODO: Navigate to address management
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Address management coming soon')),
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Settings Section
            _buildProfileSection('Settings', [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notifications',
                value: enableNotifications,
                onChanged: (value) {
                  setState(() {
                    enableNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.location_on,
                title: 'Location Services',
                value: enableLocationServices,
                onChanged: (value) {
                  setState(() {
                    enableLocationServices = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Support Section
            _buildProfileSection('Support', [
              _buildProfileTile(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {
                  // TODO: Navigate to help screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Help & Support feature coming soon')),
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.info,
                title: 'About',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'NitiMulya',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        '© 2025 NitiMulya. All rights reserved.',
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  // TODO: Navigate to privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Privacy Policy feature coming soon')),
                  );
                },
              ),
            ]),

            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
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
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.indigo,
      ),
    );
  }
}
