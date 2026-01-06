// lib/features/fanverse/presentation/screens/fanverse_photo_capture_screen.dart
// 2.2111 PHOTO FLOW - Capture Photo → Take Photo → Review/Retake → Submit
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/sg_colors.dart';

class FanversePhotoCaptureScreen extends StatefulWidget {
  final String episodeId;
  final Map<String, dynamic>? episodeData;

  const FanversePhotoCaptureScreen({
    super.key,
    required this.episodeId,
    this.episodeData,
  });

  @override
  State<FanversePhotoCaptureScreen> createState() => _FanversePhotoCaptureScreenState();
}

class _FanversePhotoCaptureScreenState extends State<FanversePhotoCaptureScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  
  // Flow states: capture, review, submit
  String _currentState = 'capture'; // capture, review
  File? _capturedImage;
  double? _aiScore;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      
      final camera = _isFrontCamera ? cameras.last : cameras.first;
      _cameraController = CameraController(camera, ResolutionPreset.high);
      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraInitialized = false;
    });
    await _cameraController?.dispose();
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    setState(() => _isFlashOn = !_isFlashOn);
    await _cameraController!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(photo.path);
        _currentState = 'review';
      });
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _currentState = 'capture';
      _aiScore = null;
    });
  }

  Future<void> _getAiScore() async {
    setState(() => _isProcessing = true);
    // Simulate AI scoring
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _aiScore = 7.5 + (2.5 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
      _isProcessing = false;
    });
  }

  Future<void> _submitEntry() async {
    if (_aiScore == null) {
      await _getAiScore();
    }
    // Navigate to success or back to challenge
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entry submitted! AI Score: ${_aiScore?.toStringAsFixed(2)}'),
          backgroundColor: const Color(0xFFFF4FD8),
        ),
      );
      context.go('/fanverse/challenge/${widget.episodeId}', extra: widget.episodeData);
    }
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
        child: _currentState == 'capture' ? _buildCaptureView() : _buildReviewView(),
      ),
    );
  }

  // ============================================
  // CAPTURE VIEW (2.21111 Capture Photo)
  // ============================================
  Widget _buildCaptureView() {
    return Stack(
      children: [
        // Camera preview
        if (_isCameraInitialized && _cameraController != null)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CameraPreview(_cameraController!),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: Color(0xFFFF4FD8))),
        
        // Neon corner guides
        _buildNeonCorners(),
        
        // Top controls
        _buildTopControls(),
        
        // Bottom controls
        _buildCaptureControls(),
        
        // Guide text
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Align your pose within the frame',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeonCorners() {
    const cornerSize = 60.0;
    const strokeWidth = 3.0;
    const cornerColor = Color(0xFFFF4FD8);
    
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Stack(
          children: [
            // Top-left corner
            Positioned(
              top: 0,
              left: 0,
              child: _buildCorner(cornerSize, strokeWidth, cornerColor, topLeft: true),
            ),
            // Top-right corner
            Positioned(
              top: 0,
              right: 0,
              child: _buildCorner(cornerSize, strokeWidth, cornerColor, topRight: true),
            ),
            // Bottom-left corner
            Positioned(
              bottom: 100,
              left: 0,
              child: _buildCorner(cornerSize, strokeWidth, cornerColor, bottomLeft: true),
            ),
            // Bottom-right corner
            Positioned(
              bottom: 100,
              right: 0,
              child: _buildCorner(cornerSize, strokeWidth, cornerColor, bottomRight: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(double size, double strokeWidth, Color color, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          strokeWidth: strokeWidth,
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 10,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () => context.go('/fanverse/live/${widget.episodeId}', extra: widget.episodeData),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
          // Episode badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4FD8).withOpacity(0.3),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFF4FD8)),
            ),
            child: Text(
              widget.episodeData?['episode'] ?? 'Photo',
              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          // Flash toggle
          GestureDetector(
            onTap: _toggleFlash,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: _isFlashOn ? const Color(0xFFFFB84D) : Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureControls() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  _capturedImage = File(image.path);
                  _currentState = 'review';
                });
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(Icons.photo_library, color: Colors.white, size: 24),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF)]),
                ),
              ),
            ),
          ),
          // Switch camera
          GestureDetector(
            onTap: _switchCamera,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // REVIEW VIEW (2.211112 Review/Retake)
  // ============================================
  Widget _buildReviewView() {
    return Stack(
      children: [
        // Image preview
        if (_capturedImage != null)
          Positioned.fill(
            child: Image.file(_capturedImage!, fit: BoxFit.cover),
          ),
        
        // Top bar
        Positioned(
          top: 10,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _retakePhoto,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.refresh, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('Retake', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5CF1FF).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF5CF1FF)),
                ),
                child: const Text('Preview', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ),
        ),
        
        // AI Score result (if processed)
        if (_aiScore != null)
          Positioned(
            top: 70,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SGColors.pulseGold),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SGColors.pulseGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('AI Score', style: TextStyle(fontSize: 11, color: SGColors.pulseGold)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _aiScore!.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SGColors.pulseGold),
                  ),
                  const Spacer(),
                  const Text('Strong clarity • Good framing', style: TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
                ],
              ),
            ),
          ),
        
        // Bottom actions
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Column(
            children: [
              if (_isProcessing)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFFF4FD8), strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Analyzing your photo...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    // Get AI Score button
                    if (_aiScore == null)
                      Expanded(
                        child: GestureDetector(
                          onTap: _getAiScore,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF0D0F1A),
                              border: Border.all(color: SGColors.pulseGold),
                            ),
                            child: const Center(
                              child: Text('AI Score (-4)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SGColors.pulseGold)),
                            ),
                          ),
                        ),
                      ),
                    if (_aiScore == null) const SizedBox(width: 12),
                    // Submit button
                    Expanded(
                      flex: _aiScore != null ? 1 : 1,
                      child: GestureDetector(
                        onTap: _submitEntry,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF)]),
                            boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.4), blurRadius: 20)],
                          ),
                          child: Center(
                            child: Text(
                              _aiScore != null ? 'SUBMIT ENTRY' : 'SUBMIT',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom painter for neon corners
class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool topLeft, topRight, bottomLeft, bottomRight;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Add glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = strokeWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();

    if (topLeft) {
      path.moveTo(0, size.height * 0.6);
      path.lineTo(0, 0);
      path.lineTo(size.width * 0.6, 0);
    } else if (topRight) {
      path.moveTo(size.width * 0.4, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height * 0.6);
    } else if (bottomLeft) {
      path.moveTo(0, size.height * 0.4);
      path.lineTo(0, size.height);
      path.lineTo(size.width * 0.6, size.height);
    } else if (bottomRight) {
      path.moveTo(size.width * 0.4, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height * 0.4);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
