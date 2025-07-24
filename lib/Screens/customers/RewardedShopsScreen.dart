import 'package:flutter/material.dart';

class RewardedShopsScreen extends StatelessWidget {
  const RewardedShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loyalty Rewards")),
      body: const Center(child: Text("Your loyalty points & rewarded shops")),
    );
  }
}
