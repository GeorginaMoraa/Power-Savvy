import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white
          ),
          ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            const Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/images/profile_pic.jpg'), // Replace with your image
              ),
            ),
            const SizedBox(height: 20),
            // Name and Email
            const Center(
              child: Column(
                children: [
                  Text(
                    'John Doe', // Name
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'johndoe@example.com', // Email
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile Options
            const Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            _buildProfileOption(
              icon: Icons.lock,
              text: 'Change Password',
              onPressed: () {
                // Navigate to Change Password screen or show dialog
              },
            ),
            _buildProfileOption(
              icon: Icons.email,
              text: 'Update Email',
              onPressed: () {
                // Navigate to Update Email screen or show dialog
              },
            ),
            _buildProfileOption(
              icon: Icons.phone,
              text: 'Update Phone Number',
              onPressed: () {
                // Navigate to Update Phone Number screen or show dialog
              },
            ),
            _buildProfileOption(
              icon: Icons.notifications,
              text: 'Notification Preferences',
              onPressed: () {
                // Navigate to Notification Preferences screen
              },
            ),
            const SizedBox(height: 20),

            // Log out button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Log out functionality
                },
                child: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Full-width button
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Rectangle button
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom widget for Profile Option Items
  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue.shade900,
        ),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onPressed,
      ),
    );
  }
}
