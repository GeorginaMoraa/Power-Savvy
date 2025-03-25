import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  String _deviceName = '';
  double _powerRating = 0.0;
  String _status = 'on'; // Default status

  Future<void> _submitDevice() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('https://power-savvy-backend.onrender.com/api/devices/device'); // Replace with your API URL
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        "device_name": _deviceName,
        "power_rating": _powerRating,
        "status": _status,
      });

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device added successfully!')),
          );
          _formKey.currentState!.reset(); // Clear the form
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add device: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device Name Input
              TextFormField(
                decoration: const InputDecoration(labelText: 'Device Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the device name';
                  }
                  return null;
                },
                onSaved: (value) => _deviceName = value!,
              ),
              const SizedBox(height: 10),
              // Power Rating Input
              TextFormField(
                decoration: const InputDecoration(labelText: 'Power Rating (kWh)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the power rating';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _powerRating = double.parse(value!),
              ),
              const SizedBox(height: 10),
              // Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: const [
                   DropdownMenuItem(value: 'on', child: Text('On')),
                   DropdownMenuItem(value: 'off', child: Text('Off')),
                ],
                onChanged: (value) => setState(() => _status = value!),
                onSaved: (value) => _status = value!,
              ),
              const SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                onPressed: _submitDevice,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Full-width button
                ),
                child: const Text('Add Device'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
