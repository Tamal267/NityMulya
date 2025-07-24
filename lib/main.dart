import 'package:flutter/material.dart';
import 'package:nitymulya/screens/auth/login_screen.dart';
import 'package:nitymulya/screens/customers/complaint_form_screen.dart';
import 'package:nitymulya/screens/customers/favorite_products_screen.dart';
import 'package:nitymulya/screens/customers/home_screen.dart';
import 'package:nitymulya/screens/customers/price_alert_screen.dart';
import 'package:nitymulya/screens/customers/review_screen.dart';
import 'package:nitymulya/screens/customers/rewarded_shops_screen.dart';

void main() {
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
        '/': (context) => const HomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/favorites': (context) => const FavoriteProductsScreen(),
        '/alerts': (context) => const PriceAlertScreen(),
        '/complaints': (context) => const ComplaintFormScreen(),
        '/reviews': (context) => const ReviewScreen(),
        '/rewards': (context) => const RewardedShopsScreen(),
      },
    );
  }
}
