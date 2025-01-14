import 'package:nyampah_app/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nyampah_app/screens/map/map_screen.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:nyampah_app/services/scan_service.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';


class ScanImage extends StatefulWidget {
  const ScanImage({super.key});

  @override
  State<ScanImage> createState() => _ScanImageState();
}

class _ScanImageState extends State<ScanImage> with TickerProviderStateMixin {
  late Future<List<CameraDescription>> _availableCameras;
  CameraController? _cameraController;
  late final TabController _tabController;
  Map<String, dynamic>? user;
  String? token;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _availableCameras = availableCameras();
    loadUserData();
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.low,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tabController.dispose();
    super.dispose();
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
      body: FutureBuilder<List<CameraDescription>>(
        future: _availableCameras,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error!'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada kamera yang tersedia'));
          }

          final cameras = snapshot.data!;

          if (_cameraController == null) {
            _initializeCamera(cameras.first);
            return const Center(child: CircularProgressIndicator());
          }

          if (!_cameraController!.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/overlay.png',
                    width: size.width,
                    height: size.height,
                    color: Colors.white.withOpacity(1),
                  ),
                ),
              ),
              // Top Left Button
              Positioned(
                top: size.height * 0.05,
                left: size.width * 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE1EBE7),
                  ),
                  child: IconButton(
                    onPressed: () {
                      MainNavigator.navigateTo(1);
                    },
                    icon: Icon(Icons.arrow_back, color: const Color.fromRGBO(0, 105, 62, 100)),
                    tooltip: 'Back',
                  ),
                ),
              ),
              // Top Right Button
              Positioned(
                top: size.height * 0.05,
                right: size.width * 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE1EBE7),
                  ),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false, // Prevent dismissal by tapping outside
                        builder: (context) {
                          return TutorialDialog();
                        },
                      );
                    },
                    icon: Icon(Icons.question_mark_outlined, color: const Color.fromRGBO(0, 105, 62, 100)),
                    tooltip: 'Settings',
                  ),
                ),
              ),
              Positioned(
                bottom: size.height * 0.2,
                left: MediaQuery.of(context).size.width * 0.5 - 30,
                child: FloatingActionButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        isLoading = true;
                      });

                      final image = await _cameraController!.takePicture();

                      final response = await ScanService.scanImage(token!, File(image.path));

                      var category = response['category'];
                      if (category == 'Undefined') {
                        category = 'Tidak terdeteksi ';
                      }
                      final trashName = response['trash_name'];
                      final description = response['description'];
                      final pengelolaan = response['pengelolaan'];

                      setState(() {
                        isLoading = false;
                      });

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        builder: (context) {
                          return DraggableScrollableSheet(
                            initialChildSize: 0.3,
                            minChildSize: 0.1,
                            maxChildSize: 0.9,
                            expand: false,
                            builder: (context, scrollController) {
                              return Container(
                                padding: EdgeInsets.all(basePadding),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 5,
                                      margin: EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: greenColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category,
                                              style: TextStyle(
                                                fontSize: basePadding,
                                                fontFamily: 'Inter',
                                                color: greenWithOpacity,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                trashName,
                                                style: TextStyle(
                                                  fontSize: basePadding * 1.3,
                                                  fontFamily: 'Inter',
                                                  color: greenColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Add functionality here
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: category == 'Limbah' || category == 'Limbah B3'
                                                  ? Colors.red
                                                  : category == 'Organik'
                                                      ? Colors.green
                                                      : leaderBoardTitleColor, // Use your custom color
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10), // Rounded corners
                                              ),
                                              padding: EdgeInsets.zero, // Ensures proper alignment of the icon
                                            ),
                                            child: Icon(
                                              Icons.warning_amber_rounded, // Icon to display
                                              color: Colors.white, // Icon color
                                              size: 24, // Icon size (default is fine, but you can adjust)
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    DefaultTabController(
                                      length: 2,
                                      child: Column(
                                        children: [
                                          TabBar(
                                            controller: _tabController,
                                            tabs: [
                                              Tab(text: 'Deskripsi'),
                                              Tab(text: 'Pengelolaan'),
                                            ],
                                            labelStyle: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            dividerColor: Colors.transparent,
                                            labelColor: greenColor,
                                            unselectedLabelStyle: TextStyle(
                                              color: greenColor,
                                              decoration: TextDecoration.none,
                                            ),
                                            indicatorColor: greenColor,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.03),
                                    Expanded(
                                      child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        ListView(
                                        controller: scrollController,
                                        children: [
                                          Text(
                                          description,
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: basePadding * 0.9,
                                            fontWeight: FontWeight.bold,
                                            color: greenColor,
                                          ),
                                          ),
                                        ],
                                        ),
                                        ListView(
                                        controller: scrollController,
                                        children: [
                                          Text(
                                          pengelolaan,
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: basePadding * 0.9,
                                            fontWeight: FontWeight.bold,
                                            color: greenColor,
                                          ),
                                          ),
                                          SizedBox(height: 20),
                                          ElevatedButton(
                                          onPressed: () async{
                                                await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                    MapScreen(),
                                            ),
                                          );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: leaderBoardTitleColor,
                                            iconColor: leaderBoardTitleColor,
                                            shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            'Tempat Pengelolaan',
                                            style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: basePadding * 0.9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            ),
                                          ),
                                          ),
                                        ],
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
                    } catch (e) {
                      print('Error!');
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  backgroundColor: Colors.green,
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  @override
  _TutorialDialogState createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  final PageController _pageController = PageController();
  int currentStep = 0;

  final List<String> steps = [
    "Arahkan kamera handphone kamu ke sampah yang kamu tuju!",
    "Kalau ada lebih dari 1 sampah yang bentuknya sama, mending discan barengan aja!",
    "Scan sampahnya, dapetin poinnya, dan tuker jadi beragam voucher yang menarik!",
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 350,
        child: Column(
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close_rounded, color: Color(0xFF00693E)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            // Content with PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentStep = index;
                  });
                },
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: SvgPicture.asset(
                              'assets/images/tutorial_step_${index + 1}.svg',
                              fit: BoxFit.contain,
                            ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          steps[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF00693E),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Navigation Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(steps.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentStep == index
                        ? Color(0xFF00693E)
                        : Colors.grey.withOpacity(0.5),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
