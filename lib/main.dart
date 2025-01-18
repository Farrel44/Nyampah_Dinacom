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
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
      home: OnboardingScreen(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  static final GlobalKey<_MainNavigatorState> navigatorKey = GlobalKey<_MainNavigatorState>();

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
  final GlobalKey _voucherKey = GlobalKey();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _scanKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _trashKey = GlobalKey();
  final GlobalKey _achievementKey = GlobalKey();

  int _currentIndex = 1;

  List<Widget> _pages = [];

  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    _loadLastSelectedIndex();
    _createTargets();
    _showTutorialOnce();

    _pages = [
      const VoucherPage(),
      HomeScreen(achievementKey: _achievementKey), // Pass the key to HomeScreen here
      const ScanImage(),
      const ProfilePage(),
      const TrashHistory(),
      MapScreen(),
    ];
  }

  // dibawah ini kalo udh prod buat ngeliatin tutorial sekali aja
  Future<void> _showTutorialOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownTutorial = prefs.getBool('hasShownTutorial') ?? false;

    if (!hasShownTutorial) {
      _showTutorial();
      await prefs.setBool('hasShownTutorial', true);
    }
  }

  // dibawah ini kalo lagi dev buat ngeliatin tutorial tiap kali buka

  /* Future<void> _showTutorialOnce() async {
    final prefs = await SharedPreferences.getInstance();
    // final hasShownTutorial = prefs.getBool('hasShownTutorial') ?? false;
    final hasShownTutorial = false;

    if (!hasShownTutorial) {
      _showTutorial();
      await prefs.setBool('hasShownTutorial', true);
    }
  } */


  void _showTutorial() {
    final tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: 'SKIP TUTORIAL',
      onFinish: () {
        // After navbar tutorial finishes, show achievement tutorial
        _showAchievementTutorial();
      },
      onSkip: () {
        // Optionally, you can also show achievement tutorial if skipped
        _showAchievementTutorial();
        return true;
      },
    );

    tutorialCoachMark.show(context: context);
  }

  void _showAchievementTutorial() {
  final achievementTutorial = TutorialCoachMark(
    targets: [
      TargetFocus(
        identify: 'achievement',
        keyTarget: _achievementKey,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            builder: (context, controller) => Align(
              alignment: Alignment.bottomCenter, // This will align the text to the bottom
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Ga cuman pindai-pindai sampah doang. Kamu juga bisa dapetin peringkat dan pencapaian. Yuk cek di sini!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ],
      ),
    ],
    colorShadow: Colors.black.withOpacity(0.8),
    textSkip: "SKIP",
    onFinish: () {},
    onSkip: () {
      return true;
    },
  );

  // Show the achievement tutorial
  achievementTutorial.show(context: context);
}


  void _createTargets() {
    targets = [
      TargetFocus(
        identify: 'home',
        keyTarget: _homeKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'Ini nih halaman beranda kamu!',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'scan',
        keyTarget: _scanKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'Kalo nemu sampah, langsung aja klik tombol ini! ',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'profile',
        keyTarget: _profileKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'Kalo mau lihat profil, di sini ya',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'voucher',
        keyTarget: _voucherKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'Udah dapet banyak poin? Gas tukerin di sini! ',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'trash',
        keyTarget: _trashKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'Kalo mau lihat data sampah yang udah kamu pindai, masuknya ke sini ya',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    ];
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

  

    GlobalKey? _getKeyForIndex(int index) {
    switch (index) {
      case 0:
        return _voucherKey;
      case 1:
        return _homeKey;
      case 2:
        return _scanKey;
      case 3:
        return _profileKey;
      case 4:
        return _trashKey;
      default:
        return null;
    }
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
              voucherKey: _voucherKey,
              homeKey: _homeKey,
              scanKey: _scanKey,
              profileKey: _profileKey,
              trashKey: _trashKey,
            ),
          ),
        ],
      ),
    );
  }
}

