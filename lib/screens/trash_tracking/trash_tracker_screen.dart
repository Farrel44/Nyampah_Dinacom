import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:nyampah_app/theme/navbar.dart';
import 'package:nyampah_app/services/trash_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:nyampah_app/main.dart';

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
    final baseUrl = AppConfig().baseURL;
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
            "Lacak Sampah",
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
                      title: "Harian",
                      isSelected: selectedPeriod == 'day',
                    ),
                    SizedBox(width: size.width * 0.02),
                    SizedBox(
                      width: size.width * 0.3, // Adjust this value as needed
                      child: SelectButtonPeriod(
                        onPressed: () {
                          setState(() {
                            selectedPeriod = 'week';
                          });
                        },
                        size: size,
                        basePadding: basePadding,
                        title: "Mingguan",
                        isSelected: selectedPeriod == 'week',
                      ),
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
                      title: "Bulanan",
                      isSelected: selectedPeriod == 'month',
                    ),
                  ],
                ),
                SizedBox(height: basePadding),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: token != null
                        ? TrashService.getTrashByGroupData(token!, selectedPeriod)
                        : Future.value([]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Color(0xFF00693E),
                        ));
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error!'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Tidak ada data yang tersedia.'));
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
                          return GestureDetector(
                            onTap: () {
                                showModalBottomSheet(
                                context: context,
                                isScrollControlled:true, // Enables full control over scrolling
                                backgroundColor: backgroundColor,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(
                                    20), // Smooth top corner
                                  ),
                                ),
                                builder: (context) {
                                  return DraggableScrollableSheet(
                                  expand: false, // Prevent forced expansion
                                  minChildSize: 0.3,
                                  maxChildSize: 0.9,
                                  initialChildSize:
                                    0.5, // Slightly larger initial size
                                  builder: (context, scrollController) {
                                    return DefaultTabController(
                                    length: 1, // Number of tabs
                                    child: Column(
                                      children: [
                                      // Drag indicator
                                      Container(
                                        width: 40,
                                        height: 5,
                                        margin: const EdgeInsets.only(
                                          top: 8, bottom: 16),
                                        decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                      ),
                                      // Title and category row
                                      Padding(
                                        padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Row(
                                        crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                              CrossAxisAlignment
                                                .start,
                                            children: [
                                            Text(
                                              trash['trash_name'] ??
                                                'Tidak diketahui',
                                              style:
                                                const TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Inter',
                                              color: greenColor,
                                              fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4),
                                            Text(
                                              trash['trash_category_name'] ??
                                                'Anorganik',
                                              style:
                                                const TextStyle(
                                              fontSize: 16 ,
                                              color:
                                                greenWithOpacity,
                                              fontWeight:
                                                FontWeight.bold,
                                              fontFamily: 'Inter',
                                              ),
                                            ),
                                            ],
                                          ),
                                          ),
                                          const Icon(
                                          Icons.warning_amber_rounded,
                                          size: 30,
                                          color: Colors.orange,
                                          ),
                                        ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Trash image
                                      Padding(
                                        padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: ClipRRect(
                                        borderRadius:
                                          BorderRadius.circular(12.0),
                                        child: SizedBox(
                                          height:
                                            190, // Adjusted height to make the image smaller
                                          width: double.infinity,
                                          child: trash['trash_image'] != null
                                          ? Image.network(
                                          '$baseUrl/storage/${trash['trash_image']}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                          'assets/images/sampah.jpeg',
                                          fit: BoxFit.cover,
                                          );
                                          },
                                          ) 
                                          : Image.asset(
                                          'assets/images/sampah.jpeg',
                                          fit: BoxFit.cover,
                                          ),
                                        ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // TabBar
                                      TabBar(
                                        dividerColor: Colors.transparent,
                                        labelColor: greenColor,
                                        labelStyle: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        ),
                                        unselectedLabelStyle: TextStyle(
                                        color: greenColor,
                                        decoration: TextDecoration.none,
                                        ),
                                        indicatorColor: greenColor,
                                        tabs: const [
                                        Tab(text: 'Deskripsi'),
                                        ],
                                      ),
                                      // TabBarView with scrollable content
                                      Expanded(
                                        child: TabBarView(
                                        children: [
                                          // "Deskripsi" content
                                          SingleChildScrollView(
                                          controller:
                                            scrollController,
                                          padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 16.0,
                                            vertical: 12.0,
                                          ),
                                          child: Text(
                                            trash['description'],
                                            textAlign:
                                              TextAlign.justify,
                                            style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize:
                                              basePadding * 0.9,
                                            fontWeight:
                                              FontWeight.bold,
                                            color: greenColor,
                                            ),
                                          ),
                                          ),
                                        ],
                                        ),
                                      ),
                                      ],
                                    ),
                                    );
                                  },
                                  );
                                },
                              );
                            },
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(basePadding),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: constraints.maxWidth,
                                          height: constraints.maxHeight * 0.60,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft:
                                                  Radius.circular(basePadding),
                                              topRight:
                                                  Radius.circular(basePadding),
                                            ),
                                          ),
                                          child: trash['trash_image'] != null
                                                  ? Image.network(
                                                    '$baseUrl/storage/${trash['trash_image']}',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(
                                                    'assets/images/sampah.jpeg',
                                                    fit: BoxFit.cover,
                                                    );
                                                    },
                                                    )
                                                  : Image.asset(
                                                    'assets/images/sampah.jpeg',
                                                    fit: BoxFit.cover,
                                                    ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      trash['trash_name'] ??
                                                          'Tidak diketahui',
                                                      style: TextStyle(
                                                        fontSize:
                                                            size.width * 0.035,
                                                        fontFamily: 'Inter',
                                                        color: greenColor,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                trash['trash_category_name'] ??
                                                    'Tidak diketahui',
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
                                                    ? DateTime.parse(
                                                            trash['created_at'])
                                                        .toLocal()
                                                        .toString()
                                                        .split(' ')[0]
                                                    : 'Tanggal Tidak Diketahui',
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