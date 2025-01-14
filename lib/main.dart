import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nyampah_app/screens/home/home_screen.dart';
import 'package:nyampah_app/screens/profile/profile_screen.dart';
import 'package:nyampah_app/screens/scan_image/scan_image_screen.dart';
import 'package:nyampah_app/screens/trash_tracking/trash_tracker_screen.dart';
import 'package:nyampah_app/screens/voucher/voucher_screen.dart';
import 'package:nyampah_app/screens/onboarding/onboarding_screen.dart';
import 'package:nyampah_app/theme/navbar.dart';
import 'package:nyampah_app/screens/map/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:nyampah_app/services/user_service.dart';

late List<CameraDescription> _cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class AppConfig {
  final baseURL = 'https://nyampah.my.id'; 
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
   static final GlobalKey<_MainNavigatorState> navigatorKey =
      GlobalKey<_MainNavigatorState>();

  MainNavigator({Key? key}) : super(key: navigatorKey);

  static void navigateTo(int index) {
    final state = MainNavigator.navigatorKey.currentState;
    if (state != null && state is _MainNavigatorState) {
      state._navigateToPage(index);
    }
  }

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
    MapScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadLastSelectedIndex();
  }

  Future<void> _loadLastSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('navbar_index') ?? 1;
    setState(() {
      _currentIndex = (savedIndex >= 0 && savedIndex < _pages.length)
          ? savedIndex
          : 1;
    });
  }

  Future<void> _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('navbar_index', index);
  }


  void _navigateToPage(int index) async {
    setState(() {
      _currentIndex = index;
    });
    await _saveSelectedIndex(index);
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
                setState(() {
                  _currentIndex = index;
                });
                await _saveSelectedIndex(index);

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token');

                  if (token != null) {
                    final userData = await UserService.getUserByName(token);
                    await prefs.setString('user', jsonEncode(userData));
                  } else {
                    throw Exception('Token not found');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to fetch user data: $e')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
