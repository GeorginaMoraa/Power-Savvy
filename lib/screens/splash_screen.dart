import 'dart:async';
// import 'package:flutter_svg/svg.dart';
// import 'package:stride/screens/Home/home_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async{
    var duration = const Duration(seconds: 4);
    return Timer(duration, navigationPage);
  }

  void navigationPage(){
    Navigator.of(context).pushReplacementNamed('/login');
  }
  @override
  void initState(){
    super.initState();
    startTime();
  }

  @override
Widget build(BuildContext context) {
  return const Scaffold(
    body: Center(
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         
          Text(
            'Welcome to Powersavy', // Replace with your desired text
            style: TextStyle(
              fontSize: 24, // Adjust font size
              fontWeight: FontWeight.bold, // Adjust font weight
              color: Colors.black, // Adjust text color
            ),
            textAlign: TextAlign.center, // Center align the text
          ),
          SizedBox(height: 20), // Optional spacing between elements
        ],
      ),
    ),
  );
}

}
