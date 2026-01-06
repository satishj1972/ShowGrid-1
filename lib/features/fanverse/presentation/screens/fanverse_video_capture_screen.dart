// lib/features/fanverse/presentation/screens/fanverse_video_capture_screen.dart
// 2.2112 VIDEO FLOW - Record Video → Recording → Review/Retake → Submit
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/sg_colors.dart';

class FanverseVideoCaptureScreen extends StatefulWidget {
  final String episodeId;
  final Map<String, dynamic>? episodeData;

  const FanverseVideoCaptureScreen({
    super.key,
    required this.episodeId,
    this.episodeData,
  });

  @override
  State<FanverseVideoCaptureScreen> createState() => _FanverseVideoCaptureScreenState();
}

class _FanverseVideoCaptureScreenState extends State<FanverseVideoCaptureScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  
  // Flow states
  String _currentState = 'ready'; // ready, recording, review
  File? _recordedVideo;
  double? _aiScore;
  bool _isProcessing = false;
  
  // Recording state
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  static const int maxRecordingSeconds = 60;

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
    if (_isRecording) return;
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

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _currentState = 'recording';
        _recordingSeconds = 0;
      });
      
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordingSeconds++);
        if (_recordingSeconds >= maxRecordingSeconds) {
          _stopRecording();
        }
      });
    } catch (e) {
      debugPrint('Recording error: $e');
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
        _currentState = 'review';
      });
    } catch (e) {
      debugPrint('Stop recording error: $e');
    }
  }

  void _retakeVideo() {
    setState(() {
      _recordedVideo = null;
      _currentState = 'ready';
      _aiScore = null;
      _recordingSeconds = 0;
    });
  }

  Future<void> _getAiScore() async {
    setState(() => _isProcessing = true);
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

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _currentState == 'review' ? _buildReviewView() : _buildRecordingView(),
      ),
    );
  }

  // ============================================
  // RECORDING VIEW (2.21121 Record Video)
  // ============================================
  Widget _buildRecordingView() {
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
          const Center(child: CircularProgressIndicator(color: Color(0xFF9B7DFF))),
        
        // Neon frame (pulsing when recording)
        _buildNeonFrame(),
        
        // Top controls
        _buildTopControls(),
        
        // Recording indicator
        if (_isRecording)
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'REC ${_formatDuration(_recordingSeconds)} / ${_formatDuration(maxRecordingSeconds)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Progress bar
        if (_isRecording)
          Positioned(
            top: 120,
            left: 40,
            right: 40,
            child: LinearProgressIndicator(
              value: _recordingSeconds / maxRecordingSeconds,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4FD8)),
            ),
          ),
        
        // Bottom controls
        _buildRecordingControls(),
      ],
    );
  }

  Widget _buildNeonFrame() {
    final borderColor = _isRecording ? Colors.red : const Color(0xFF9B7DFF);
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor.withOpacity(_isRecording ? 0.8 : 0.5),
            width: _isRecording ? 4 : 2,
          ),
          boxShadow: _isRecording
              ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)]
              : [BoxShadow(color: const Color(0xFF9B7DFF).withOpacity(0.3), blurRadius: 15)],
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
            onTap: _isRecording ? null : () => context.go('/fanverse/live/${widget.episodeId}', extra: widget.episodeData),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Icon(Icons.close, color: _isRecording ? Colors.grey : Colors.white, size: 22),
            ),
          ),
          // Episode badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF9B7DFF).withOpacity(0.3),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF9B7DFF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.videocam, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  widget.episodeData?['episode'] ?? 'Video',
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Flash toggle
          GestureDetector(
            onTap: _isRecording ? null : _toggleFlash,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: _isFlashOn ? const Color(0xFFFFB84D) : (_isRecording ? Colors.grey : Colors.white),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingControls() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery
          GestureDetector(
            onTap: _isRecording ? null : () async {
              final picker = ImagePicker();
              final XFile? video = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
              if (video != null) {
                setState(() {
                  _recordedVideo = File(video.path);
                  _currentState = 'review';
                });
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(_isRecording ? 0.1 : 0.2),
                border: Border.all(color: Colors.white.withOpacity(_isRecording ? 0.1 : 0.3)),
              ),
              child: Icon(Icons.photo_library, color: _isRecording ? Colors.grey : Colors.white, size: 24),
            ),
          ),
          // Record button
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _isRecording ? Colors.red : Colors.white, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: _isRecording ? BorderRadius.circular(8) : null,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          // Switch camera
          GestureDetector(
            onTap: _isRecording ? null : _switchCamera,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(_isRecording ? 0.1 : 0.2),
                border: Border.all(color: Colors.white.withOpacity(_isRecording ? 0.1 : 0.3)),
              ),
              child: Icon(Icons.flip_camera_ios, color: _isRecording ? Colors.grey : Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // REVIEW VIEW (2.211212 Review/Retake)
  // ============================================
  Widget _buildReviewView() {
    return Stack(
      children: [
        // Video preview placeholder
        Positioned.fill(
          child: Container(
            color: const Color(0xFF0D0F1A),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_outline, color: Color(0xFF9B7DFF), size: 80),
                  SizedBox(height: 16),
                  Text('Video Preview', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('Tap to play', style: TextStyle(color: SGColors.htmlMuted, fontSize: 12)),
                ],
              ),
            ),
          ),
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
                onTap: _retakeVideo,
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
                child: Text('${_formatDuration(_recordingSeconds)}', style: const TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ),
        ),
        
        // AI Score result
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
                  Text(_aiScore!.toStringAsFixed(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SGColors.pulseGold)),
                  const Spacer(),
                  const Text('Good flow • Nice timing', style: TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
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
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF9B7DFF), strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Analyzing your video...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                )
              else
                Row(
                  children: [
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
                    Expanded(
                      child: GestureDetector(
                        onTap: _submitEntry,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [Color(0xFF9B7DFF), Color(0xFF5CF1FF)]),
                            boxShadow: [BoxShadow(color: const Color(0xFF9B7DFF).withOpacity(0.4), blurRadius: 20)],
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
