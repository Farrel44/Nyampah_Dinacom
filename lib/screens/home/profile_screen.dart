import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nyampah_app/theme/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
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
                            child: Image.asset(
                              'assets/images/placeholder_image.png',
                              width: constraints.maxWidth * 0.2,
                              height: constraints.maxWidth * 0.2,
                            ),
                          ),
                          SizedBox(width: constraints.maxWidth * 0.05),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "{username}",
                                style: TextStyle(
                                    color: greenColor,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: constraints.maxWidth * 0.06),
                              ),
                              Text(
                                "{email}",
                                style: TextStyle(
                                    color: greenWithOpacity,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: constraints.maxWidth * 0.05),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      //logic
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
                height: size.height * 0.15,
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
                            children: [
                              SvgPicture.asset(
                                'assets/images/setting.svg',
                                width: constraints.maxWidth * 0.07,
                              ),
                              SizedBox(width: constraints.maxWidth * 0.03),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pengaturan akun & aplikasi',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        color: greenColor,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    'Kontrol pengaturan aplikasi, data, dan lainnya.',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: greenWithOpacity,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                              SizedBox(width: constraints.maxWidth * 0.06),
                              const Icon(
                                Icons.chevron_right,
                                color: greenWithOpacity,
                              )
                            ],
                          ),
                          Divider(
                            height: constraints.maxWidth * 0.08,
                            color: greenWithOpacity,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/setting.svg',
                                width: constraints.maxWidth * 0.07,
                              ),
                              SizedBox(width: constraints.maxWidth * 0.03),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tentang Kami',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        color: greenColor,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    'Ikuti kami di sosial media, website, dan lainnya.',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: greenWithOpacity,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                              SizedBox(width: constraints.maxWidth * 0.05),
                              const Icon(
                                Icons.chevron_right,
                                color: greenWithOpacity,
                              ),
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
                height: size.height * 0.15,
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
                            children: [
                              SvgPicture.asset(
                                'assets/images/setting.svg',
                                width: constraints.maxWidth * 0.07,
                              ),
                              SizedBox(width: constraints.maxWidth * 0.03),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Voucherku',
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
                              const Icon(
                                Icons.chevron_right,
                                color: greenWithOpacity,
                              )
                            ],
                          ),
                          Divider(
                            height: constraints.maxWidth * 0.08,
                            color: greenWithOpacity,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/setting.svg',
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
                              const Icon(
                                Icons.chevron_right,
                                color: greenWithOpacity,
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: size.height * 0.2),
              SizedBox(
                width: size.width,
                height: size.height * 0.06,
                child: ElevatedButton(
                  onPressed: () {},
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
}
