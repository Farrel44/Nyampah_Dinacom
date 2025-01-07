import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyampah_app/theme/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? user;
  String? token;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    final userToken = prefs.getString('token');

    if (userData != null) {
      setState(() {
        user = jsonDecode(userData);
        token = userToken;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final double welcomeTextSize =
                    (constraints.maxWidth * 0.045).clamp(16.0, 18.0);
                final double usernameTextSize =
                    (constraints.maxWidth * 0.07).clamp(24.0, 28.0);
                final double profileImageSize =
                    (constraints.maxWidth * 0.18).clamp(60.0, 70.0);

                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(basePadding),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome Back',
                                      style: TextStyle(
                                        color: greenWithOpacity,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: welcomeTextSize,
                                      ),
                                    ),
                                    Text(
                                      '${user?['name'] ?? 'User'}!',
                                      style: TextStyle(
                                        color: greenColor,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        fontSize: usernameTextSize,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              ClipOval(
                                child: Image.asset(
                                  'assets/images/${user?['profile_image'] ?? 'placeholder_image.png'}',
                                  width: profileImageSize,
                                  height: profileImageSize,
                                  fit: BoxFit.cover,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: basePadding),
                          Container(
                            width: constraints.maxWidth,
                            constraints: BoxConstraints(
                              minHeight: 100,
                              maxHeight: size.height * 0.18,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(basePadding),
                              child: LayoutBuilder(
                                builder: (context, cardConstraints) {
                                  final double titleSize =
                                      (cardConstraints.maxWidth * 0.08)
                                          .clamp(20.0, 24.0);
                                  final double subtitleSize =
                                      (cardConstraints.maxWidth * 0.06)
                                          .clamp(14.0, 16.0);
                                  final double progressBarHeight =
                                      (cardConstraints.maxWidth * 0.025)
                                          .clamp(6.0, 10.0);
                                  final points = user?['points'] ?? 0;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user?['rank'] ?? 'Rank'}',
                                        style: TextStyle(
                                          color: greenColor,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          fontSize: titleSize,
                                        ),
                                      ),
                                      SizedBox(
                                          height: cardConstraints.maxHeight * 0.02),
                                      Text(
                                        '$points Points',
                                        style: TextStyle(
                                          color: greenWithOpacity,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          fontSize: subtitleSize,
                                        ),
                                      ),
                                      SizedBox(
                                          height: cardConstraints.maxHeight * 0.1),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            progressBarHeight * 0.5),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: progressBarHeight,
                                          child: LinearProgressIndicator(
                                            value: (points / 1000).clamp(0.0, 1.0),
                                            color: greenColor,
                                            backgroundColor: greenWhite,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: cardConstraints.maxHeight * 0.04),
                                      Text(
                                        '${1000 - (points % 1000)} Points Left',
                                        style: TextStyle(
                                          color: greenWithOpacity,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          fontSize: subtitleSize,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: basePadding),
                          // Add other containers or widgets here
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
