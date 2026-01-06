// lib/features/gridvoice/presentation/screens/gridvoice_audio_screen.dart
// 2.3111 AUDIO FLOW - Start Recording → Stop Recording → Review/Retake → Submit
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/sg_colors.dart';

class GridVoiceAudioScreen extends StatefulWidget {
  final String chapterId;
  final Map<String, dynamic>? chapterData;

  const GridVoiceAudioScreen({
    super.key,
    required this.chapterId,
    this.chapterData,
  });

  @override
  State<GridVoiceAudioScreen> createState() => _GridVoiceAudioScreenState();
}

class _GridVoiceAudioScreenState extends State<GridVoiceAudioScreen> with SingleTickerProviderStateMixin {
  // Flow states: ready, recording, review
  String _currentState = 'ready';
  
  // Recording state
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  static const int maxRecordingSeconds = 180; // 3 minutes for voice stories
  
  // Review state
  double? _aiScore;
  bool _isProcessing = false;
  
  // Optional photo/video attachment
  File? _attachedMedia;
  String? _mediaType;
  
  // Animation for recording pulse
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startRecording() {
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
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _currentState = 'review';
    });
  }

  void _retakeRecording() {
    setState(() {
      _currentState = 'ready';
      _recordingSeconds = 0;
      _aiScore = null;
    });
  }

  Future<void> _attachPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (image != null) {
      setState(() {
        _attachedMedia = File(image.path);
        _mediaType = 'photo';
      });
    }
  }

  Future<void> _attachVideo() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 90));
    if (video != null) {
      setState(() {
        _attachedMedia = File(video.path);
        _mediaType = 'video';
      });
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachedMedia = null;
      _mediaType = null;
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
          content: Text('Voice story submitted! AI Score: ${_aiScore?.toStringAsFixed(2)}'),
          backgroundColor: const Color(0xFF5CFFB1),
        ),
      );
      context.go('/gridvoice/challenge/${widget.chapterId}', extra: widget.chapterData);
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [Color(0xFF1A2A3A), Color(0xFF05060A), Color(0xFF020308)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: _currentState == 'review' ? _buildReviewView() : _buildRecordingView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _isRecording ? null : () => context.go('/gridvoice/live/${widget.chapterId}', extra: widget.chapterData),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Icon(Icons.close, color: _isRecording ? Colors.grey : Colors.white, size: 22),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5CFFB1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF5CFFB1)),
            ),
            child: Row(
              children: const [
                Icon(Icons.mic, color: Color(0xFF5CFFB1), size: 14),
                SizedBox(width: 6),
                Text('Voice Story', style: TextStyle(fontSize: 11, color: Color(0xFF5CFFB1), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 44), // Balance for close button
        ],
      ),
    );
  }

  // ============================================
  // RECORDING VIEW (2.31111 & 2.31112)
  // ============================================
  Widget _buildRecordingView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          // Chapter info
          Text(
            widget.chapterData?['title'] ?? 'Voice Story',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _currentState == 'ready' 
                ? 'Tap the mic to start recording your story'
                : 'Recording... Tap again to stop',
            style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted),
          ),
          const Spacer(),
          // Waveform visualization placeholder
          if (_isRecording) _buildWaveformVisualization(),
          const SizedBox(height: 30),
          // Timer
          Text(
            _formatDuration(_recordingSeconds),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: _isRecording ? const Color(0xFF5CFFB1) : Colors.white.withOpacity(0.5),
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Max ${_formatDuration(maxRecordingSeconds)}',
            style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted),
          ),
          const Spacer(),
          // Record button
          _buildRecordButton(),
          const SizedBox(height: 30),
          // Attachment section (only when not recording)
          if (!_isRecording) _buildAttachmentSection(),
          const Spacer(),
          // Tips
          if (!_isRecording) _buildTips(),
        ],
      ),
    );
  }

  Widget _buildWaveformVisualization() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(20, (index) {
          final height = 10.0 + (30.0 * ((index + _recordingSeconds) % 5) / 5);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 4,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF5CFFB1).withOpacity(0.8),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isRecording
                    ? const LinearGradient(colors: [Colors.red, Color(0xFFFF6B6B)])
                    : const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : const Color(0xFF5CFFB1)).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _isRecording ? Colors.white : const Color(0xFF050611),
                size: 44,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F1A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.attach_file, color: Color(0xFF5CA8FF), size: 16),
              SizedBox(width: 8),
              Text('Add visual context (optional)', style: TextStyle(fontSize: 12, color: Color(0xFF5CA8FF))),
            ],
          ),
          const SizedBox(height: 10),
          if (_attachedMedia != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5CFFB1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _mediaType == 'photo' ? Icons.photo : Icons.videocam,
                    color: const Color(0xFF5CFFB1),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_mediaType == 'photo' ? 'Photo' : 'Video'} attached',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5CFFB1)),
                    ),
                  ),
                  GestureDetector(
                    onTap: _removeAttachment,
                    child: const Icon(Icons.close, color: Color(0xFFFF6B6B), size: 18),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _attachPhoto,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.photo, color: Colors.white70, size: 18),
                          SizedBox(width: 6),
                          Text('Photo', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _attachVideo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.videocam, color: Colors.white70, size: 18),
                          SizedBox(width: 6),
                          Text('Video', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF5CFFB1).withOpacity(0.08),
        border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.2)),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_outline, color: Color(0xFF5CFFB1), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Speak naturally. Share the story behind your experience.',
              style: TextStyle(fontSize: 11, color: SGColors.htmlMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // REVIEW VIEW (2.31113 Review/Retake → Submit)
  // ============================================
  Widget _buildReviewView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Playback card
          _buildPlaybackCard(),
          const SizedBox(height: 16),
          // Attached media preview
          if (_attachedMedia != null) _buildMediaPreview(),
          const Spacer(),
          // AI Score (if available)
          if (_aiScore != null) _buildAiScoreCard(),
          const SizedBox(height: 16),
          // Action buttons
          _buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPlaybackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          center: Alignment.topLeft,
          colors: [const Color(0xFF5CFFB1).withOpacity(0.15), const Color(0xFF0D0F1A)],
        ),
        border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Voice Recording', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5CFFB1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(_formatDuration(_recordingSeconds), style: const TextStyle(fontSize: 12, color: Color(0xFF5CFFB1))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Playback button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Play audio preview
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playing audio...'), duration: Duration(seconds: 1)),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF5CFFB1).withOpacity(0.4), blurRadius: 20)],
                  ),
                  child: const Icon(Icons.play_arrow, color: Color(0xFF050611), size: 32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Waveform preview
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(30, (index) {
                final height = 8.0 + (24.0 * ((index * 3) % 7) / 7);
                return Container(
                  width: 3,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5CFFB1).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      height: 120,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5CA8FF).withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_mediaType == 'photo')
            Image.file(_attachedMedia!, fit: BoxFit.cover)
          else
            Container(
              color: const Color(0xFF0D0F1A),
              child: const Center(
                child: Icon(Icons.videocam, color: Color(0xFF5CA8FF), size: 40),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _mediaType == 'photo' ? 'Photo' : 'Video',
                style: const TextStyle(fontSize: 10, color: Color(0xFF5CA8FF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiScoreCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.black.withOpacity(0.6),
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
          const Text('Clear audio • Good pace', style: TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isProcessing) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF5CFFB1), strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Analyzing your story...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            // Retake button
            Expanded(
              child: GestureDetector(
                onTap: _retakeRecording,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                    border: Border.all(color: const Color(0xFFFF9F9F).withOpacity(0.65)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh, color: Color(0xFFFF9F9F), size: 18),
                      SizedBox(width: 6),
                      Text('Retake', style: TextStyle(fontSize: 13, color: Color(0xFFFF9F9F))),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // AI Score button (if not scored)
            if (_aiScore == null) ...[
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
                      child: Text('AI Score', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SGColors.pulseGold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            // Submit button
            Expanded(
              flex: _aiScore != null ? 2 : 1,
              child: GestureDetector(
                onTap: _submitEntry,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF5CFFB1).withOpacity(0.4), blurRadius: 20)],
                  ),
                  child: Center(
                    child: Text(
                      _aiScore != null ? 'SUBMIT STORY' : 'SUBMIT',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF050611)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
