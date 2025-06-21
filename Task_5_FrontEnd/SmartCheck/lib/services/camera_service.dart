import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static List<CameraDescription>? _cameras;
  static CameraController? _controller;

  // Initialize cameras
  static Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  // Get front camera
  static CameraDescription? getFrontCamera() {
    if (_cameras == null || _cameras!.isEmpty) return null;
    
    try {
      return _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      // If no front camera found, return the first available camera
      return _cameras!.isNotEmpty ? _cameras!.first : null;
    }
  }

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  // Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  // Initialize camera controller
  static Future<CameraController?> initializeCameraController() async {
    try {
      // Check permission first
      if (!await isCameraPermissionGranted()) {
        final granted = await requestCameraPermission();
        if (!granted) return null;
      }

      // Initialize cameras if not already done
      if (_cameras == null) {
        await initializeCameras();
      }

      final frontCamera = getFrontCamera();
      if (frontCamera == null) return null;

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      return _controller;
    } catch (e) {
      print('Error initializing camera controller: $e');
      return null;
    }
  }

  // Dispose camera controller
  static Future<void> disposeCameraController() async {
    await _controller?.dispose();
    _controller = null;
  }

  // Take picture
  static Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      return await _controller!.takePicture();
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  // Get camera controller
  static CameraController? get controller => _controller;
}
