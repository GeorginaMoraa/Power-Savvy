import 'package:flutter/material.dart';
import 'package:techsavvy/features/app_screen.dart';
import 'package:techsavvy/features/dashboard/bill_estimation_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart'; 
import 'features/auth/register_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Savvy',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/billestimate': (context) => const BillEstimationScreen(),
        '/appscreen': (context) => const AppScreen()
        // '/dashboard': (context) => Scaffold(
        //   body: Center(child: Text('Dashboard Placeholder')),
        // ), // Replace with your actual DashboardScreen
      },
    );
  }
}
