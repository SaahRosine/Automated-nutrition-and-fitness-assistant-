import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/pages/settings.dart';
import 'package:mobile/core/constants/app_styles.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _cameraAvailable = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _cameraAvailable = false;
          _errorMessage = 'No camera available on this device';
        });
        return;
      }

      final firstCamera = cameras.first;
      _controller = CameraController(firstCamera, ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    } catch (e) {
      setState(() {
        _cameraAvailable = false;
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _cameraAvailable && _controller != null
          ? FloatingActionButton(
              onPressed: () async {
                try {
                  await _initializeControllerFuture;
                  final image = await _controller!.takePicture();
                  // Handle captured image here
                  print('Image captured: ${image.path}');
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to capture image: $e')),
                  );
                }
              },
              child: Icon(Icons.camera_alt),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (!_cameraAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_photography, size: 64, color: AppColors.greyText),
            SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Camera not available',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Alternative: allow picking from gallery
                // For now, just show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Camera functionality not available on this device',
                    ),
                  ),
                );
              },
              child: Text('Use Gallery Instead'),
            ),
          ],
        ),
      );
    }

    if (_initializeControllerFuture == null) {
      return Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error initializing camera: ${snapshot.error}'),
            );
          }
          return CameraPreview(_controller!);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
