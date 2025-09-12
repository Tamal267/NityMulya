import 'package:flutter/material.dart';
import 'package:nitymulya/providers/auth_provider.dart';
import 'package:nitymulya/screens/customers/main_customer_screen.dart';
import 'package:nitymulya/screens/dncrp/dncrp_dashboard_screen.dart';
import 'package:nitymulya/screens/shop_owner/dashboard_screen.dart';
import 'package:nitymulya/screens/welcome_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_dashboard_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // If not authenticated, show welcome screen
        if (!authProvider.isAuthenticated) {
          return const WelcomeScreen();
        }

        // If authenticated, redirect to appropriate dashboard
        return _buildDashboardForUser(authProvider.userType, authProvider.userData);
      },
    );
  }

  Widget _buildDashboardForUser(String? userType, Map<String, dynamic>? userData) {
    switch (userType?.toLowerCase()) {
      case 'customer':
        final userName = userData?['full_name'] ?? userData?['name'] ?? 'Customer';
        final userEmail = userData?['email'] ?? '';
        return MainCustomerScreen(
          userName: userName,
          userEmail: userEmail,
          userRole: 'Customer',
        );
      
      case 'shop_owner':
      case 'shop owner':
        return const ShopOwnerDashboard();
      
      case 'wholesaler':
        return const WholesalerDashboardScreen();
      
      case 'dncrp_admin':
        return const DNCRPDashboardScreen();
      
      default:
        return const WelcomeScreen();
    }
  }
}

// Route guard widget for protected routes
class RouteGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;

  const RouteGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If not authenticated, redirect to welcome screen
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If authenticated but wrong role, redirect to appropriate dashboard
        if (!allowedRoles.contains(authProvider.userType)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              authProvider.getHomeRoute(), 
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If authenticated and correct role, show the child widget
        return child;
      },
    );
  }
}