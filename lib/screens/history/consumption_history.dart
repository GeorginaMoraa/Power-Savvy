import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class ConsumptionHistoryScreen extends StatefulWidget {
  const ConsumptionHistoryScreen({Key? key}) : super(key: key);

  @override
  _ConsumptionHistoryScreenState createState() =>
      _ConsumptionHistoryScreenState();
}

class _ConsumptionHistoryScreenState extends State<ConsumptionHistoryScreen>
    with SingleTickerProviderStateMixin {
  Map<DateTime, List<Map<String, dynamic>>> dailyConsumption = {};
  List<Map<String, dynamic>> monthlyConsumption = [];
  bool isLoadingDaily = true;
  bool isLoadingMonthly = true;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    print('Fetching daily and monthly consumption...');
    _tabController = TabController(length: 2, vsync: this);
    _fetchDailyConsumption(selectedDay);
    _fetchMonthlyConsumption();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDailyConsumption(DateTime selectedDate) async {
    try {
      // Fetch the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');  // Replace 'jwt_token' with your actual key

      if (token == null) {
        throw Exception("Token not found");
      }

      // Convert selectedDate to a string format 'YYYY-MM-DD'
      String formattedDate = "${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      // Make API call to fetch daily consumption with dynamic date
      final response = await http.get(
        Uri.parse('https://power-savvy-backend.onrender.com/api/device/devices/daily-consumption?date=$formattedDate'),
        headers: {
          'Authorization': 'Bearer $token',  // Add JWT token to headers
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        Map<DateTime, List<Map<String, dynamic>>> formattedData = {};

        // Process the data into the desired format
        for (var item in data) {
          DateTime date = DateTime.parse(item['date']);
          if (!formattedData.containsKey(date)) {
            formattedData[date] = [];
          }
          formattedData[date]?.add(item);
        }

        setState(() {
          dailyConsumption = formattedData;
          isLoadingDaily = false;
        });
      } else {
        throw Exception('Failed to load daily consumption');
      }
    } catch (e) {
      print('Error fetching daily consumption: $e');
      setState(() {
        isLoadingDaily = false;
      });
    }
  }

  Future<void> _fetchMonthlyConsumption() async {
    try {
      // Fetch the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');  // Replace 'jwt_token' with your actual key

      if (token == null) {
        throw Exception("Token not found");
      }

      // Format the selected month as 'YYYY-MM' (e.g., '2024-12')
      String formattedMonth = "${selectedDay.year.toString().padLeft(4, '0')}-${selectedDay.month.toString().padLeft(2, '0')}";

      // Make API call to fetch monthly consumption data
      final response = await http.get(
        Uri.parse('https://power-savvy-backend.onrender.com/api/device/devices/monthly-consumption?month=$formattedMonth'),
        headers: {
          'Authorization': 'Bearer $token',  // Add JWT token to headers
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          monthlyConsumption = List<Map<String, dynamic>>.from(data);
          isLoadingMonthly = false;
        });
      } else {
        throw Exception('Failed to load monthly consumption');
      }
    } catch (e) {
      print('Error fetching monthly consumption: $e');
      setState(() {
        isLoadingMonthly = false;
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return dailyConsumption[normalizedDay] ?? [];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consumption History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Set tab text color to white
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Daily Consumption Tab
          isLoadingDaily
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    TableCalendar(
                      focusedDay: focusedDay,
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      calendarFormat: CalendarFormat.month,
                      eventLoader: _getEventsForDay,
                      selectedDayPredicate: (day) => _isSameDay(selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          this.selectedDay = selectedDay;
                          this.focusedDay = focusedDay;
                        });
                        _fetchDailyConsumption(selectedDay); // Fetch daily consumption when day is selected
                      },
                      calendarStyle: const CalendarStyle(
                        markersMaxCount: 1,
                        markerDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: _getEventsForDay(selectedDay)
                            .map((event) => Card(
                                  child: ListTile(
                                    title: Text("Device Name: ${event['device_name']}"),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Consumption: ${event['consumption']} kWh"),
                                        Text("Room: ${event['room']}"),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),

          // Monthly Consumption Tab
          isLoadingMonthly
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: monthlyConsumption.length,
                  itemBuilder: (context, index) {
                    final monthData = monthlyConsumption[index];

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0), // Adds 8 pixels of padding from the top
                      child: Card(
                        child: ListTile(
                          title: Text("Month: ${monthData['month']}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total Consumption: ${monthData['total_consumption']} kWh"),
                              Text("Total Cost: KES ${monthData['total_cost']}"),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
