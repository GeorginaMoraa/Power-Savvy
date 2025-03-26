import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<dynamic> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

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
      print('Error fetching rooms: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('access_token');
      if (jwt == null) {
        throw Exception('No JWT token found.');
      }
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
        await fetchDeviceCounts();
      } else {
        throw Exception('Failed to fetch rooms: ${response.body}');
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
      final response = await http.delete(
        Uri.parse('https://power-savvy-backend.onrender.com/api/room/rooms/$roomId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        // Remove the room from the local list
        setState(() {
          rooms.removeWhere((room) => room['_id'] == roomId);
        });
      } else {
        print('Failed to delete room: ${response.body}');
      }
    } catch (e) {
      print('Error deleting room: $e');
    }
  }

  Future<void> addNewRoom(BuildContext context) async {
    String? name = await _showRoomForm(context);
    if (name != null && name.isNotEmpty) {
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
          Uri.parse('https://power-savvy-backend.onrender.com/api/room/rooms'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'name': name, 'description': 'Description for $name'}),
        );

        if (response.statusCode == 201) {
          await fetchRooms();
        } else {
          print('Failed to add room: ${response.body}');
        }
      } catch (e) {
        print('Error adding room: $e');
      }
    }
  }

  Future<String?> _showRoomForm(BuildContext context) async {
    TextEditingController roomNameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Room'),
          content: TextField(
            controller: roomNameController,
            decoration: const InputDecoration(hintText: 'Room Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, roomNameController.text),
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchDeviceCounts() async {
  for (int i = 0; i < rooms.length; i++) {
    var roomId = rooms[i]['_id'];
    var deviceCount = await fetchDeviceCountForRoom(roomId);
    setState(() {
      rooms[i]['deviceCount'] = deviceCount; // Add device count to each room
    });
  }
}

  Future<int> fetchDeviceCountForRoom(String roomId) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('access_token');
    if (jwt == null) {
      throw Exception('No JWT token found.');
    }

    final response = await http.get(
      Uri.parse('https://power-savvy-backend.onrender.com/api/device/devices/room?roomId=$roomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      // Debugging: print the response body to check the structure
      print('Device Response Body: ${response.body}');

      var devices = jsonDecode(response.body);

      // Check if the devices list is empty or not
      print('Number of Devices: ${devices.length}');
      
      // Ensure that 'devices' is a list or array
      return devices is List ? devices.length : 0;
    } else {
      throw Exception('Failed to fetch devices count: ${response.body}');
    }
  } catch (e) {
    print('Error fetching device count: $e');
    return 0;  // Return 0 if there's an error fetching device count
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rooms',
          style: TextStyle(
            color: Colors.white
          ),
          ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchRooms,
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 8.0, // Space between columns
                  mainAxisSpacing: 8.0, // Space between rows
                  childAspectRatio: 1, // Aspect ratio of grid cells
                ),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final deviceCount = room['deviceCount'] ?? 0;
                  return GestureDetector(
                    onLongPress: () async {
                      // Show context menu on long press
                      await showMenu<String>(
                        context: context,
                        position: const RelativeRect.fromLTRB(200.0, 100.0, 0.0, 0.0),
                        items: [
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Room'),
                              ],
                            ),
                          ),
                        ],
                      ).then((value) {
                        if (value == 'delete') {
                          // Confirm deletion
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Room'),
                                content: const Text('Are you sure you want to delete this room?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      deleteRoom(room['_id']); // Delete the room
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: const Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('No'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });
                    },
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomDetailsScreen(room: room),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room['name'],
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                room['description'],
                                style: const TextStyle(fontSize: 14.0),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                '$deviceCount Devices',  // Display device count
                                style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewRoom(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RoomDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> room;

  const RoomDetailsScreen({super.key, required this.room});

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  List<dynamic> devices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDevices(widget.room['_id']); // Pass room ID to fetch devices
  }

  Future<void> fetchDevices(String roomId) async {
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
        Uri.parse('https://power-savvy-backend.onrender.com/api/device/devices/room?roomId=$roomId'),
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
      print('Error fetching devices: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.room['name'],
          style: const TextStyle(
            color: Colors.white
          ),
          ),
          backgroundColor: Colors.blue.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.room['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Devices in this Room:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      var device = devices[index];
                      return ListTile(
                        title: Text(device['name']),
                        subtitle: Text('Watts: ${device['watts']}\nStatus: ${device['status']}'), // Display device status
                        trailing: Icon(
                          device['status'] == 'active' ? Icons.check_circle : Icons.cancel,
                          color: device['status'] == 'on' ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
