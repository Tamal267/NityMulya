import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Enter your email to receive reset instructions.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Send OTP")),
          ],
        ),
      ),
    );
  }
}
