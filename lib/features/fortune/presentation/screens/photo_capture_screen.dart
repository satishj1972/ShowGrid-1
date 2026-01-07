// lib/features/fortune/presentation/screens/photo_capture_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/sg_colors.dart';
import 'submission_screen.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  final String challengeDescription;
  final String gridType;
  final String? challengeCategory;

  const PhotoCaptureScreen({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.challengeDescription,
    required this.gridType,
    this.challengeCategory,
  });

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isFrontCamera = false;
  FlashMode _flashMode = FlashMode.auto;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      await _setupCamera(_cameras![0]);
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _controller?.dispose();
    _controller = CameraController(camera, ResolutionPreset.high);
    
    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Camera error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitialized = false;
    });
    
    await _setupCamera(_cameras![_isFrontCamera ? 1 : 0]);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    
    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      default:
        newMode = FlashMode.off;
    }
    
    await _controller!.setFlashMode(newMode);
    setState(() => _flashMode = newMode);
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || _isCapturing) return;
    
    setState(() => _isCapturing = true);
    
    try {
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _capturedImage = File(photo.path);
        _isCapturing = false;
      });
    } catch (e) {
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capture failed: $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _capturedImage = File(image.path));
    }
  }

  void _submitPhoto() {
    if (_capturedImage == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubmissionScreen(
          mediaFile: _capturedImage!,
          mediaType: 'photo',
          challengeId: widget.challengeId,
          challengeTitle: widget.challengeTitle,
          challengeDescription: widget.challengeDescription,
          gridType: widget.gridType,
          challengeCategory: widget.challengeCategory,
        ),
      ),
    );
  }

  void _retake() {
    setState(() => _capturedImage = null);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _capturedImage != null ? _buildPreview() : _buildCamera(),
      ),
    );
  }

  Widget _buildCamera() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        if (_isInitialized && _controller != null)
          CameraPreview(_controller!)
        else
          const Center(child: CircularProgressIndicator(color: SGColors.htmlViolet)),

        // Top controls
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
              Text(
                widget.challengeTitle,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  _flashMode == FlashMode.off ? Icons.flash_off :
                  _flashMode == FlashMode.auto ? Icons.flash_auto :
                  Icons.flash_on,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        // Neon corners overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              margin: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                border: Border.all(color: SGColors.htmlViolet.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery
              IconButton(
                onPressed: _pickFromGallery,
                icon: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.white),
                ),
              ),
              
              // Capture button
              GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isCapturing ? Colors.grey : Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Switch camera
              IconButton(
                onPressed: _toggleCamera,
                icon: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.flip_camera_ios, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image preview
        Image.file(_capturedImage!, fit: BoxFit.cover),

        // Top bar
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _retake,
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
              const Text(
                'Preview',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        // Bottom actions
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retake,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitPhoto,
                  icon: const Icon(Icons.check),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SGColors.htmlViolet,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
