import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CustomCameraPage extends StatefulWidget {
  @override
  _CustomCameraPageState createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Get list of cameras
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras.first,
      ResolutionPreset.medium,
    );

    // Initialize the camera
    await _cameraController.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    final image = await _cameraController.takePicture();
    setState(() {
      _capturedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _capturedImage == null
                    ? CameraPreview(_cameraController) // Camera view
                    : Image.file(
                        File(_capturedImage!.path), // Captured image preview
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 700,
                      ),
                // Top Close Button
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bottom Buttons: Re-Capture and Save
          if (_capturedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    onPressed: () {
                      setState(() {
                        _capturedImage = null; // Re-capture
                      });
                    },
                    child: const Text("Re-Capture", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    onPressed: () {
                      // Save action
                      Navigator.pop(context, _capturedImage);
                    },
                    child: const Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                backgroundColor: Colors.purple,
                onPressed: _captureImage,
                child: const Icon(Icons.camera),
              ),
            ),
        ],
      ),
    );
  }
}
