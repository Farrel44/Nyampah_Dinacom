import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nyampah_app/theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
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
                                '{username}!',
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
                            'assets/images/placeholder_image.png',
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
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bronze',
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
                                  '75 Points',
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
                                      value: 0.2,
                                      color: greenColor,
                                      backgroundColor: greenWhite,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: cardConstraints.maxHeight * 0.04),
                                Text(
                                  '25 Points Left',
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
                          final double titleSize =
                              (constraints.maxWidth * 0.08).clamp(20.0, 24.0);
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
                                  ],
                                ),
                              ),
                              Container(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight * 0.63,
                                child: ListView.builder(
                                  itemCount: 3,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 10),
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                  color: greenColor,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: titleSize),
                                            ),
                                            SizedBox(
                                                width: constraints.maxHeight *
                                                    0.05),
                                            ClipOval(
                                              child: Image.asset(
                                                'assets/images/placeholder_image.png',
                                                width: profileImageSize * 0.7,
                                                height: profileImageSize * 0.7,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(
                                                width: constraints.maxHeight *
                                                    0.05),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '{username}',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.bold,
                                                    color: greenColor,
                                                    fontSize:
                                                        constraints.minWidth *
                                                            0.04,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        constraints.maxHeight *
                                                            0.05),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '{level}',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: greenWithOpacity,
                                                        fontSize: constraints
                                                                .minWidth *
                                                            0.035,
                                                      ),
                                                    ),
                                                    Text(
                                                      '{rank}',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: greenWithOpacity,
                                                        fontSize: constraints
                                                                .minWidth *
                                                            0.035,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                                width: constraints.maxHeight *
                                                    0.07),
                                            Text(
                                              '{points} points',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold,
                                                color: greenColor,
                                                fontSize:
                                                    constraints.minWidth * 0.04,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(
                                  height: 1,
                                  thickness: 1.5,
                                ),
                              ),
                              SizedBox(height: constraints.maxHeight * 0.02),
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '20',
                                      style: TextStyle(
                                          color: greenColor,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          fontSize: titleSize),
                                    ),
                                    SizedBox(
                                        width: constraints.maxHeight * 0.05),
                                    ClipOval(
                                      child: Image.asset(
                                        'assets/images/placeholder_image.png',
                                        width: profileImageSize * 0.7,
                                        height: profileImageSize * 0.7,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                        width: constraints.maxHeight * 0.05),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '{username}',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold,
                                            color: greenColor,
                                            fontSize:
                                                constraints.minWidth * 0.04,
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                constraints.maxHeight * 0.05),
                                        Row(
                                          children: [
                                            Text(
                                              '{level}',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold,
                                                color: greenWithOpacity,
                                                fontSize: constraints.minWidth *
                                                    0.035,
                                              ),
                                            ),
                                            Text(
                                              '{rank}',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold,
                                                color: greenWithOpacity,
                                                fontSize: constraints.minWidth *
                                                    0.035,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                        width: constraints.maxHeight * 0.07),
                                    Text(
                                      '{points} points',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        color: greenColor,
                                        fontSize: constraints.minWidth * 0.04,
                                      ),
                                    ),
                                  ],
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
