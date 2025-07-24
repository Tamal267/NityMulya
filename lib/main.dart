import 'package:flutter/material.dart';
import 'package:nitymulya/screens/customers/ComplaintFormScreen.dart';
import 'package:nitymulya/screens/customers/FavoriteProductsScreen.dart';
import 'package:nitymulya/screens/customers/HomeScreen.dart';
import 'package:nitymulya/screens/customers/PriceAlertScreen.dart';
import 'package:nitymulya/screens/customers/ReviewScreen.dart';
import 'package:nitymulya/screens/customers/RewardedShopsScreen.dart';
import 'package:nitymulya/screens/auth/login_screen.dart';

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
