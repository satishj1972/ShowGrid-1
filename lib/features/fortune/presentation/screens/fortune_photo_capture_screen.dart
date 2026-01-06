// lib/features/fortune/presentation/screens/fortune_photo_capture_screen.dart
// 2.1111 Fortune Photo Flow - Capture Photo with neon corners
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/sg_colors.dart';

class FortunePhotoCaptureScreen extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic>? challengeData;

  const FortunePhotoCaptureScreen({super.key, required this.challengeId, this.challengeData});

  @override
  State<FortunePhotoCaptureScreen> createState() => _FortunePhotoCaptureScreenState();
}

class _FortunePhotoCaptureScreenState extends State<FortunePhotoCaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  File? _capturedImage;
  String _flowState = 'ready'; // ready, captured, scored
  double? _aiScore;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _setupCamera(_cameras![0]);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _cameraController?.dispose();
    _cameraController = CameraController(camera, ResolutionPreset.high, enableAudio: false);
    try {
      await _cameraController!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Camera setup error: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    _isFrontCamera = !_isFrontCamera;
    await _setupCamera(_cameras![_isFrontCamera ? 1 : 0]);
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(photo.path);
        _flowState = 'captured';
      });
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  Future<void> _getAIScore() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _aiScore = 7.5 + (DateTime.now().millisecond % 25) / 10;
      _flowState = 'scored';
      _isProcessing = false;
    });
  }

  void _retake() {
    setState(() {
      _capturedImage = null;
      _flowState = 'ready';
      _aiScore = null;
    });
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entry submitted with AI Score: ${_aiScore?.toStringAsFixed(2)}'), backgroundColor: SGColors.neonMint),
    );
    context.go('/fortune/challenge/${widget.challengeId}', extra: widget.challengeData);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _flowState == 'ready' ? _buildCameraView() : _buildReviewView(),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera Preview
        if (_isInitialized && _cameraController != null)
          Positioned.fill(child: CameraPreview(_cameraController!))
        else
          const Center(child: CircularProgressIndicator(color: SGColors.fortunePrimary)),

        // Neon Corner Guides
        Positioned.fill(child: CustomPaint(painter: NeonCornerPainter(color: SGColors.fortunePrimary))),

        // Top Bar
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.7), Colors.transparent])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.go('/fortune/live/${widget.challengeId}', extra: widget.challengeData),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: SGColors.fortunePrimary.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: SGColors.fortunePrimary)),
                  child: const Text('FORTUNE PHOTO', style: TextStyle(color: SGColors.fortunePrimary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _toggleFlash,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: _isFlashOn ? SGColors.fortunePrimary : Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: _isFlashOn ? Colors.black : Colors.white, size: 24),
                  ),
                ),
                GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: SGColors.fortunePrimary, width: 4),
                      boxShadow: [BoxShadow(color: SGColors.fortunePrimary.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _switchCamera,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewView() {
    return Column(
      children: [
        // Top Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(onTap: _retake, child: const Text('Retake', style: TextStyle(color: SGColors.fortunePrimary, fontSize: 16))),
              const Text('Review', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(width: 60),
            ],
          ),
        ),

        // Image Preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: SGColors.fortunePrimary.withOpacity(0.5), width: 2)),
            clipBehavior: Clip.antiAlias,
            child: _capturedImage != null
                ? Image.file(_capturedImage!, fit: BoxFit.cover, width: double.infinity)
                : Container(color: Colors.grey[900], child: const Center(child: Text('Preview', style: TextStyle(color: Colors.white54)))),
          ),
        ),

        // AI Score Display
        if (_flowState == 'scored' && _aiScore != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [SGColors.fortunePrimary.withOpacity(0.2), SGColors.fortuneSecondary.withOpacity(0.1)]),
              border: Border.all(color: SGColors.fortunePrimary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: SGColors.pulseGold.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.auto_awesome, color: SGColors.pulseGold, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI GridScore', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(_aiScore!.toStringAsFixed(2), style: const TextStyle(color: SGColors.pulseGold, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: SGColors.neonMint.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Good Shot!', style: TextStyle(color: SGColors.neonMint, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_flowState == 'captured')
                Expanded(
                  child: GestureDetector(
                    onTap: _isProcessing ? null : _getAIScore,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [SGColors.fortunePrimary, SGColors.fortuneSecondary])),
                      child: Center(
                        child: _isProcessing
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('GET AI SCORE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      ),
                    ),
                  ),
                ),
              if (_flowState == 'scored') ...[
                Expanded(
                  child: GestureDetector(
                    onTap: _retake,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.3))),
                      child: const Center(child: Text('RETAKE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [SGColors.neonMint, SGColors.electricBlue])),
                      child: const Center(child: Text('SUBMIT ENTRY', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1))),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class NeonCornerPainter extends CustomPainter {
  final Color color;
  NeonCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 40.0;
    const margin = 40.0;

    // Top-left
    canvas.drawLine(Offset(margin, margin), Offset(margin + cornerLength, margin), paint);
    canvas.drawLine(Offset(margin, margin), Offset(margin, margin + cornerLength), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - cornerLength, margin), paint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + cornerLength), paint);

    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + cornerLength, size.height - margin), paint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - cornerLength), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - cornerLength, size.height - margin), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
