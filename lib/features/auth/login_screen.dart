import 'package:flutter/material.dart';


import '../../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await ApiService.loginUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (response['success']) {
          // Navigate to the dashboard or home screen
          Navigator.pushReplacementNamed(context, '/appscreen');
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'An error occurred';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again later.';
        });
      } finally {
        setState(() {
          _isLoading = false; // Stop loading in all cases
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Prevent overflow by making the content scrollable
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue
                            )
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, // Adjust vertical padding
                          horizontal: 12.0, // Adjust horizontal padding
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
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
                          borderSide: BorderSide(
                              color: Colors.black
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue
                            )
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
                            onTap: _loginUser,
                            child: Container(
                              padding: const EdgeInsets.all(25),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "Login",
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
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: const Text('Need an account? Sign Up'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}