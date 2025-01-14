import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nyampah_app/screens/achievement/achievement_screen.dart';
import 'package:nyampah_app/screens/profile/edit_screen.dart';
import 'package:nyampah_app/screens/login/login_screen.dart';
import 'package:nyampah_app/services/user_service.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:nyampah_app/screens/map/map_screen.dart';
import 'package:nyampah_app/main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  String? token;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUserData();
    });
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    final userToken = prefs.getString('token');

    if (userData != null) {
      if (mounted) {
        setState(() {
          user = jsonDecode(userData);
          token = userToken;
        });
      }
    }
  }

  Future<void> reloadUserData() async {
    await loadUserData();
  }

  Future<void> refreshProfile() async {
    if (!mounted) return;
    
    setState(() {
      isRefreshing = true;
    });

    try {
      // Get fresh data from API
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        final userData = await UserService.getUserByName(token);
        if (userData != null) {
          prefs.setString('user', jsonEncode(userData));
          if (mounted) {
            setState(() {
              user = userData;
            });
          }
        }
      }
    } catch (e) {
      // Handle error
      print('Failed to refresh profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = AppConfig().baseURL;
    final size = MediaQuery.of(context).size;
    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(basePadding),
          child: Column(
            children: [
              Container(
                width: size.width,
                height: size.height * 0.15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: user?['profile_image'] != null
                                ? Image.network(
                                  '$baseUrl/storage/${user?['profile_image']}',
                                    width: constraints.maxWidth * 0.2,
                                    height: constraints.maxWidth * 0.2,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/placeholder_image.png',
                                        width: constraints.maxWidth * 0.2,
                                        height: constraints.maxWidth * 0.2,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/placeholder_image.png',
                                    width: constraints.maxWidth * 0.2,
                                    height: constraints.maxWidth * 0.2,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          SizedBox(width: constraints.maxWidth * 0.05),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth * 0.5,
                                child: Text(
                                  "${user?['name'] ?? 'Nama Pengguna'}",
                                  style: TextStyle(
                                      color: greenColor,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: constraints.maxWidth * 0.06),
                                ),
                              ),
                              SizedBox(
                                width: constraints.maxWidth * 0.5,
                                child: Text(
                                  "${user?['email'] ?? 'Email Pengguna'}",
                                  style: TextStyle(
                                      color: greenWithOpacity,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: constraints.maxWidth * 0.05),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const EditProfile(),
                                        ),
                                      );
                                      if (result == true) {
                                        await refreshProfile(); // Use the new refresh function
                                      }
                                    },
                                    child: Text(
                                      "Edit Profil",
                                      style: TextStyle(
                                          color: leaderBoardTitleColor,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              constraints.maxWidth * 0.05),
                                    ),
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.01),
                                  SvgPicture.asset(
                                    'assets/images/edit.svg',
                                    width: constraints.maxWidth * 0.04,
                                    height: constraints.maxWidth * 0.04,
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: basePadding),
              Container(
                width: size.width,
                height: size.height * 0.17,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SvgPicture.asset(
                                'assets/images/achievement_icon.svg',
                                width: constraints.maxWidth * 0.07,
                              ),
                              SizedBox(width: constraints.maxWidth * 0.03),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Peringkat dan Pencapaian',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        color: greenColor,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    'Semua voucher kamu ada di sini!',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: greenWithOpacity,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                              SizedBox(width: constraints.maxWidth * 0.25),
                                GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AchievementPage(),
                                        ),
                                      );
                                },
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: greenWithOpacity,
                                ),
                                )
                            ],
                          ),
                          Divider(
                            height: constraints.maxWidth * 0.05,
                            color: greenWithOpacity,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SvgPicture.asset(
                                'assets/images/trash_icon.svg',
                                width: constraints.maxWidth * 0.07,
                              ),
                              SizedBox(width: constraints.maxWidth * 0.03),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Track Sampah',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        color: greenColor,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    'data sampah yang udah kamu scan di sini!',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: greenWithOpacity,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                              SizedBox(width: constraints.maxWidth * 0.12),
                              GestureDetector(
                                onTap: () async {
                                  MainNavigator.navigateTo(4);
                                },
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: greenWithOpacity,
                                ),
                                )
                            ],
                          ),
                          Divider(
                            height: constraints.maxWidth * 0.05,
                            color: greenWithOpacity,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SvgPicture.asset(
                                'assets/images/map_icon.svg',
                                width: constraints.maxWidth * 0.07,
                              ),
                              SizedBox(width: constraints.maxWidth * 0.03),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tempat Pengolahan Sampah',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        color: greenColor,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    'Yuk cari tahu tempat pengolahan sampah terdekat!',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: greenWithOpacity,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                              SizedBox(width: constraints.maxWidth * 0.03),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MapScreen(),
                                        ),
                                      ); 
                                },
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: greenWithOpacity,
                                ),
                                )
                            ],
                          )
                          
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: size.height * 0.4),
                SizedBox(
                width: size.width,
                height: size.height * 0.06,
                child: ElevatedButton(
                  onPressed: () async {
                  bool? confirmLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: backgroundColor,
                      title: Text(
                      'Konfirmasi Keluar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: greenColor,
                      ),
                      ),
                      content: Text(
                      'Apakah Anda yakin ingin keluar?',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      ),
                      actions: [
                      TextButton(
                        onPressed: () {
                        Navigator.of(context).pop(false);
                        },
                        child: Text(
                        'Batal',
                        style: TextStyle(
                          color: greenColor,
                        ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                        Navigator.of(context).pop(true);
                        },
                        child: Text(
                        'Keluar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                        ),
                      ),
                      ],
                    );
                    },
                  );

                  if (confirmLogout == true) {
                    SharedPreferences sp = await SharedPreferences.getInstance();
                    sp.clear();

                    Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                    );
                  }
                  },
                  child: Text(
                  'Keluar',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: darkRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  ),
                ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void pushNavigate(BuildContext context) {}
}
