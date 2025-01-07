import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nyampah_app/screens/home/edit_screen.dart';
import 'package:nyampah_app/screens/home/home_screen.dart';
import 'package:nyampah_app/screens/home/profile_screen.dart';
import 'package:nyampah_app/screens/home/scan_image_screen.dart';
import 'package:nyampah_app/screens/home/trash_tracker_screen.dart';
import 'package:nyampah_app/screens/home/voucher_screen.dart';
import 'package:nyampah_app/screens/login/login_screen.dart';
import 'package:nyampah_app/screens/onboarding/onboarding_screen.dart';
import 'package:nyampah_app/theme/navbar.dart';

late List<CameraDescription> _cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    const VoucherPage(),
    const HomeScreen(),
    const ScanImage(),
    const ProfilePage(),
    const TrashHistory(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: _pages[_currentIndex],
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: FloatingBottomNav(
              selectedIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
