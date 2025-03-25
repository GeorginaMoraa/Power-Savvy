import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double currentUsage = 0.0;
  double billEstimate = 0.0;

  @override
  void initState() {
    super.initState();
    fetchRealTimeData(); // Start the process to trigger real-time data update
  }

  // Trigger the real-time data update by calling the POST API
  Future<void> triggerRealTimeUpdate() async {
    final url = Uri.parse(
        'https://power-savvy-backend.onrender.com/api/report/update_realtime'); // Your actual endpoint

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print('Real-time data update triggered successfully.');
        fetchRealTimeData(); // Proceed to fetch real-time data after the update
      } else {
        print('Failed to trigger real-time data update');
        showSnackbar('Failed to trigger real-time data update: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error triggering real-time data update: $error');
      showSnackbar('Error: $error');
    }
  }

  // Fetch real-time consumption data from the backend
  Future<void> fetchRealTimeData() async {
    final url = Uri.parse(
        'https://power-savvy-backend.onrender.com/api/report/consumption/realtime'); // Your actual API URL
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentUsage = data['data']['current_usage'];
        });
        fetchBillEstimate();  // Call the bill estimate function after fetching usage data
      } else {
        print('Failed to load data');
        showSnackbar('Failed to fetch real-time data: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching real-time data: $error');
      showSnackbar('Error: $error');
    }
  }

  // Fetch the bill estimate from the backend
  Future<void> fetchBillEstimate() async {
    final url = Uri.parse(
        'https://power-savvy-backend.onrender.com/api/energy/estimate_bill'); // Your actual endpoint

    Map<String, dynamic> requestData = {
      'energy_usage': currentUsage, // Send current usage (in kWh)
    };

    try {
      final response = await http.post(
        url,
        body: json.encode(requestData),
        headers: {'Content-Type': 'application/json'},  // Ensure proper content type
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            billEstimate = data['data']['total']; // Use the total from the response
          });
        } else {
          showSnackbar('Failed to estimate bill: ${data['message']}');
        }
      } else {
        showSnackbar('Failed to fetch bill estimate: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching bill estimate: $error');
      showSnackbar('Error: $error');
    }
  }

  // Show a Snackbar message
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // List of general power-saving tips
  List<String> generalTips = [
    "Turn off unnecessary lights.",
    "Use energy-efficient appliances.",
    "Avoid overloading sockets.",
    "Unplug devices when not in use.",
  ];

  // Dynamic tips based on current usage
  List<String> getDynamicTips() {
    if (currentUsage < 20) {
      return [
        "Great job! Your energy consumption is efficient.",
        "Keep up the good work by continuing to monitor and conserve energy."
      ];
    } else {
      return [
        "Your consumption is higher than 20 kWh. Here are some tips:",
        "Use appliances like washing machines and dishwashers during off-peak hours.",
        "Turn off devices completely instead of leaving them on standby.",
        "Consider using a smart thermostat to optimize cooling or heating.",
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-Time Consumption:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Usage',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${currentUsage.toStringAsFixed(2)} kW',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: currentUsage < 20 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Bill Estimate
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bill Estimate:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'KSh ${billEstimate.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                triggerRealTimeUpdate();  // Trigger real-time update and then refresh data
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full-width button
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,  // Set to zero for a rectangular button
                ),
              ),
              child: const Text('Update and Refresh Data'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Tips Based on your Usage:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            ...getDynamicTips().map((tip) {
              return ListTile(
                leading: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                ),
                title: Text(tip),
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'General Power-Saving Tips:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            ...generalTips.map((tip) {
              return ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(tip),
              );
            }),
          ],
        ),
      ),
    );
  }
}
