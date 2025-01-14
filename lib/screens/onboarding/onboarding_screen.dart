import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nyampah_app/main.dart';
import 'package:nyampah_app/screens/signup/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = true;
  String _loadingMessage = "Memuat....";

  @override
  void initState() {
    super.initState();
    isLogin();
  }

  void isLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool? isLogin = sp.getBool('isLogin') ?? false;

    if (isLogin) {
      setState(() {
        _loadingMessage = "Memasukkan Anda...";
      });
      Timer(const Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainNavigator()),
        );
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4ED),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: const Color(0xFF00693E)),
                  SizedBox(height: 20),
                  Text(_loadingMessage),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  children: [
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(-0.6, 1),
                      asset: 'assets/images/leaf_3.svg',
                      width: width * 0.18,
                      height: height * 0.18,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(0.60, 0.23),
                      asset: 'assets/images/bottle.svg',
                      width: width * 0.29,
                      height: height * 0.29,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(1.6, 1),
                      asset: 'assets/images/recycle_bin.svg',
                      width: width * 0.7,
                      height: height * 0.7,
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0, -1),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          width * 0.05,
                          height * 0.05,
                          width * 0.19,
                          0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextSection(),
                            SizedBox(height: height * 0.02),
                            _buildGetStartedButton(context, width, height),
                          ],
                        ),
                      ),
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(-1, -0.2),
                      asset: 'assets/images/leaf_2.svg',
                      width: width * 0.2,
                      height: height * 0.2,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(1, -1),
                      asset: 'assets/images/leaf_1.svg',
                      width: width * 0.3,
                      height: width * 0.3,
                      fit: BoxFit.cover,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(0.4, -0.54),
                      asset: 'assets/images/leaf_4.svg',
                      width: width * 0.04,
                      height: height * 0.04,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(-0.7, 0.16),
                      asset: 'assets/images/leaf_5.svg',
                      width: width * 0.04,
                      height: height * 0.04,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(-1, 0.65),
                      asset: 'assets/images/deco.svg',
                      width: width * 0.1,
                      height: height * 0.1,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(-0.63, -1.1),
                      asset: 'assets/images/deco_2.svg',
                      width: width * 0.04,
                      height: height * 0.04,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(0.94, -0.34),
                      asset: 'assets/images/deco.svg',
                      width: width * 0.1,
                      height: height * 0.1,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(-0.3, -0.1),
                      asset: 'assets/images/trash.svg',
                      width: width * 0.07,
                      height: height * 0.07,
                    ),
                    _buildSvgAsset(
                      alignment: const AlignmentDirectional(0.10, -0.4),
                      asset: 'assets/images/can.svg',
                      width: width * 0.08,
                      height: height * 0.08,
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSvgAsset({
    required AlignmentDirectional alignment,
    required String asset,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignmentInside = Alignment.center,
  }) {
    return Align(
      alignment: alignment,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SvgPicture.asset(
          asset,
          width: width,
          height: height,
          fit: fit,
          alignment: alignmentInside,
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "Don’t wait for",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF00693E),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: " change",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFFFF8302),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "Be the",
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    color: Color(0xFFFF8302),
                    fontSize: 40,
                    fontVariations: [
                      FontVariation('wght', 700),
                    ],
                  ),
                ),
                TextSpan(
                  text: " change",
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    color: Color(0xFF00693E),
                    fontSize: 40,
                    fontVariations: [
                      FontVariation('wght', 700),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton(
      BuildContext context, double width, double height) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00693E),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.015,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        'Mulai!',
        style: TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: width * 0.05,
        ),
      ),
    );
  }
}
