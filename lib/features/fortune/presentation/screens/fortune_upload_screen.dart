// lib/features/fortune/presentation/screens/fortune_upload_screen.dart
// 2.1113 Fortune Upload Page - Gallery upload for Photo/Video
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/sg_colors.dart';

class FortuneUploadScreen extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic>? challengeData;

  const FortuneUploadScreen({super.key, required this.challengeId, this.challengeData});

  @override
  State<FortuneUploadScreen> createState() => _FortuneUploadScreenState();
}

class _FortuneUploadScreenState extends State<FortuneUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  String _fileType = ''; // 'photo' or 'video'
  String _flowState = 'select'; // select, preview, scored
  double? _aiScore;
  bool _isProcessing = false;

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _fileType = 'photo';
          _flowState = 'preview';
        });
      }
    } catch (e) {
      debugPrint('Photo pick error: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
      if (video != null) {
        setState(() {
          _selectedFile = File(video.path);
          _fileType = 'video';
          _flowState = 'preview';
        });
      }
    } catch (e) {
      debugPrint('Video pick error: $e');
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

  void _replace() {
    setState(() {
      _selectedFile = null;
      _fileType = '';
      _flowState = 'select';
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
  Widget build(BuildContext context) {
    final challenge = widget.challengeData ?? {'title': 'Challenge', 'icon': '🎯'};

    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _flowState == 'select' ? _buildSelectView(challenge) : _buildPreviewView(challenge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go('/fortune/live/${widget.challengeId}', extra: widget.challengeData),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF0D0F1A).withOpacity(0.8), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF23263A))),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.arrow_back, color: Color(0xFFA7B0C6), size: 16), SizedBox(width: 6), Text('Back', style: TextStyle(fontSize: 13, color: Color(0xFFA7B0C6)))]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: SGColors.fortunePrimary.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: SGColors.fortunePrimary)),
            child: Text('Step ${_flowState == 'select' ? '1' : (_flowState == 'preview' ? '2' : '3')} of 3', style: const TextStyle(color: SGColors.fortunePrimary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectView(Map<String, dynamic> challenge) {
    return Column(
      children: [
        // Challenge info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: const Color(0xFF0D0F1A).withOpacity(0.8), border: Border.all(color: SGColors.fortunePrimary.withOpacity(0.3))),
          child: Row(
            children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [SGColors.fortunePrimary, SGColors.fortuneSecondary])), child: Center(child: Text(challenge['icon'] ?? '🎯', style: const TextStyle(fontSize: 26)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(challenge['title'] ?? 'Challenge', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)), const SizedBox(height: 4), const Text('Upload from gallery', style: TextStyle(fontSize: 12, color: SGColors.htmlMuted))])),
            ],
          ),
        ),
        const Spacer(),
        const Text('Select media to upload', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        const Text('Choose a photo or video from your gallery', style: TextStyle(fontSize: 13, color: SGColors.htmlMuted)),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [SGColors.fortunePrimary.withOpacity(0.3), SGColors.fortuneSecondary.withOpacity(0.1)]), border: Border.all(color: SGColors.fortunePrimary.withOpacity(0.5))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [SGColors.fortunePrimary, SGColors.fortuneSecondary]), boxShadow: [BoxShadow(color: SGColors.fortunePrimary.withOpacity(0.5), blurRadius: 20)]), child: const Icon(Icons.photo_library, color: Colors.white, size: 28)),
                      const SizedBox(height: 12),
                      const Text('PHOTO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white)),
                      const SizedBox(height: 4),
                      const Text('From gallery', style: TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
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
                  height: 140,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [SGColors.fortuneSecondary.withOpacity(0.3), SGColors.htmlCyan.withOpacity(0.1)]), border: Border.all(color: SGColors.fortuneSecondary.withOpacity(0.5))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [SGColors.fortuneSecondary, SGColors.htmlCyan]), boxShadow: [BoxShadow(color: SGColors.fortuneSecondary.withOpacity(0.5), blurRadius: 20)]), child: const Icon(Icons.video_library, color: Colors.white, size: 28)),
                      const SizedBox(height: 12),
                      const Text('VIDEO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white)),
                      const SizedBox(height: 4),
                      const Text('Max 60 seconds', style: TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const Spacer(flex: 2),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: SGColors.fortunePrimary.withOpacity(0.1), border: Border.all(color: SGColors.fortunePrimary.withOpacity(0.3))),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: SGColors.fortunePrimary, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('AI scoring costs 4 credits per submission', style: TextStyle(fontSize: 12, color: SGColors.htmlMuted))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView(Map<String, dynamic> challenge) {
    return Column(
      children: [
        // Preview
        Expanded(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: SGColors.fortunePrimary.withOpacity(0.5), width: 2)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_selectedFile != null && _fileType == 'photo')
                  Image.file(_selectedFile!, fit: BoxFit.cover)
                else
                  Container(
                    color: const Color(0xFF0D0F1A),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_fileType == 'video' ? Icons.videocam : Icons.image, color: SGColors.fortunePrimary, size: 64),
                        const SizedBox(height: 16),
                        Text(_fileType == 'video' ? 'Video Selected' : 'Media Selected', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_fileType == 'video' ? Icons.videocam : Icons.photo, color: SGColors.fortunePrimary, size: 16),
                        const SizedBox(width: 6),
                        Text(_fileType.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // AI Score Display
        if (_flowState == 'scored' && _aiScore != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [SGColors.fortunePrimary.withOpacity(0.2), SGColors.fortuneSecondary.withOpacity(0.1)]), border: Border.all(color: SGColors.fortunePrimary.withOpacity(0.5))),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: SGColors.pulseGold.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome, color: SGColors.pulseGold, size: 28)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('AI GridScore', style: TextStyle(color: Colors.white70, fontSize: 12)), Text(_aiScore!.toStringAsFixed(2), style: const TextStyle(color: SGColors.pulseGold, fontSize: 28, fontWeight: FontWeight.bold))])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: SGColors.neonMint.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text('Nice!', style: TextStyle(color: SGColors.neonMint, fontSize: 12, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        const SizedBox(height: 16),
        // Action Buttons
        Row(
          children: [
            if (_flowState == 'preview')
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
              Expanded(
                child: GestureDetector(
                  onTap: _replace,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.3))),
                    child: const Center(child: Text('REPLACE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
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
      ],
    );
  }
}
