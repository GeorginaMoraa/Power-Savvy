import 'package:flutter/material.dart';

class ElectricitySavingTipsScreen extends StatelessWidget {
  final List<Map<String, String>> tips = [
    {
      "title": "Use LED Bulbs",
      "description":
          "Replace incandescent bulbs with LED bulbs. They use up to 75% less energy and last much longer.",
    },
    {
      "title": "Turn Off Unused Devices",
      "description":
          "Always turn off appliances, lights, and devices when not in use to save electricity.",
    },
    {
      "title": "Optimize Your Fridge",
      "description":
          "Set your refrigerator to the recommended temperature and ensure the door seals are tight to avoid energy loss.",
    },
    {
      "title": "Unplug Idle Electronics",
      "description":
          "Unplug chargers and devices when not in use as they consume standby power.",
    },
    {
      "title": "Install Smart Thermostats",
      "description":
          "Smart thermostats help regulate heating and cooling efficiently, saving energy and money.",
    },
    {
      "title": "Use Natural Light",
      "description":
          "Take advantage of natural daylight during the day to reduce reliance on artificial lighting.",
    },
    {
      "title": "Wash with Cold Water",
      "description":
          "When using a washing machine, opt for cold water settings to save on heating costs.",
    },
    {
      "title": "Seal Air Leaks",
      "description":
          "Seal gaps around doors and windows to prevent air leaks that increase heating or cooling costs.",
    },
    {
      "title": "Install Solar Panels",
      "description":
          "Invest in solar panels to generate your own electricity and reduce dependence on the grid.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Electricity Saving Tips",
          style: TextStyle(
            color: Colors.white
          ),
          ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tips[index]['title']!,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    tips[index]['description']!,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
