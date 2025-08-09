import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nitymulya/network/auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String selectedRole = 'Customer';

  final _formKey = GlobalKey<FormState>();
  
  // Customer form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  Position? currentLocation;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required for signup')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is permanently denied. Please enable it from settings.')),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        currentLocation = position;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location captured successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  // Validate customer signup form
  bool validateCustomerForm() {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return false;
    }
    
    if (_emailController.text.trim().isEmpty || 
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return false;
    }
    
    if (_contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your contact number')),
      );
      return false;
    }
    
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return false;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return false;
    }

    if (currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture your location by tapping the location icon')),
      );
      return false;
    }
    
    return true;
  }

  // Perform customer signup
  Future<void> performSignup() async {
    if (!validateCustomerForm()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await signupCustomer(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        contact: _contactController.text.trim(),
        password: _passwordController.text,
        latitude: currentLocation!.latitude,
        longitude: currentLocation!.longitude,
        address: _addressController.text.trim().isEmpty ? '' : _addressController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );

      if (result['success']) {
        // Navigate back to login screen on successful signup
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget getFieldsForRole() {
    switch (selectedRole) {
      case 'Customer':
        return Column(
          children: [
            _textField("Full Name", _fullNameController),
            _textField("Email", _emailController),
            _textField("Contact", _contactController),
            _textFieldWithLocation("Address", getCurrentLocation, _addressController),
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
            _textFieldWithLocation("Organization Address", getCurrentLocation),
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
            _textFieldWithLocation("Shop Address", getCurrentLocation),
            _textField("Shop Description"),
            _textField("Shop Image URL"),
            _passwordFields(),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _textField(String label, [TextEditingController? controller]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _textFieldWithLocation(String label, VoidCallback onTap, [TextEditingController? controller]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.location_on, 
              color: currentLocation != null ? Colors.green : Colors.grey,
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _passwordFields() {
    return Column(
      children: [
        _textField("Password", _passwordController),
        _textField("Confirm Password", _confirmPasswordController),
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

                    // Signup Button
                    ElevatedButton(
                      onPressed: isLoading ? null : () {
                        if (selectedRole == 'Customer') {
                          performSignup();
                        } else {
                          // For other roles, show message that they're not implemented yet
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$selectedRole signup not implemented yet')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF079b11),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up"),
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
