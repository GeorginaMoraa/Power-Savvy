import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:powersavy/screens/dashboard/dashboard_screen.dart';
import 'package:powersavy/screens/devices/devices_screen.dart';
import 'package:powersavy/screens/profile/profile_screen.dart';
import 'package:powersavy/screens/rooms/rooms_screen.dart';

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
        children: const[DashboardScreen(), RoomsScreen(), DevicesScreen(), ProfileSettingsScreen()],
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
          NavigationDestination(icon: Icon(Iconsax.safe_home), label: "Dashboard"),
          NavigationDestination(icon: Icon(Iconsax.building), label: "Rooms"),
          NavigationDestination(icon: Icon(Iconsax.lamp), label: "Devices"),
          NavigationDestination(icon: Icon(Iconsax.user), label: "Profile")
        ],
      ),
    );
  }
}