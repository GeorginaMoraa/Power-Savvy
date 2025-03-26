import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http; // For making API calls

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await http.post(
          Uri.parse('https://power-savvy-backend.onrender.com/api/auth/register'), // Replace with your API endpoint
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 201) {
          // Navigate to the login screen or dashboard
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? 'Registration failed';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 12.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 12.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 12.0,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onTap: _registerUser,
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Already have an account? Log In'),
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
