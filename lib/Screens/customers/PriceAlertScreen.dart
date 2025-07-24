import 'package:flutter/material.dart';

class PriceAlertScreen extends StatelessWidget {
  const PriceAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Price Alerts")),
      body: const Center(child: Text("Price alert subscriptions")),
    );
  }
}
