import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:powersavy/screens/widgets/button.dart';
import 'package:powersavy/screens/widgets/textfield.dart';
import 'package:powersavy/screens/app_screen.dart'; 

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  // Method to send login request
    Future<void> _login(BuildContext context) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final Uri url = Uri.parse("https://power-savvy-backend.onrender.com/api/auth/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );


      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          
          if (responseData.containsKey("access_token")) {
            final String accessToken = responseData["access_token"];

            // Save the access token to shared preferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("access_token", accessToken);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login successful")),
            );

            // Navigate to the next screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AppScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid server response.")),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error parsing server response.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login to Powersavy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 45),
            MyTextField(
              controller: emailController,
              hintText: "johndoe@mail.com",
              obscureText: false,
            ),
            const SizedBox(height: 25),
            MyTextField(
              controller: passwordController,
              hintText: "password",
              obscureText: true,
            ),
            const SizedBox(height: 25),
            Button(
              onTap: () => _login(context), 
              text: "Sign In",
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
    );
  }
}
