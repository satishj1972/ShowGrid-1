// lib/features/fortune/presentation/screens/video_capture_screen.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/sg_colors.dart';
import 'submission_screen.dart';

class VideoCaptureScreen extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  final String challengeDescription;
  final String gridType;
  final String? challengeCategory;
  final int maxDuration; // in seconds

  const VideoCaptureScreen({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.challengeDescription,
    required this.gridType,
    this.challengeCategory,
    this.maxDuration = 60,
  });

  @override
  State<VideoCaptureScreen> createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isFrontCamera = false;
  FlashMode _flashMode = FlashMode.off;
  
  File? _recordedVideo;
  File? _thumbnailFile;
  
  Timer? _timer;
  int _recordedSeconds = 0;

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
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Camera error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _isRecording) return;
    
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitialized = false;
    });
    
    await _setupCamera(_cameras![_isFrontCamera ? 1 : 0]);
  }

  Future<void> _startRecording() async {
    if (_controller == null || _isRecording) return;
    
    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordedSeconds = 0;
      });
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordedSeconds++);
        
        if (_recordedSeconds >= widget.maxDuration) {
          _stopRecording();
        }
      });
    } catch (e) {
      print('Recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_isRecording) return;
    
    _timer?.cancel();
    
    try {
      final XFile video = await _controller!.stopVideoRecording();
      
      // Capture thumbnail
      final XFile thumbnail = await _controller!.takePicture();
      
      setState(() {
        _isRecording = false;
        _recordedVideo = File(video.path);
        _thumbnailFile = File(thumbnail.path);
      });
    } catch (e) {
      setState(() => _isRecording = false);
      print('Stop recording error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: widget.maxDuration),
    );
    
    if (video != null) {
      setState(() {
        _recordedVideo = File(video.path);
        _thumbnailFile = null; // No thumbnail for gallery videos
      });
    }
  }

  void _submitVideo() {
    if (_recordedVideo == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubmissionScreen(
          mediaFile: _recordedVideo!,
          mediaType: 'video',
          challengeId: widget.challengeId,
          challengeTitle: widget.challengeTitle,
          challengeDescription: widget.challengeDescription,
          gridType: widget.gridType,
          challengeCategory: widget.challengeCategory,
          thumbnailFile: _thumbnailFile,
        ),
      ),
    );
  }

  void _retake() {
    setState(() {
      _recordedVideo = null;
      _thumbnailFile = null;
      _recordedSeconds = 0;
    });
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _recordedVideo != null ? _buildPreview() : _buildCamera(),
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
          const Center(child: CircularProgressIndicator(color: SGColors.htmlPink)),

        // Top controls
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _isRecording ? null : () => context.pop(),
                icon: Icon(Icons.close, color: _isRecording ? Colors.grey : Colors.white, size: 28),
              ),
              Column(
                children: [
                  Text(
                    widget.challengeTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  if (_isRecording)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '● REC ${_formatDuration(_recordedSeconds)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: _isRecording ? null : _toggleCamera,
                icon: Icon(Icons.flip_camera_ios, color: _isRecording ? Colors.grey : Colors.white, size: 28),
              ),
            ],
          ),
        ),

        // Progress bar
        if (_isRecording)
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _recordedSeconds / widget.maxDuration,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(SGColors.htmlPink),
                  minHeight: 4,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDuration(_recordedSeconds)} / ${_formatDuration(widget.maxDuration)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
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
                onPressed: _isRecording ? null : _pickFromGallery,
                icon: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _isRecording ? Colors.grey : Colors.white, width: 2),
                  ),
                  child: Icon(Icons.video_library, color: _isRecording ? Colors.grey : Colors.white),
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
                    child: _isRecording
                        ? const Icon(Icons.stop, color: Colors.white, size: 30)
                        : null,
                  ),
                ),
              ),
              
              // Timer display
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${widget.maxDuration}s',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
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
        // Thumbnail preview (or placeholder)
        if (_thumbnailFile != null)
          Image.file(_thumbnailFile!, fit: BoxFit.cover)
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam, size: 80, color: SGColors.htmlPink),
                  SizedBox(height: 16),
                  Text('Video Ready', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
          ),

        // Play icon overlay
        const Center(
          child: Icon(Icons.play_circle_fill, size: 80, color: Colors.white70),
        ),

        // Duration badge
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Duration: ${_formatDuration(_recordedSeconds)}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),

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
                  onPressed: _submitVideo,
                  icon: const Icon(Icons.check),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SGColors.htmlPink,
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
