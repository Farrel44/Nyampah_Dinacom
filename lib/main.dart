import 'package:flutter/material.dart';
import 'package:nyampah_app/screens/home/home_screen.dart';
import 'package:nyampah_app/screens/home/profile_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProfilePage(),
    );
  }
}
