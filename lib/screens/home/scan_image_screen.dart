import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:nyampah_app/services/api_service.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      ResolutionPreset.ultraHigh,
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cameras available'));
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

                      final response = await ApiService.scanImage(token!, File(image.path));

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
                                            Text(
                                              trashName,
                                              style: TextStyle(
                                                fontSize: basePadding * 1.3,
                                                fontFamily: 'Inter',
                                                color: greenColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: leaderBoardTitleColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              alignment: Alignment.center,
                                            ),
                                            onPressed: () {},
                                            child: Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.white,
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
                      print('Error: $e');
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
