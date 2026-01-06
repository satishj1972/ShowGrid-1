// lib/features/fortune/presentation/screens/fortune_video_capture_screen.dart
// 2.1112 Fortune Video Flow - Record Video with timer
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import '../../../../core/theme/sg_colors.dart';

class FortuneVideoCaptureScreen extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic>? challengeData;

  const FortuneVideoCaptureScreen({super.key, required this.challengeId, this.challengeData});

  @override
  State<FortuneVideoCaptureScreen> createState() => _FortuneVideoCaptureScreenState();
}

class _FortuneVideoCaptureScreenState extends State<FortuneVideoCaptureScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isRecording = false;
  File? _recordedVideo;
  String _flowState = 'ready'; // ready, recording, recorded, scored
  double? _aiScore;
  bool _isProcessing = false;
  
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  static const int maxDuration = 60;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
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
    _cameraController = CameraController(camera, ResolutionPreset.high, enableAudio: true);
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
    if (_cameras == null || _cameras!.length < 2 || _isRecording) return;
    _isFrontCamera = !_isFrontCamera;
    await _setupCamera(_cameras![_isFrontCamera ? 1 : 0]);
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _flowState = 'recording';
        _recordingSeconds = 0;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordingSeconds++);
        if (_recordingSeconds >= maxDuration) _stopRecording();
      });
    } catch (e) {
      debugPrint('Recording start error: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;
    _recordingTimer?.cancel();
    try {
      final XFile video = await _cameraController!.stopVideoRecording();
      setState(() {
        _recordedVideo = File(video.path);
        _isRecording = false;
        _flowState = 'recorded';
      });
    } catch (e) {
      debugPrint('Recording stop error: $e');
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
      _recordedVideo = null;
      _flowState = 'ready';
      _aiScore = null;
      _recordingSeconds = 0;
    });
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Video submitted with AI Score: ${_aiScore?.toStringAsFixed(2)}'), backgroundColor: SGColors.neonMint),
    );
    context.go('/fortune/challenge/${widget.challengeId}', extra: widget.challengeData);
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: (_flowState == 'ready' || _flowState == 'recording') ? _buildCameraView() : _buildReviewView(),
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

        // Recording indicator and timer
        if (_isRecording)
          Positioned(
            top: 80, left: 0, right: 0,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3 + _pulseController.value * 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
                        const SizedBox(width: 8),
                        const Text('REC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(_formatDuration(_recordingSeconds), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Progress bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _recordingSeconds / maxDuration,
                    child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [SGColors.fortunePrimary, SGColors.fortuneSecondary]), borderRadius: BorderRadius.circular(2))),
                  ),
                ),
              ],
            ),
          ),

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
                  onTap: _isRecording ? null : () => context.go('/fortune/live/${widget.challengeId}', extra: widget.challengeData),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    child: Icon(Icons.close, color: _isRecording ? Colors.white38 : Colors.white, size: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: SGColors.fortunePrimary.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: SGColors.fortunePrimary)),
                  child: Text(_isRecording ? 'MAX ${maxDuration}s' : 'FORTUNE VIDEO', style: const TextStyle(color: SGColors.fortunePrimary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
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
                  onTap: _isRecording ? null : _toggleFlash,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: _isFlashOn ? SGColors.fortunePrimary : Colors.white.withOpacity(_isRecording ? 0.1 : 0.2), shape: BoxShape.circle),
                    child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: _isFlashOn ? Colors.black : (_isRecording ? Colors.white38 : Colors.white), size: 24),
                  ),
                ),
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _isRecording ? Colors.red : SGColors.fortunePrimary, width: 4),
                      boxShadow: [BoxShadow(color: (_isRecording ? Colors.red : SGColors.fortunePrimary).withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: _isRecording ? BorderRadius.circular(8) : null,
                        color: _isRecording ? Colors.red : SGColors.fortunePrimary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _isRecording ? null : _switchCamera,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(_isRecording ? 0.1 : 0.2), shape: BoxShape.circle),
                    child: Icon(Icons.flip_camera_ios, color: _isRecording ? Colors.white38 : Colors.white, size: 24),
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
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(onTap: _retake, child: const Text('Retake', style: TextStyle(color: SGColors.fortunePrimary, fontSize: 16))),
              const Text('Review Video', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(width: 60),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey[900], border: Border.all(color: SGColors.fortunePrimary.withOpacity(0.5), width: 2)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.videocam, color: SGColors.fortunePrimary, size: 64),
                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                    child: Text('Duration: ${_formatDuration(_recordingSeconds)}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_flowState == 'scored' && _aiScore != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [SGColors.fortunePrimary.withOpacity(0.2), SGColors.fortuneSecondary.withOpacity(0.1)]), border: Border.all(color: SGColors.fortunePrimary.withOpacity(0.5))),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: SGColors.pulseGold.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome, color: SGColors.pulseGold, size: 28)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('AI GridScore', style: TextStyle(color: Colors.white70, fontSize: 12)), Text(_aiScore!.toStringAsFixed(2), style: const TextStyle(color: SGColors.pulseGold, fontSize: 28, fontWeight: FontWeight.bold))])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: SGColors.neonMint.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text('Great!', style: TextStyle(color: SGColors.neonMint, fontSize: 12, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_flowState == 'recorded')
                Expanded(
                  child: GestureDetector(
                    onTap: _isProcessing ? null : _getAIScore,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [SGColors.fortunePrimary, SGColors.fortuneSecondary])),
                      child: Center(child: _isProcessing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('GET AI SCORE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1))),
                    ),
                  ),
                ),
              if (_flowState == 'scored') ...[
                Expanded(child: GestureDetector(onTap: _retake, child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.3))), child: const Center(child: Text('RETAKE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)))))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: GestureDetector(onTap: _submit, child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [SGColors.neonMint, SGColors.electricBlue])), child: const Center(child: Text('SUBMIT ENTRY', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1)))))),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
