import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://power-savvy-backend.onrender.com";

  // Login user
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse("$baseUrl/api/auth/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {"success": false, "message": jsonDecode(response.body)['msg']};
    }
  }

  // Sign up User
  static Future<Map<String, dynamic>> registerUser(String email, String password, String username) async {
    final url = Uri.parse("$baseUrl/api/auth/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "username": username,
      }),
    );

    if (response.statusCode == 201) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {"success": false, "message": jsonDecode(response.body)['msg']};
    }
  }

  //Estimate Bill
  static Future<Map<String, dynamic>> estimateBill(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/api/energy/estimate_bill');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to estimate bill. Please try again.',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'An error occurred: $error',
      };
    }
  }

  static Future<Map<String, dynamic>> submitDevice(String deviceName, double powerRating, String status) async {
    final url = Uri.parse("$baseUrl/api/devices/device");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "device_name": deviceName,
        "power_rating": powerRating,
        "status": status
      }),
    );

    if (response.statusCode == 201){
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {"success": false, "message": jsonDecode(response.body)['msg']};
    }
  }

}