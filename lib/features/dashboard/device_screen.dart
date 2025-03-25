import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<dynamic> devices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('https://power-savvy-backend.onrender.com/api/devices/devices'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          devices = data['devices'];
        });
      } else {
        print('Failed to fetch devices');
      }
    } catch (e) {
      print('Error fetching devices: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addDevice(String name, double powerRating, String status) async {
    try {
      final response = await http.post(
        Uri.parse('https://power-savvy-backend.onrender.com/api/devices/device'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "device_name": name,
          "power_rating": powerRating,
          "status": status,
        }),
      );
      if (response.statusCode == 201) {
        fetchDevices(); // Refresh the list
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device added successfully!')),
        );
      } else {
        print('Failed to add device');
      }
    } catch (e) {
      print('Error adding device: $e');
    }
  }
  Future<void> updateDeviceStatus(String deviceId, String newStatus) async {
  try {
    final response = await http.put(
      Uri.parse('https://power-savvy-backend.onrender.com/api/devices/device/$deviceId'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": newStatus}),
    );

    if (response.statusCode == 200) {
      fetchDevices(); // Refresh the device list after updating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Device status updated to $newStatus!')),
      );
    } else {
      print('Failed to update device status: ${response.body}');
    }
  } catch (e) {
    print('Error updating device status: $e');
  }
}


  void showAddDeviceDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController powerController = TextEditingController();
    String status = 'ON';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
              ),
              TextField(
                controller: powerController,
                decoration: const InputDecoration(labelText: 'Power Rating (W)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'ON', child: Text('ON')),
                  DropdownMenuItem(value: 'OFF', child: Text('OFF')),
                ],
                onChanged: (value) {
                  status = value!;
                },
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final powerRating = double.tryParse(powerController.text);
                if (name.isNotEmpty && powerRating != null) {
                  addDevice(name, powerRating, status);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
    
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,  // Set to zero for a rectangular button
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devices',
          style: TextStyle(
            color: Colors.white
          ),
          ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? const Center(child: Text('No devices available'))
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final currentStatus = device['status'];

                    return ListTile(
                      title: Text(device['device_name']),
                      subtitle: Text(
                        'Power Rating: ${device['power_rating']} W\nStatus: $currentStatus',
                      ),
                      trailing: Switch(
                        value: currentStatus == 'ON',
                        onChanged: (value) {
                          final newStatus = value ? 'ON' : 'OFF';
                          updateDeviceStatus(device['_id'], newStatus); // Use the method
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                    );
                  }

                ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDeviceDialog,
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.add),
      ),
    );
  }
}
