import 'package:flutter/material.dart';
import 'package:nitymulya/network/auth.dart';
import 'package:nitymulya/screens/auth/forgot_password_screen.dart';
import 'package:nitymulya/screens/auth/signup_screen.dart';
import 'package:nitymulya/screens/customers/main_customer_screen.dart';
import 'package:nitymulya/screens/shop_owner/dashboard_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_dashboard_screen.dart';
import 'package:nitymulya/screens/dncrp/dncrp_dashboard_screen.dart';
import 'package:nitymulya/utils/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'Customer';
  final List<String> roles = ['Customer', 'Shop Owner', 'Wholesaler', 'DNCRP-Admin'];

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Handle DNCRP-Admin login separately
      if (selectedRole == 'DNCRP-Admin') {
        // Check DNCRP demo credentials
        if (email == 'DNCRP_Demo@govt.com' && password == 'DNCRP_Demo') {
          setState(() {
            _isLoading = false;
          });

          // Save DNCRP admin session
          await UserSession.saveUserSession(
            userId: 'dncrp_admin_demo',
            userType: 'dncrp_admin',
            userData: {
              'id': 'dncrp_admin_demo',
              'name': 'DNCRP Admin Demo',
              'email': email,
              'role': 'dncrp_admin'
            },
            token: 'dncrp_demo_token',
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DNCRP Admin login successful')),
          );

          // Navigate to DNCRP Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DNCRPDashboardScreen(),
            ),
          );
          return;
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid DNCRP credentials'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Call backend login function for other roles
      final result = await loginUser(
        email: email,
        password: password,
        role: selectedRole,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        final userData = result['user'];
        final userName =
            userData?['full_name'] ?? userData?['name'] ?? email.split('@')[0];
        final userRole = result['role'] ?? selectedRole.toLowerCase();
        final userId = userData?['id']?.toString() ?? '';

        // Save user session
        await UserSession.saveUserSession(
          userId: userId,
          userType: userRole,
          userData: userData ?? {},
          token: result['token'],
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login successful')),
        );

        // Redirect based on role
        if (userRole.contains('customer') || selectedRole == 'Customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainCustomerScreen(
                userName: userName,
                userEmail: email,
                userRole: 'Customer',
              ),
            ),
          );
        } else if (userRole.contains('shop') || selectedRole == 'Shop Owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ShopOwnerDashboard(),
            ),
          );
        } else if (userRole.contains('wholesaler') ||
            selectedRole == 'Wholesaler') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WholesalerDashboardScreen(),
            ),
          );
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
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
                    borderRadius:
                        BorderRadius.circular(60), // Makes the image round
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
                      onPressed: _isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF079b11),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.white, // Text color
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
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
