import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:powersavy/screens/widgets/button.dart';
import 'package:powersavy/screens/widgets/textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _profilePicController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Fetch current profile data
  Future<void> _fetchProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('access_token');
      if (jwt == null) {
        throw Exception('No JWT token found.');
      }

      final response = await http.get(
        Uri.parse('https://power-savvy-backend.onrender.com/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _nameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _profilePicController.text = data['profile_picture'] ?? '';
        });
      } else {
        throw Exception('Failed to load profile data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  // Update profile function
  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('access_token');
      if (jwt == null) {
        throw Exception('No JWT token found.');
      }

      final response = await http.put(
        Uri.parse('https://power-savvy-backend.onrender.com/api/auth/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'username': _nameController.text,
          'email': _emailController.text,
          'profile_picture': _profilePicController.text, // Optional
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['msg'])),
        );
        Navigator.pop(context, true); // Go back to the previous screen after successful update
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white
          ),
          ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  MyTextField(
                    controller: _nameController,
                    hintText: "name",
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _emailController,
                    hintText: "jd@mail.com",
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _profilePicController,
                    hintText: "https://image.com/#url",
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: _updateProfile,
                  //   child: const Text('Save Changes'),
                  // ),
                  Button(
                    onTap: _updateProfile, 
                    text: "Save Changes")
                ],
              ),
      ),
    );
  }
}
