import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

            // Profile Options
            _buildProfileSection('Account', [
              _buildProfileTile(
                icon: Icons.edit,
                title: 'Edit Profile',
                onTap: () {
                  // TODO: Navigate to edit profile screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Profile feature coming soon')),
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () {
                  // TODO: Navigate to change password screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change Password feature coming soon')),
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.location_on,
                title: 'Address',
                onTap: () {
                  // TODO: Navigate to address management
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address management coming soon')),
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
                    const SnackBar(content: Text('Help & Support feature coming soon')),
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
                    applicationLegalese: '© 2025 NitiMulya. All rights reserved.',
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  // TODO: Navigate to privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy Policy feature coming soon')),
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
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
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
