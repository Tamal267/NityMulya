import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String selectedRole = 'Customer';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  bool otpSent = false;

  void sendOTP() {
    setState(() {
      otpSent = true;
    });
    // TODO: Use actual email OTP logic with backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to your email')),
    );
  }

  void selectLocation() {
    // TODO: Open map picker here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Map picker to be integrated')),
    );
  }

  Widget getFieldsForRole() {
    switch (selectedRole) {
      case 'Customer':
        return Column(
          children: [
            _textField("Full Name"),
            _textField("Email"),
            _textField("Contact"),
            _textFieldWithLocation("Address", selectLocation),
            _passwordFields(),
          ],
        );
      case 'Wholesaler':
        return Column(
          children: [
            _textField("Name"),
            _textField("Email"),
            _textField("Contact"),
            _textField("Organization Name"),
            _textFieldWithLocation("Organization Address", selectLocation),
            _textField("Organization Logo URL"),
            _passwordFields(),
          ],
        );
      case 'Shop Owner':
        return Column(
          children: [
            _textField("Name"),
            _textField("Email"),
            _textField("Contact"),
            _textField("Shop Name"),
            _textFieldWithLocation("Shop Address", selectLocation),
            _textField("Shop Description"),
            _textField("Shop Image URL"),
            _passwordFields(),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _textField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _textFieldWithLocation(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.green),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _passwordFields() {
    return Column(
      children: [
        _textField("Password"),
        _textField("Confirm Password"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf2f2f2),
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color(0xFF079b11),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            color: const Color(0xFFE8F5E9), // Light green tint
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo with rounded border
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/image/logo.jpeg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Role Selection
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF079b11),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        dropdownColor: Colors.green[50],
                        decoration:
                            const InputDecoration.collapsed(hintText: ''),
                        items: ['Customer', 'Wholesaler', 'Shop Owner']
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dynamic Fields
                    getFieldsForRole(),

                    const SizedBox(height: 20),

                    // OTP Section
                    if (!otpSent)
                      ElevatedButton(
                        onPressed: sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF079b11),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Send OTP"),
                      )
                    else
                      Column(
                        children: [
                          TextFormField(
                            controller: _otpController,
                            decoration: const InputDecoration(
                              labelText: "Enter OTP",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // After sign up → login screen
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF079b11),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text("Verify & Sign Up"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
