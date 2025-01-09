import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:nyampah_app/theme/navbar.dart';
import 'package:nyampah_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TrashHistory extends StatefulWidget {
  const TrashHistory({super.key});

  @override
  State<TrashHistory> createState() => _TrashHistoryState();
}

class _TrashHistoryState extends State<TrashHistory> {
  Map<String, dynamic>? user;
  String? token;
  String selectedPeriod = 'day'; 
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
      extendBody: true, // Pastikan body diperpanjang ke area navbar
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Trash Tracker",
            style: TextStyle(
              color: greenColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.065,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(basePadding),
            child: Column(
              children: [
                Row(
                  children: [
                    SelectButtonPeriod(
                      onPressed: () {
                        setState(() {
                          selectedPeriod = 'day';
                        });
                      },
                      size: size,
                      basePadding: basePadding,
                      title: "Daily",
                      isSelected: selectedPeriod == 'day',
                    ),
                    SizedBox(width: size.width * 0.02),
                    SelectButtonPeriod(
                      onPressed: () {
                        setState(() {
                          selectedPeriod = 'week';
                        });
                      },
                      size: size,
                      basePadding: basePadding,
                      title: "Weekly",
                      isSelected: selectedPeriod == 'week',
                    ),
                    SizedBox(width: size.width * 0.02),
                    SelectButtonPeriod(
                      onPressed: () {
                        setState(() {
                          selectedPeriod = 'month';
                        });
                      },
                      size: size,
                      basePadding: basePadding,
                      title: "Monthly",
                      isSelected: selectedPeriod == 'month',
                    ),
                  ],
                ),
                SizedBox(height: basePadding),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: token != null ? ApiService.getTrashByGroupData(token!, selectedPeriod) : Future.value([]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data available.'));
                      }

                      final trashData = snapshot.data!;
                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: basePadding,
                          mainAxisSpacing: basePadding,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: trashData.length,
                        itemBuilder: (context, index) {
                          final trash = trashData[index];
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(basePadding),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: constraints.maxWidth,
                                        height: constraints.maxHeight * 0.60,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(basePadding),
                                            topRight: Radius.circular(basePadding),
                                          ),
                                        ),
                                        child: Image.network(
                                          trash['trash_image'] ?? '', // Use API image URL
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                            'assets/images/sampah.jpeg', // Fallback image
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    trash['trash_name'] ?? 'Unknown',
                                                    style: TextStyle(
                                                      fontSize: size.width * 0.035,
                                                      fontFamily: 'Inter',
                                                      color: greenColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.orange,
                                                  size: 22,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              trash['trash_category_name'] ?? 'Unknown',
                                              style: TextStyle(
                                                color: greenWithOpacity,
                                                fontSize: size.width * 0.035,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              trash['created_at'] != null
                                                  ? DateTime.parse(trash['created_at'])
                                                      .toLocal()
                                                      .toString()
                                                      .split(' ')[0]
                                                  : 'Unknown Date',
                                              style: TextStyle(
                                                color: greenColor,
                                                fontFamily: 'Inter',
                                                fontSize: size.width * 0.032,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Navbar Floating
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: FloatingBottomNav(
              selectedIndex: 4,
              onTap: (p0) {},
            ),
          ),
        ],
      ),
    );
  }
}

class SelectButtonPeriod extends StatelessWidget {
  const SelectButtonPeriod({
    super.key,
    required this.title,
    required this.size,
    required this.basePadding,
    required this.onPressed,
    required this.isSelected,
  });

  final String title;
  final Size size;
  final double basePadding;
  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.25,
      height: size.height * 0.04,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? greenColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(basePadding),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: size.width * 0.032,
            color: isSelected ? Colors.white : greenColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
