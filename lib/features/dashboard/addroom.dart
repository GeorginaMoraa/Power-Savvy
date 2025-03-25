import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateRoomScreen extends StatefulWidget {
  final String houseId; // Pass the house ID from the parent screen
  const CreateRoomScreen({Key? key, required this.houseId}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _createRoom() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final url = Uri.parse('https://your-api.com/api/rooms');
      final token = "your_jwt_token"; // Replace with your stored JWT token logic

      final body = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'house_id': widget.houseId,
      };

      try {
        final response = await http.post(
          url,
          body: json.encode(body),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 201) {
          // Parse response
          final data = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Room Created: ${data['msg']}')),
          );
          Navigator.pop(context); // Go back to the previous screen
        } else {
          // Handle error
          final error = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error['msg']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
      appBar: AppBar(
        title: const Text('Create Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Room Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter room name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Room name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Room Description (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter room description',
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createRoom,
                  child: const Text('Create Room'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
