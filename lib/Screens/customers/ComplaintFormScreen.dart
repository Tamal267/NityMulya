import 'package:flutter/material.dart';

class ComplaintFormScreen extends StatelessWidget {
  const ComplaintFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Complaint")),
      body: const Center(child: Text("Complaint form UI")),
    );
  }
}
