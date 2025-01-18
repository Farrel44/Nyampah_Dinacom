import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:nyampah_app/services/user_service.dart';
import 'package:nyampah_app/screens/achievement/achievement_screen.dart';
import 'package:nyampah_app/main.dart';


class HomeScreen extends StatefulWidget {
  final GlobalKey achievementKey;

  const HomeScreen({Key? key, required this.achievementKey}) : super(key: key); // Accept the key in the constructor

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  Map<String, dynamic>? user;
  String? token;
  Future<List<Map<String, dynamic>>>? leaderboardFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    final userToken = prefs.getString('token');

    if (userData != null) {
      setState(() {
        user = jsonDecode(userData);
        token = userToken;
        leaderboardFuture = UserService.getLeaderboard(token!);
      });

    }

    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> refreshLeaderboard() async {
    setState(() {
      leaderboardFuture = UserService.getLeaderboard(token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = AppConfig().baseURL;
    final size = MediaQuery.of(context).size;

    // Calculate responsive dimensions
    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(
            color:  Color(0xFF00693E),
          ))
          : user == null
              ? const Center(child: CircularProgressIndicator( color:  Color(0xFF00693E),))
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
                        //achievement card
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
                              'Selamat datang kembali.',
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
                          )
                        ],
                        ),
                        SizedBox(height: basePadding),
                        //rank card
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
                            double calculateProgress(int exp) {
                            if (exp < 5000) {
                              return exp / 5000; // Bronze rank progress
                            } else if (exp < 10000) {
                              return (exp - 5000) / 5000; // Silver rank progress
                            } else if (exp < 15000) {
                              return (exp - 10000) / 5000; // Gold rank progress
                            } else if (exp < 20000) {
                              return (exp - 15000) / 5000; // Platinum rank progress
                            } else {
                              return 1.0; // Diamond rank (progress full)
                            }
                            }
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
                            final exp = user?['exp'] ?? 0;

                            return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                              CrossAxisAlignment.start,
                            children: [
                              TextButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AchievementPage(),
                                        ),
                                      );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Column(
                                  children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                    Row(
                                        key: widget.achievementKey,
                                      children: [
                                      SvgPicture.asset(
                                        'assets/images/rank_${user?['rank']?.toLowerCase() ?? 'bronze'}.svg',
                                        height: cardConstraints.maxHeight * 0.40,
                                        fit: BoxFit.cover,
                                        placeholderBuilder: (context) => Image.asset(
                                        'assets/images/placeholder_image.png',
                                        height: cardConstraints.maxHeight * 0.40,
                                        fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: basePadding),
                                      Column(
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
                                        height: cardConstraints.maxHeight * 0.02,
                                        ),
                                        Text(
                                        '$points Poin',
                                        style: TextStyle(
                                        color: greenWithOpacity,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        fontSize: subtitleSize,
                                        ),
                                        ),
                                        ],
                                      ),
                                      ],
                                      ),
                                      ],
                                    ),
                                    ],
                                    ),
                                SizedBox(
                                  height: cardConstraints.maxHeight * 0.1,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                  progressBarHeight * 0.5,
                                  ),
                                  child: SizedBox(
                                  width: double.infinity,
                                  height: progressBarHeight,
                                  child: LinearProgressIndicator(
                                    value: calculateProgress(exp),
                                    color: greenColor,
                                    backgroundColor: greenWhite,
                                  ),
                                  ),
                                ),
                                SizedBox(
                                  height: cardConstraints.maxHeight * 0.04,
                                ),
                                Text(
                                  '${1000 - (exp % 1000)} Exp tersisa ke peringkat berikutnya',
                                  style: TextStyle(
                                  color: greenWithOpacity,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: subtitleSize,
                                  ),
                                ),
                                ],
                              ),
                              ),
                            ],
                            );
                          },
                          ),
                        ),
                        ),
                        SizedBox(height: basePadding),
                        Container(
                        width: size.width,
                        height: size.height * 0.6, // Adjusted height to be fuller
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                          return Column(
                            children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                              color: leaderBoardTitleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              ),
                              child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Row(
                                    children: [
                                    Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      child: SvgPicture.asset(
                                      'assets/images/leaderboard.svg',
                                      width: constraints.maxWidth * 0.06,
                                      height: constraints.maxWidth * 0.06,
                                      ),
                                    ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth * 0.04),
                                    const Text(
                                    'Leaderboard',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      color: greenColor,
                                      fontWeight: FontWeight.bold),
                                    ),
                                    ],
                                  ),
                                  ],
                                ),
                                IconButton(
                                icon: const Icon(Icons.refresh, color: greenColor),
                                onPressed: refreshLeaderboard,
                                ),
                              ],
                              ),
                            ),
                            Expanded(
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: leaderboardFuture,
                              builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: Color(0xFF00693E)));
                              } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('No data available'));
                              } else {
                              final leaderboardData = snapshot.data!
                                ..sort((a, b) => (b['exp'] as int).compareTo(a['exp'] as int));

                              return ListView.builder(
                                itemCount: leaderboardData.length,
                                itemBuilder: (context, index) {
                                final user = leaderboardData[index];
                                print("profile image : $baseUrl/storage/$user['profile_image']");
                                return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                  color: greenColor,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  ),
                                  ),
                                  const SizedBox(width: 20),
                                  ClipOval(
                                  child: user['profileImage'] != null
                                  ? Image.network(
                                    '$baseUrl/storage/${leaderboardData[index]['profileImage']}',
                                    width: constraints.maxWidth * 0.15,
                                    height: constraints.maxWidth * 0.15,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                    'assets/images/placeholder_image.png',
                                    width: constraints.maxWidth * 0.15,
                                    height: constraints.maxWidth * 0.15,
                                    fit: BoxFit.cover,
                                    );
                                    },
                                    )
                                  : Image.asset(
                                    'assets/images/placeholder_image.png',
                                    width: constraints.maxWidth * 0.15,
                                    height: constraints.maxWidth * 0.15,
                                    fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Text(
                                  user['name'] ?? 'Pengguna Tidak Dikenal',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    color: greenColor,
                                    fontSize: 16,
                                  ),
                                  ),
                                  Text(
                                  '${user['points']} Poin',
                                  style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  color: greenWithOpacity,
                                  fontSize: 14,
                                  ),
                                  ),
                                  ],
                                  ),
                                  const Spacer(),
                                  
                                  Text(
                                  '${user['exp']} Exp',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    color: greenColor,
                                    fontSize: 16,
                                  ),
                                  ),
                                ],
                                ),
                                );
                                },
                              );
                              }
                              },
                              ),
                            ),
                            ],
                          );
                          },
                        ),
                        )
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
