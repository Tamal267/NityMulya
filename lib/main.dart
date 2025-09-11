import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nitymulya/config/api_config.dart';
import 'package:nitymulya/config/web_config.dart';
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
import 'package:nitymulya/screens/shop_owner/dashboard_screen.dart';
import 'package:nitymulya/screens/welcome_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_dashboard_screen.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NitiMulya',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        //'/': (context) => const AdminPage(),
        '/': (context) => const WelcomeScreen(),
        
        //'/WelcomeScreen': (context) => const WelcomeScreen(),
        //nahid
        // '/': (context) => const WholesalerDashboardScreen(),
        '/home': (context) => const MainCustomerScreen(),
        '/main-customer': (context) => const MainCustomerScreen(),
        '/login': (context) => const LoginScreen(),
        '/my-orders': (context) => const MyOrdersScreen(),
        '/favorites': (context) => const FavoriteProductsScreen(),
        '/alerts': (context) => const PriceAlertScreen(),
        '/complaints': (context) => const ComplaintFormScreen(),
        '/reviews': (context) => const ReviewsScreen(),
        '/rewards': (context) => const RewardedShopsScreen(),
        '/map': (context) => const MapScreen(),
        '/enhanced-map': (context) => const EnhancedMapScreen(),
        '/customer-profile': (context) => const CustomerProfileScreen(),
        // '/': (context) => const ShopOwnerDashboard(),
        '/shop-dashboard': (context) => const ShopOwnerDashboard(),
        '/wholesaler-dashboard': (context) => const WholesalerDashboardScreen(),
        '/notifications': (context) => const NotificationScreen(),
      },
    );
  }
}
