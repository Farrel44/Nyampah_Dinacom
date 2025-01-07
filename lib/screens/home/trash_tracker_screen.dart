import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:nyampah_app/theme/navbar.dart';

class TrashHistory extends StatefulWidget {
  const TrashHistory({super.key});

  @override
  State<TrashHistory> createState() => _TrashHistoryState();
}

class _TrashHistoryState extends State<TrashHistory> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);

    return Scaffold(
      extendBody: true, // Pastikan body diperpanjang ke area navbar
      backgroundColor: backgroundColor,
      appBar: AppBar(
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
                      onPressed: () {},
                      size: size,
                      basePadding: basePadding,
                      title: "Daily",
                    ),
                    SizedBox(width: size.width * 0.02),
                    SelectButtonPeriod(
                      onPressed: () {},
                      size: size,
                      basePadding: basePadding,
                      title: "Weekly",
                    ),
                    SizedBox(width: size.width * 0.02),
                    SelectButtonPeriod(
                      onPressed: () {},
                      size: size,
                      basePadding: basePadding,
                      title: "Monthly",
                    ),
                  ],
                ),
                SizedBox(height: basePadding),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: basePadding,
                      mainAxisSpacing: basePadding,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight * 0.65,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(basePadding),
                                      topRight: Radius.circular(basePadding),
                                    ),
                                  ),
                                  child: Image.asset(
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Sampah Plastik',
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
                                        'Anorganik',
                                        style: TextStyle(
                                          color: greenWithOpacity,
                                          fontSize: size.width * 0.035,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '12.33 | 10 Sept 2024',
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
  });

  final String title;
  final Size size;
  final double basePadding;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.25,
      height: size.height * 0.04,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
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
            color: greenColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
