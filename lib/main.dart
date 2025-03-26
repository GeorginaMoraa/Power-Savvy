import 'package:flutter/material.dart';
import 'package:powersavy/screens/login/login_screen.dart';
import 'package:powersavy/screens/signup/signup_screen.dart';
import 'package:powersavy/screens/splash_screen.dart';

Future main() async {
  //environment variables
  // await dotenv.load(fileName: ".env");

  // run application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: <String,WidgetBuilder>{
        '/register' : (BuildContext context) => const RegisterScreen(),
        '/login':(BuildContext context) =>  LoginScreen()
      },
    );
  }
}
