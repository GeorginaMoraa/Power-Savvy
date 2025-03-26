import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<dynamic> rooms = [];
  List<dynamic> devices = [];
  String? selectedRoom;
  String? selectedStatus = 'off'; // Default status
  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController deviceWattsController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms();
    fetchDevices();
  }

  // Fetch rooms to populate the dropdown
  Future<void> fetchRooms() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('access_token');
      if (jwt == null) {
        throw Exception('No JWT token found.');
      }

      final response = await http.get(
        Uri.parse('https://power-savvy-backend.onrender.com/api/room/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          rooms = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch rooms: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch devices to display in the list
  Future<void> fetchDevices() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('access_token');
      if (jwt == null) {
        throw Exception('No JWT token found.');
      }

      final response = await http.get(
        Uri.parse('https://power-savvy-backend.onrender.com/api/device/devices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          devices = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch devices: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Add device with selected room and status
  Future<void> addDevice() async {
    if (deviceNameController.text.isNotEmpty &&
        deviceWattsController.text.isNotEmpty &&
        selectedRoom != null &&
        selectedStatus != null) {
      setState(() {
        isLoading = true;
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? jwt = prefs.getString('access_token');
        if (jwt == null) {
          throw Exception('No JWT token found.');
        }

        final response = await http.post(
          Uri.parse('https://power-savvy-backend.onrender.com/api/device/devices'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({
            'name': deviceNameController.text,
            'watts': deviceWattsController.text,
            'roomId': selectedRoom,
            'status': selectedStatus,  // Include status in the request body
          }),
        );

        if (response.statusCode == 201) {
          deviceNameController.clear();
          deviceWattsController.clear();
          setState(() {
            selectedRoom = null;
            selectedStatus = 'off';  // Reset status after adding
            isLoading = false;
          });
          fetchDevices();  // Refresh the device list
        } else {
          throw Exception('Failed to add device: ${response.body}');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
    }
  }

  // Update the status of the selected device
Future<void> updateDeviceStatus(String deviceId, String newStatus) async {
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
      Uri.parse('https://power-savvy-backend.onrender.com/api/device/devices/status'), // Update with the correct endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({
        'device_id': deviceId,
        'status': newStatus,
      }),
    );

    if (response.statusCode == 200) {
      fetchDevices(); // Refresh device list after update
    } else {
      throw Exception('Failed to update device status: ${response.body}');
    }
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

// Helper function to convert "HH:mm:ss" to total hours as a double
double parseTimeToHours(String time) {
  try {
    List<String> parts = time.split(":");
    if (parts.length == 3) {
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      int seconds = int.parse(parts[2]);

      // Convert to total hours
      return hours + (minutes / 60) + (seconds / 3600);
    }
  } catch (e) {
    print('Error parsing time: $e');
  }
  return 0; // Return 0 if parsing fails
}

Future<void> fetchOnDurationSummary(String deviceId) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('access_token');
    if (jwt == null) {
      throw Exception('No JWT token found.');
    }

    // Construct the API URL
    String apiUrl =
        'https://power-savvy-backend.onrender.com/api/device/devices/$deviceId/on-duration-summary';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (!mounted) return;

      // Extract relevant data
      var dailyOnDuration = data["daily_on_duration"] ?? "0:00:00";
      var weeklyOnDuration = data["weekly_on_duration"] ?? "0";
      var monthlyOnDuration = data["monthly_on_duration"] ?? "0";
      var dailyTag = data["daily_tag"] ?? "Not available";

      // Convert daily duration to hours for comparison
      double dailyHours = parseTimeToHours(dailyOnDuration);

      // Generate Recommendations
      List<String> recommendations = [];
      if (dailyHours > 2) {
        recommendations.add(
            "The device has been on for more than 2 hours today. Consider turning it off to save energy.");
      }

      // Show data and recommendations in a dialog
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'On-Duration Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: $dailyTag'),
                          const SizedBox(height: 8),
                          Text('Daily Duration: $dailyOnDuration'),
                          Text('Weekly Duration: $weeklyOnDuration hrs'),
                          Text('Monthly Duration: $monthlyOnDuration hrs'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (recommendations.isNotEmpty)
                    Card(
                      elevation: 3,
                      color: Colors.yellow[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommendations',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...recommendations.map(
                              (rec) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      rec,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      throw Exception('Failed to fetch summary: ${response.body}');
    }
  } catch (e) {
    print('Error fetching on-duration summary: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}



// Delete the selected device
Future<void> deleteDevice(String deviceId) async {
  setState(() {
    isLoading = true;
  });

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('access_token');
    if (jwt == null) {
      throw Exception('No JWT token found.');
    }

    final response = await http.delete(
      Uri.parse('https://power-savvy-backend.onrender.com/api/device/devices/$deviceId'), // Make sure to update the endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      fetchDevices(); // Refresh the device list after deletion
    } else {
      throw Exception('Failed to delete device: ${response.body}');
    }
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}




  // Show dialog to add a new device
  void showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                ),
              ),
              TextField(
                controller: deviceWattsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Device Watts/Voltage',
                ),
              ),
              DropdownButton<String>(
                value: selectedRoom,
                hint: const Text('Select Room'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRoom = newValue;
                  });
                },
                items: rooms.isEmpty
                    ? [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('No rooms available'),
                        )
                      ]
                    : rooms.map<DropdownMenuItem<String>>((room) {
                        return DropdownMenuItem<String>(
                          value: room['_id'].toString(), // Ensure this matches the room ID
                          child: Text(room['name']),
                        );
                      }).toList(),
              ),
              DropdownButton<String>(
                value: selectedStatus,
                hint: const Text('Select Status'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue;
                  });
                },
                items: const [
                  DropdownMenuItem<String>(
                    value: 'on',
                    child: Text('On'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'off',
                    child: Text('Off'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                addDevice();
                Navigator.pop(context);
              },
              child: const Text('Add Device'),
            ),
          ],
        );
      },
    );
  }

  void showEditDeviceDialog(
  String deviceId, 
  String currentName, 
  String currentWatts, 
  String currentRoomId, 
  String currentStatus, 
) {
  // Create text controllers with initial values
  TextEditingController editDeviceNameController = TextEditingController(text: currentName);
  TextEditingController editWattsController = TextEditingController(text: currentWatts);
  TextEditingController editRoomIdController = TextEditingController(text: currentRoomId);

  String selectedStatus = currentStatus; // Set the initial status to currentStatus

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Device Name Field
            TextField(
              controller: editDeviceNameController,
              decoration: const InputDecoration(
                labelText: 'Device Name',
              ),
            ),
            const SizedBox(height: 10),

            // Watts Field
            TextField(
              controller: editWattsController,
              decoration: const InputDecoration(
                labelText: 'Watts',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            // Room ID Field
            TextField(
              controller: editRoomIdController,
              decoration: const InputDecoration(
                labelText: 'Room ID',
              ),
            ),
            const SizedBox(height: 10),

            // Status Field (Dropdown or TextField)
            DropdownButton<String>(
              value: selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
              items: <String>['on', 'off']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String newName = editDeviceNameController.text;
              String newWatts = editWattsController.text;
              String newRoomId = editRoomIdController.text;
              String newStatus = selectedStatus;

              if (newName.isNotEmpty && newWatts.isNotEmpty && newRoomId.isNotEmpty) {
                // Call update function with new details
                updateDeviceDetails(deviceId, newName, newWatts, newRoomId, newStatus);
                Navigator.pop(context); // Close the dialog
              } else {
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<void> updateDeviceDetails(
  String deviceId, 
  String newName, 
  String newWatts, 
  String newRoomId, 
  String newStatus
) async {
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
      Uri.parse('https://power-savvy-backend.onrender.com/api/device/devices/$deviceId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({
        'name': newName,      // Send the new device name
        'watts': newWatts,    // Send the new watts value
        'room_id': newRoomId, // Send the new room ID
        'status': newStatus,  // Send the new status
      }),
    );

    if (response.statusCode == 200) {
      fetchDevices();  // Refresh the device list after the update
    } else {
      throw Exception('Failed to update device details: ${response.body}');
    }
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
          'Devices',
          style: TextStyle(
            color: Colors.white
          ),
          ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchDevices,  // Trigger fetchDevices when pulled down
              child: ListView.builder(
  itemCount: devices.length,
  itemBuilder: (context, index) {
    var device = devices[index];
    var room = rooms.firstWhere(
      (room) => room['_id'] == device['room_id'],
      orElse: () => {'name': 'Unknown Room'}, // Default value if not found
    );

    return GestureDetector(
     onTap: () async{
  print("Bottom sheet invoked");
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      print("Bottom sheet displayed");
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: const Text('View on Duration Summmary'),
              onTap: (){
                
                fetchOnDurationSummary(
                  device['_id']
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Device'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                // Show the edit dialog
                showEditDeviceDialog(
                  device['_id'],              // Pass device ID
                  device['name'],             // Pass device name
                  device['watts'].toString(), // Pass watts
                  device['room_id'],          // Pass room ID
                  device['status'],           // Pass status
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Device'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Device'),
                      content: const Text('Are you sure you want to delete this device?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteDevice(device['_id'].toString());
                            Navigator.pop(context); // Close the dialog
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    },
  );
},

      child: ListTile(
        title: Text(device['name']),
        subtitle: Text('Watts: ${device['watts']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Room: ${room['name']}'),
            const SizedBox(width: 10),
            Text('Status: ${device['status']}'),
            IconButton(
              icon: Icon(
                device['status'] == 'on' ? Icons.power_settings_new : Icons.power_off,
                color: device['status'] == 'on' ? Colors.green : Colors.red,
              ),
              onPressed: () {
                String newStatus = device['status'] == 'on' ? 'off' : 'on';
                updateDeviceStatus(device['_id'].toString(), newStatus);
              },
            ),
          ],
        ),
      ),
    );
  
  },
)

            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDeviceDialog, // Open the dialog to add device
        child: const Icon(Icons.add),
      ),
    );
  }
}
