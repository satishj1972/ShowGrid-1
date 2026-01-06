// lib/features/gridvoice/presentation/screens/gridvoice_upload_screen.dart
// 2.3112 UPLOAD FLOW - Upload Audio → Preview → Submit
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/sg_colors.dart';

class GridVoiceUploadScreen extends StatefulWidget {
  final String chapterId;
  final Map<String, dynamic>? chapterData;

  const GridVoiceUploadScreen({
    super.key,
    required this.chapterId,
    this.chapterData,
  });

  @override
  State<GridVoiceUploadScreen> createState() => _GridVoiceUploadScreenState();
}

class _GridVoiceUploadScreenState extends State<GridVoiceUploadScreen> {
  // File states
  File? _audioFile;
  File? _visualMedia;
  String? _visualMediaType;
  
  // Flow states
  String _currentState = 'select'; // select, preview
  double? _aiScore;
  bool _isProcessing = false;

  Future<void> _pickAudio() async {
    // In a real app, use file_picker for audio files
    // For demo, we'll simulate audio selection
    setState(() {
      _audioFile = File('/path/to/audio.m4a'); // Simulated
      _currentState = 'preview';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio file selected'), backgroundColor: Color(0xFF5CFFB1)),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (image != null) {
      setState(() {
        _visualMedia = File(image.path);
        _visualMediaType = 'photo';
        if (_audioFile == null) {
          _currentState = 'preview';
        }
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 90));
    if (video != null) {
      setState(() {
        _visualMedia = File(video.path);
        _visualMediaType = 'video';
        _currentState = 'preview';
      });
    }
  }

  void _removeAudio() {
    setState(() {
      _audioFile = null;
      if (_visualMedia == null) {
        _currentState = 'select';
      }
    });
  }

  void _removeVisual() {
    setState(() {
      _visualMedia = null;
      _visualMediaType = null;
      if (_audioFile == null) {
        _currentState = 'select';
      }
    });
  }

  void _resetAll() {
    setState(() {
      _audioFile = null;
      _visualMedia = null;
      _visualMediaType = null;
      _aiScore = null;
      _currentState = 'select';
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
    if (_audioFile == null && _visualMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one file'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_aiScore == null) {
      await _getAiScore();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Story uploaded! AI Score: ${_aiScore?.toStringAsFixed(2)}'),
          backgroundColor: const Color(0xFF5CFFB1),
        ),
      );
      context.go('/gridvoice/challenge/${widget.chapterId}', extra: widget.chapterData);
    }
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
                child: _currentState == 'select' ? _buildSelectView() : _buildPreviewView(),
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
            onTap: () => context.go('/gridvoice/live/${widget.chapterId}', extra: widget.chapterData),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Back', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5CA8FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF5CA8FF)),
            ),
            child: Row(
              children: const [
                Icon(Icons.cloud_upload, color: Color(0xFF5CA8FF), size: 14),
                SizedBox(width: 6),
                Text('Upload', style: TextStyle(fontSize: 11, color: Color(0xFF5CA8FF), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  // ============================================
  // SELECT VIEW - Choose files to upload
  // ============================================
  Widget _buildSelectView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Chapter info
          _buildChapterInfo(),
          const Spacer(),
          // Upload instructions
          const Text(
            'Upload your story',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add audio and/or visual content',
            style: TextStyle(fontSize: 13, color: SGColors.htmlMuted),
          ),
          const SizedBox(height: 40),
          // Upload options
          _buildUploadOptions(),
          const Spacer(flex: 2),
          // Info
          _buildInfoCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChapterInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0D0F1A).withOpacity(0.8),
        border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
            ),
            child: Center(child: Text(widget.chapterData?['icon'] ?? '📸', style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.chapterData?['title'] ?? 'Chapter', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(widget.chapterData?['chapter'] ?? '', style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOptions() {
    return Column(
      children: [
        // Audio upload
        GestureDetector(
          onTap: _pickAudio,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [const Color(0xFF5CFFB1).withOpacity(0.15), const Color(0xFF5CA8FF).withOpacity(0.05)],
              ),
              border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
                  ),
                  child: const Icon(Icons.audio_file, color: Color(0xFF050611), size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Upload Audio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      SizedBox(height: 4),
                      Text('MP3, M4A, WAV • Max 3 min', style: TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline, color: Color(0xFF5CFFB1), size: 24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Visual upload row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF0D0F1A).withOpacity(0.8),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.photo, color: Color(0xFF5CA8FF), size: 28),
                      const SizedBox(height: 8),
                      const Text('Photo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                      const Text('Optional', style: TextStyle(fontSize: 10, color: SGColors.htmlMuted)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF0D0F1A).withOpacity(0.8),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.videocam, color: Color(0xFF9B7DFF), size: 28),
                      const SizedBox(height: 8),
                      const Text('Video', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                      const Text('Max 90s', style: TextStyle(fontSize: 10, color: SGColors.htmlMuted)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF5CA8FF).withOpacity(0.1),
        border: Border.all(color: const Color(0xFF5CA8FF).withOpacity(0.2)),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Color(0xFF5CA8FF), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Voice stories can be combined with photos or videos for better engagement.',
              style: TextStyle(fontSize: 11, color: SGColors.htmlMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PREVIEW VIEW - Review and submit
  // ============================================
  Widget _buildPreviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Audio preview
          if (_audioFile != null) _buildAudioPreview(),
          // Visual preview
          if (_visualMedia != null) _buildVisualPreview(),
          // Add more options
          if (_audioFile == null || _visualMedia == null) _buildAddMoreSection(),
          const SizedBox(height: 20),
          // AI Score
          if (_aiScore != null) _buildAiScoreCard(),
          const SizedBox(height: 20),
          // Action buttons
          _buildActionButtons(),
          const SizedBox(height: 16),
          // Step indicator
          Text(
            _aiScore != null ? 'Step 3 of 3 • Confirm & Submit' : 'Step 2 of 3 • Preview & AI Score',
            style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: SGColors.htmlMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
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
              Row(
                children: const [
                  Icon(Icons.audio_file, color: Color(0xFF5CFFB1), size: 20),
                  SizedBox(width: 8),
                  Text('Audio File', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
              GestureDetector(
                onTap: _removeAudio,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  ),
                  child: const Icon(Icons.close, color: Color(0xFFFF6B6B), size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Playback visualization
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playing audio...'), duration: Duration(seconds: 1)),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
                  ),
                  child: const Icon(Icons.play_arrow, color: Color(0xFF050611), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Waveform
                    Container(
                      height: 24,
                      child: Row(
                        children: List.generate(25, (index) {
                          final height = 6.0 + (14.0 * ((index * 2) % 5) / 5);
                          return Container(
                            width: 3,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5CFFB1).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Uploaded audio', style: TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF5CA8FF).withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_visualMediaType == 'photo')
            Image.file(_visualMedia!, fit: BoxFit.cover)
          else
            Container(
              color: const Color(0xFF0D0F1A),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.videocam, color: Color(0xFF9B7DFF), size: 48),
                  SizedBox(height: 8),
                  Text('Video Selected', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _visualMediaType == 'photo' ? Icons.photo : Icons.videocam,
                    color: const Color(0xFF5CA8FF),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _visualMediaType == 'photo' ? 'Photo' : 'Video',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF5CA8FF)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: _removeVisual,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B6B).withOpacity(0.9),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF0D0F1A).withOpacity(0.6),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add more (optional)', style: TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
          const SizedBox(height: 10),
          Row(
            children: [
              if (_audioFile == null)
                Expanded(
                  child: GestureDetector(
                    onTap: _pickAudio,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.audio_file, color: Color(0xFF5CFFB1), size: 16),
                          SizedBox(width: 6),
                          Text('Audio', style: TextStyle(fontSize: 12, color: Color(0xFF5CFFB1))),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_audioFile == null && _visualMedia == null) const SizedBox(width: 10),
              if (_visualMedia == null)
                Expanded(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.photo, color: Colors.white70, size: 16),
                          SizedBox(width: 6),
                          Text('Photo', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
          const Text('Good quality • Clear audio', style: TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
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

    return Row(
      children: [
        // Replace button
        Expanded(
          child: GestureDetector(
            onTap: _resetAll,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF9F9F).withOpacity(0.65)),
              ),
              child: const Center(child: Text('Replace', style: TextStyle(fontSize: 13, color: Color(0xFFFF9F9F)))),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // AI Score button
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
                child: const Center(child: Text('AI Score', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SGColors.pulseGold))),
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
    );
  }
}
