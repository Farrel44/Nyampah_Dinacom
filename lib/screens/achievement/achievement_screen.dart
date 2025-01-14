import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nyampah_app/services/achievement_service.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyampah_app/services/user_service.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => AchievementPageState();
}

class AchievementPageState extends State<AchievementPage> {
  Map<String, dynamic>? user;
  String? token;
  List<Map<String, dynamic>> achievements = [];
  bool isLoading = true;
  Future<List<Map<String, dynamic>>>? achievementsFuture;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    final userToken = prefs.getString('token');

    if (userData != null && userToken != null) {
      setState(() {
        user = jsonDecode(userData);
        token = userToken;
        achievementsFuture = AchievementService.getAllAchievements(userToken);
      });
    }
  }

  Future<void> updateUserRankData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final userData = await UserService.getUserByName(token);
        await prefs.setString('user', jsonEncode(userData));

        setState(() {
          user = userData;
        });
      } else {
        throw Exception('Token tidak ditemukan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data pengguna!')),
        );
      }
    }
  }

  Future<void> handleClaimAchievement(int achievementId) async {
    try {
      await AchievementService.claimAchievement(token!, achievementId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pencapaian berhasil diklaim!'),
            backgroundColor: greenColor,
          ),
        );
        await updateUserRankData(); // Update user data after claiming achievement
        await refreshAchievement(); // Refresh achievements
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengklaim prestasi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> refreshAchievement() async {
    setState(() {
      achievementsFuture = AchievementService.getAllAchievements(token!);
    });
    await loadUserData(); // Refresh user data and rank
  }

  Future<void> fetchedAchievements(String? token) async {
    if (token == null) return;

    try {
      final fetchedAchievement = await AchievementService.getAllAchievements(token);
      if (mounted) {
        setState(() {
          achievements = fetchedAchievement;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data prestasi!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Text(
            "Peringkat & Prestasi",
            style: TextStyle(
              color: greenColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.065,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: greenColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Rank Card
          Padding(
            padding: EdgeInsets.all(basePadding),
            child: Container(
              width: double.infinity,
              height: size.height * 0.18,
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
                        (cardConstraints.maxWidth * 0.08).clamp(20.0, 24.0);
                    final double subtitleSize =
                        (cardConstraints.maxWidth * 0.06).clamp(14.0, 16.0);
                    final double progressBarHeight =
                        (cardConstraints.maxWidth * 0.025).clamp(6.0, 10.0);
                    final points = user?['points'] ?? 0;
                    final exp = user?['exp'] ?? 0;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${user?['rank'] ?? 'Peringkat'}',
                          style: TextStyle(
                            color: greenColor,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: titleSize,
                          ),
                        ),
                        SizedBox(height: cardConstraints.maxHeight * 0.02),
                        Text(
                          '$points Poin',
                          style: TextStyle(
                            color: greenWithOpacity,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: subtitleSize,
                          ),
                        ),
                        SizedBox(height: cardConstraints.maxHeight * 0.1),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              progressBarHeight * 0.5),
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
                        SizedBox(height: cardConstraints.maxHeight * 0.04),
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
                    );
                  },
                ),
              ),
            ),
          ),

          // Achievements Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(basePadding),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Achievement Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                'assets/images/achievement_icon.svg',
                                width: size.width * 0.06,
                                height: size.width * 0.06,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.04),
                          const Text(
                            'Pencapaian',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24,
                              color: greenColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Achievement List
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: achievementsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: Color(0xFF00693E))
                            );
                          } 
                          
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}')
                            );
                          }
                          
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Tidak ada pencapaian yang tersedia')
                            );
                          }

                          final achievements = snapshot.data!;
                          return ListView.builder(
                            padding: EdgeInsets.all(basePadding),
                            itemCount: achievements.length,
                            itemBuilder: (context, index) {
                              final achievement = achievements[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: greenWithOpacity),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Achievement Title
                                        Text(
                                          achievement['achievementName'] ?? '',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold,
                                            color: greenColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                                            
                                        // Achievement Description
                                        Text(
                                          achievement['achievementDescription'] ?? '',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: greenWithOpacity,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Claim Button
                                        ElevatedButton(
                                          onPressed: achievement['claimable'] == true
                                              ? () async {
                                                  await handleClaimAchievement(achievement['achievementId']);
                                                  await loadUserData();
                        
                                                  // Fetch user data
                                                  try {
                                                    final prefs = await SharedPreferences.getInstance();
                                                    final token = prefs.getString('token');
                                                    print(token);
                          
                                                    if (token != null) {
                                                      final userData = await UserService.getUserByName(token);
                                                      await prefs.setString('user', jsonEncode(userData));
                                                    } else {
                                                      throw Exception('Token tidak ditemukan');
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Gagal mengambil data pengguna: '),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: achievement['claimable'] == true
                                                ? greenColor
                                                : greenWithOpacity,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            minimumSize: const Size(50, 24),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            'Claim',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        // Reward Points
                                        Text(
                                          '${achievement['rewardPoints']} Points',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            color: greenWithOpacity,
                                            fontSize: 12,
                                          ),
                                        ),
                        
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
