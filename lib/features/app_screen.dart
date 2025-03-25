import 'package:flutter/material.dart';
import 'package:techsavvy/features/dashboard/bill_estimation_screen.dart';
import 'package:techsavvy/features/dashboard/dashboard_screen.dart';

import 'package:iconsax/iconsax.dart';
import 'package:techsavvy/features/dashboard/device_screen.dart';
import 'package:techsavvy/features/dashboard/profile_screen.dart';
// import 'package:techsavvy/features/dashboard/devices_screen.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  var currentIndex = 0;

  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [DashboardScreen(), BillEstimationScreen(), DevicesScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        height: 70.0,
        elevation: 0,
        selectedIndex: currentIndex,
        onDestinationSelected: (index){
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const[
          NavigationDestination(icon: Icon(Iconsax.home), label: "Dashboard"),
          NavigationDestination(icon: Icon(Iconsax.candle), label: "Bill Estimate"),
          NavigationDestination(icon: Icon(Iconsax.devices), label: "Devices"),
          NavigationDestination(icon: Icon(Iconsax.user), label: "Profile")
        ],
      ),
    );
  }
}