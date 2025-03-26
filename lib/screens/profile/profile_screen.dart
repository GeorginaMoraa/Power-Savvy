import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:powersavy/screens/profile/editprofiile_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String? profilePicture;
  String? username;
  String? email;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

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
          profilePicture = data['profile_picture'];
          username = data['username'];
          email = data['email'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade900,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      // Profile picture
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profilePicture != null
                                ? NetworkImage(profilePicture!)
                                : const NetworkImage("https://placehold.co/600x400/png"),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Name and email
                      Text(
                        username ?? "Loading...",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email ?? "Loading...",
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Options
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profile details"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    // Navigate to the EditProfileScreen
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );

                    // If profile was updated, reload profile data
                    if (result == true) {
                      _fetchProfileData();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text("Push Notifications"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.inbox),
                  title: const Text("Inbox"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('access_token');
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
    );
  }
}

