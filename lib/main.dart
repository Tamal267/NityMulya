import 'package:flutter/material.dart';
import 'package:nitymulya/screens/customers/ComplaintFormScreen.dart';
import 'package:nitymulya/screens/customers/FavoriteProductsScreen.dart';
import 'package:nitymulya/screens/customers/HomeScreen.dart';
import 'package:nitymulya/screens/customers/PriceAlertScreen.dart';
import 'package:nitymulya/screens/customers/ReviewScreen.dart';
import 'package:nitymulya/screens/customers/RewardedShopsScreen.dart';


void main() {
  runApp(NitiMulyaApp());
}

class NitiMulyaApp extends StatelessWidget {
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
        '/': (context) => HomeScreen(),
        '/favorites': (context) => FavoriteProductsScreen(),
        '/alerts': (context) => PriceAlertScreen(),
        '/complaints': (context) => ComplaintFormScreen(),
        '/reviews': (context) => ReviewScreen(),
        '/rewards': (context) => RewardedShopsScreen(),
      },
    );
  }
}
