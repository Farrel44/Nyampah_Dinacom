import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:nyampah_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? user;
  String? token;
  Future<List<Map<String, dynamic>>>? leaderboardFuture;

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
        leaderboardFuture = ApiService.getLeaderboard(token!);
      });
    }
  }

  Future<void> refreshLeaderboard() async {
    setState(() {
      leaderboardFuture = ApiService.getLeaderboard(token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Calculate responsive dimensions
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
                          Container(
                            width: size.width,
                            height: size.height * 0.4,
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
                                          IconButton(
                                            icon: const Icon(Icons.refresh, color: greenColor),
                                            onPressed: refreshLeaderboard,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight * 0.63,
                                      child: FutureBuilder<List<Map<String, dynamic>>>(
                                        future: leaderboardFuture,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Center(child: CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Center(child: Text('Error: ${snapshot.error}'));
                                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                            return const Center(child: Text('No data available'));
                                          } else {
                                            // Sort the leaderboard data by "exp" in descending order and take the top 5
                                            final leaderboardData = (snapshot.data!)
                                                .toList()
                                                ..sort((a, b) => (b['exp'] as int).compareTo(a['exp'] as int));
                                            final top5 = leaderboardData.take(3).toList();

                                            return Column(
                                              children: [
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: top5.length,
                                                  itemBuilder: (context, index) {
                                                    final user = top5[index];
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            '${index + 1}',
                                                            style: TextStyle(
                                                              color: greenColor,
                                                              fontFamily: 'Inter',
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 20, // Adjust to match your titleSize
                                                            ),
                                                          ),
                                                          const SizedBox(width: 20),
                                                          ClipOval(
                                                            child: Image.network(
                                                              user['profileImage'] ?? 'assets/images/placeholder_image.png',
                                                              width: 40,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 20),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                user['name'] ?? 'Unknown User',
                                                                style: TextStyle(
                                                                  fontFamily: 'Inter',
                                                                  fontWeight: FontWeight.bold,
                                                                  color: greenColor,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              Text(
                                                                'EXP: ${user['exp']}',
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
                                                            '${user['points']} points',
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
                                                ),
                                                Divider(),
                                                Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '${user?['rank'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                          color: greenColor,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20, // Adjust to match your titleSize
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      ClipOval(
                                                        child: Image.asset(
                                                          'assets/images/${user?['profile_image'] ?? 'placeholder_image.png'}',
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            user?['name'] ?? 'Unknown User',
                                                            style: TextStyle(
                                                              fontFamily: 'Inter',
                                                              fontWeight: FontWeight.bold,
                                                              color: greenColor,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            'EXP: ${user?['exp'] ?? 0}',
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
                                                        '${user?['points'] ?? 0} points',
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.bold,
                                                          color: greenColor,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
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
