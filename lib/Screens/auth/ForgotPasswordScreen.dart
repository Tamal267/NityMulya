import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Enter your email to receive reset instructions.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Send OTP")),
          ],
        ),
      ),
    );
  }
}
