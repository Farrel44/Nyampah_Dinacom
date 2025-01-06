import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';

// ScallopedClipper remains the same
class ScallopedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double scallopsWidth = 15.0;
    final double scallopsHeight = 10.0;
    final int scallopsCount = (size.width / scallopsWidth).ceil();

    path.lineTo(0, size.height - scallopsHeight);

    for (int i = 0; i < scallopsCount; i++) {
      final double startX = i * scallopsWidth;
      path.relativeArcToPoint(
        Offset(scallopsWidth, 0),
        radius: Radius.circular(scallopsHeight),
        clockwise: false,
      );
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => VoucherPageState();
}

class VoucherPageState extends State<VoucherPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Voucher",
            style: TextStyle(
                color: greenColor,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.065),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(basePadding),
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: size.height * 0.15,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ClipPath(
                          clipper: ScallopedClipper(),
                          child: Container(
                            width: double.infinity,
                            height: (size.height * 0.15) * 0.65,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: basePadding,
                                vertical: basePadding / 2,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center vertically
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Center horizontally
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Google Play",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Voucher Google Play IDR 5.000",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Klaim Voucher",
                                  style: TextStyle(
                                    color: greenColor,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: greenColor,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
