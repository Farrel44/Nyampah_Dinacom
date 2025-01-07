import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';

class ScanImage extends StatefulWidget {
  const ScanImage({super.key});

  @override
  State<ScanImage> createState() => _ScanImageState();
}

class _ScanImageState extends State<ScanImage> {
  late Future<List<CameraDescription>> _availableCameras;
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _availableCameras = availableCameras();
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              // Kamera Fullscreen
              Positioned.fill(
                child: CameraPreview(
                    _cameraController!), // Kamera mengisi seluruh layar
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
                      final XFile? image =
                          await _cameraController!.takePicture();
                      if (image != null) {
                        print("Gambar diambil: ${image.path}");
                      }
                    } catch (e) {
                      print("Error mengambil gambar: $e");
                    }
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(
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
