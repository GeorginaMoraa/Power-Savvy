import 'package:flutter/material.dart';
import 'package:powersavy/screens/history/consumption_history.dart';
import 'package:powersavy/screens/savings/energy_saving_screen.dart';
import 'package:powersavy/screens/simulation/bill_simulation.dart';
import 'package:powersavy/screens/simulation/usage.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
      body: Stack(
        children: [
          // Black background with opacity
          Container(
            color: Colors.white, // Set the background color to black
          ),
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.yellow[700],
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 40, color: Colors.blue),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'to PowerSavy',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu buttons
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  children: [
                    DashboardButton(
                      icon: Icons.settings,
                      label: 'My Bill / Consumption',
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const UsageScreen(),
                          )
                        );
                      },
                    ),
                    DashboardButton(
                      icon: Icons.settings,
                      label: 'Consumption History',
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const ConsumptionHistoryScreen(),
                          )
                        );
                      },
                    ),
                    DashboardButton(
                      icon: Icons.attach_money,
                      label: 'Bill Simulation',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BillEstimationScreen(),
                          ),
                        );
                      },
                    ),
                    DashboardButton(
                      icon: Icons.calendar_today,
                      label: 'Tips on saving energy',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  ElectricitySavingTipsScreen(),
                          )
                        );
                      },
                    ),
                  
                  ],
                ),
              ),
              // Footer
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const DashboardButton({super.key, 
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900, // Button color
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
