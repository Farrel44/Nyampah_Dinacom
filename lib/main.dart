import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nyampah_app/screens/home/home_screen.dart';
import 'package:nyampah_app/screens/home/profile_screen.dart';
import 'package:nyampah_app/screens/home/scan_image_screen.dart';
import 'package:nyampah_app/screens/home/trash_tracker_screen.dart';
import 'package:nyampah_app/screens/home/voucher_screen.dart';
import 'package:nyampah_app/screens/onboarding/onboarding_screen.dart';
import 'package:nyampah_app/theme/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _currentIndex = 2;

  final List<Widget> _pages = [
    const VoucherPage(),
    const HomeScreen(),
    const ScanImage(),
    const ProfilePage(),
    const TrashHistory(),
  ];

  @override
  void initState() {
    super.initState();
    _loadLastSelectedIndex();
  }

  // Load the last selected index from SharedPreferences
  Future<void> _loadLastSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentIndex = prefs.getInt('navbar_index') ?? 2; // Default to index 2
    });
  }

  // Save the selected index to SharedPreferences
  Future<void> _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('navbar_index', index);
  }

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
              onTap: (index) async {
                // Update state and save to SharedPreferences
                setState(() {
                  _currentIndex = index;
                });
                await _saveSelectedIndex(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
