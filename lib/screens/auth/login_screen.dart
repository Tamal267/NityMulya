import 'package:flutter/material.dart';
import 'package:nitymulya/screens/auth/forgot_password_screen.dart';
import 'package:nitymulya/screens/auth/signup_screen.dart';
import 'package:nitymulya/screens/customers/home_screen.dart';
import 'package:nitymulya/screens/shop_owner/dashboard_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'Customer';
  final List<String> roles = ['Customer', 'Shop Owner', 'Wholesaler'];

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // TODO: Add real authentication logic here
    // For now, we'll simulate a successful login
    
    // Extract user name from email (simple simulation)
    final userName = email.split('@')[0];
    
    // Redirect based on role
    if (selectedRole == 'Customer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: userName,
            userEmail: email,
            userRole: selectedRole,
          ),
        ),
      );
    } else if (selectedRole == 'Shop Owner') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ShopOwnerDashboard(),
        ),
      );
    } else if (selectedRole == 'Wholesaler') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WholesalerDashboardScreen(),
        ),
      );
    } else {
      // For any other roles, show coming soon message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$selectedRole dashboard coming soon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: const Color(0xFF079b11),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Go directly to HomeScreen
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo with rounded border
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60), // Makes the image round
                    child: Image.asset(
                      'assets/image/logo.jpeg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Select Role',
                      border: OutlineInputBorder(),
                    ),
                    items: roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email TextField
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password TextField
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF079b11),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.white, // Text color
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Forgot Password Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),

                  // Sign Up Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const SignupScreen()), // <-- Fixed class name
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
