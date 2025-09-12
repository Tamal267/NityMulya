import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nitymulya/config/api_config.dart';
import 'package:nitymulya/config/web_config.dart';
import 'package:nitymulya/providers/auth_provider.dart';
import 'package:nitymulya/screens/auth/login_screen.dart';
import 'package:nitymulya/screens/customers/complaint_form_screen.dart';
import 'package:nitymulya/screens/customers/customer_profile_screen.dart';
import 'package:nitymulya/screens/customers/enhanced_map_screen.dart';
import 'package:nitymulya/screens/customers/favorite_products_screen.dart';
import 'package:nitymulya/screens/customers/main_customer_screen.dart';
import 'package:nitymulya/screens/customers/map_screen.dart';
import 'package:nitymulya/screens/customers/my_orders_screen.dart';
import 'package:nitymulya/screens/customers/notification_screen.dart';
import 'package:nitymulya/screens/customers/price_alert_screen.dart';
import 'package:nitymulya/screens/customers/reviews_screen.dart';
import 'package:nitymulya/screens/customers/rewarded_shops_screen.dart';
import 'package:nitymulya/screens/dncrp/dncrp_dashboard_screen.dart';
import 'package:nitymulya/screens/shop_owner/dashboard_screen.dart';
import 'package:nitymulya/screens/welcome_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_dashboard_screen.dart';
import 'package:nitymulya/utils/auth_wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure web-specific settings to avoid Chrome debugging issues
  WebConfig.configure();

  // Initialize API configuration
  await ApiConfig.initialize();

  await dotenv.load(fileName: ".env.local");
  runApp(const NitiMulyaApp());
}

class NitiMulyaApp extends StatelessWidget {
  const NitiMulyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider()..initializeAuth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NitiMulya',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: 'Poppins',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          
          // Customer routes - protected
          '/home': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: MainCustomerScreen(
              userName: 'Customer',
              userEmail: '',
              userRole: 'Customer',
            ),
          ),
          '/main-customer': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: MainCustomerScreen(
              userName: 'Customer',
              userEmail: '',
              userRole: 'Customer',
            ),
          ),
          '/my-orders': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: MyOrdersScreen(),
          ),
          '/favorites': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: FavoriteProductsScreen(),
          ),
          '/alerts': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: PriceAlertScreen(),
          ),
          '/complaints': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: ComplaintFormScreen(),
          ),
          '/reviews': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: ReviewsScreen(),
          ),
          '/rewards': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: RewardedShopsScreen(),
          ),
          '/map': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: MapScreen(),
          ),
          '/enhanced-map': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: EnhancedMapScreen(),
          ),
          '/customer-profile': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: CustomerProfileScreen(),
          ),
          '/notifications': (context) => const RouteGuard(
            allowedRoles: ['customer'],
            child: NotificationScreen(),
          ),
          
          // Shop Owner routes - protected
          '/shop-dashboard': (context) => const RouteGuard(
            allowedRoles: ['shop_owner', 'shop owner'],
            child: ShopOwnerDashboard(),
          ),
          
          // Wholesaler routes - protected
          '/wholesaler-dashboard': (context) => const RouteGuard(
            allowedRoles: ['wholesaler'],
            child: WholesalerDashboardScreen(),
          ),
          
          // DNCRP Admin routes - protected
          '/dncrp-dashboard': (context) => const RouteGuard(
            allowedRoles: ['dncrp_admin'],
            child: DNCRPDashboardScreen(),
          ),
        },
      ),
    );
  }
}
