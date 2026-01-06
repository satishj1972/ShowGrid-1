// lib/features/fanverse/presentation/screens/fanverse_upload_screen.dart
// 2.2113 Upload Page (Photo / Video) → Preview → Submit
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/sg_colors.dart';

class FanverseUploadScreen extends StatefulWidget {
  final String episodeId;
  final Map<String, dynamic>? episodeData;

  const FanverseUploadScreen({
    super.key,
    required this.episodeId,
    this.episodeData,
  });

  @override
  State<FanverseUploadScreen> createState() => _FanverseUploadScreenState();
}

class _FanverseUploadScreenState extends State<FanverseUploadScreen> {
  File? _selectedFile;
  String? _fileType; // 'photo' or 'video'
  double? _aiScore;
  bool _isProcessing = false;
  int _credits = 20;

  // Flow states: select, preview, scored
  String _currentState = 'select';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _fileType = 'photo';
        _currentState = 'preview';
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
    if (video != null) {
      setState(() {
        _selectedFile = File(video.path);
        _fileType = 'video';
        _currentState = 'preview';
      });
    }
  }

  void _replaceFile() {
    setState(() {
      _selectedFile = null;
      _fileType = null;
      _aiScore = null;
      _currentState = 'select';
    });
  }

  Future<void> _getAiScore() async {
    if (_credits < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough credits'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() {
      _isProcessing = true;
      _credits -= 4;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _aiScore = 7.5 + (2.5 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
      _isProcessing = false;
      _currentState = 'scored';
    });
  }

  Future<void> _submitEntry() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entry submitted!${_aiScore != null ? ' AI Score: ${_aiScore!.toStringAsFixed(2)}' : ''}'),
          backgroundColor: const Color(0xFFFF4FD8),
        ),
      );
      context.go('/fanverse/challenge/${widget.episodeId}', extra: widget.episodeData);
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
            colors: [Color(0xFF1E1633), Color(0xFF05060A), Color(0xFF020308)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top bar
              _buildTopBar(),
              // Main content
              _selectedFile == null ? _buildSelectView() : _buildPreviewView(),
              // Bottom dock
              _buildBottomDock(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            GestureDetector(
              onTap: () => context.go('/fanverse/live/${widget.episodeId}', extra: widget.episodeData),
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
            // Upload badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(colors: [const Color(0xFFFF4FD8).withOpacity(0.18), const Color(0xFF5CF1FF).withOpacity(0.18)]),
                border: Border.all(color: Colors.white.withOpacity(0.24)),
              ),
              child: const Text('UPLOAD • Photo / Video', style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
            // Credits
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0xFF040714).withOpacity(0.85),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF5CF1FF),
                      boxShadow: [BoxShadow(color: const Color(0xFF5CF1FF), blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Credits: $_credits', style: const TextStyle(fontSize: 11, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SELECT VIEW - Choose file
  // ============================================
  Widget _buildSelectView() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      bottom: 150,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const RadialGradient(
            colors: [Color(0xFF2A2D48), Color(0xFF0B0D12), Color(0xFF000000)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [const Color(0xFFFF4FD8).withOpacity(0.3), const Color(0xFF9B7DFF).withOpacity(0.3)]),
                border: Border.all(color: const Color(0xFFFF4FD8).withOpacity(0.5), width: 2),
              ),
              child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Upload your entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 8),
            Text(widget.episodeData?['title'] ?? 'Choose a photo or video', style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted)),
            const SizedBox(height: 24),
            // Upload options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUploadOption(icon: Icons.photo, label: 'Photo', onTap: _pickImage),
                const SizedBox(width: 16),
                _buildUploadOption(icon: Icons.videocam, label: 'Video', onTap: _pickVideo),
              ],
            ),
            const SizedBox(height: 16),
            const Text('JPG, PNG or MP4 • Max 60s', style: TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [const Color(0xFFFF4FD8).withOpacity(0.2), const Color(0xFF9B7DFF).withOpacity(0.1)]),
          border: Border.all(color: const Color(0xFFFF4FD8).withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFF4FD8), size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PREVIEW VIEW - Show selected file
  // ============================================
  Widget _buildPreviewView() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      bottom: 150,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFFF4FD8).withOpacity(0.5), width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // File preview
            if (_fileType == 'photo' && _selectedFile != null)
              Image.file(_selectedFile!, fit: BoxFit.cover)
            else
              Container(
                color: const Color(0xFF0B0D12),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline, color: Color(0xFF9B7DFF), size: 60),
                      SizedBox(height: 12),
                      Text('Video Selected', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            // Type badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF5CF1FF).withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_fileType == 'photo' ? Icons.photo : Icons.videocam, color: const Color(0xFF5CF1FF), size: 14),
                    const SizedBox(width: 4),
                    Text(_fileType == 'photo' ? 'Photo' : 'Video', style: const TextStyle(fontSize: 11, color: Color(0xFF5CF1FF))),
                  ],
                ),
              ),
            ),
            // AI Score badge (if scored)
            if (_aiScore != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: SGColors.pulseGold),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('AI ', style: TextStyle(fontSize: 11, color: SGColors.pulseGold)),
                      Text(_aiScore!.toStringAsFixed(1), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SGColors.pulseGold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BOTTOM DOCK - Actions
  // ============================================
  Widget _buildBottomDock() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xE6000000), Color(0x1A000000)],
          ),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score panel (if in preview or scored state)
            if (_selectedFile != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    colors: [const Color(0xFFFF4FD8).withOpacity(0.16), const Color(0xFF000000).withOpacity(0.9)],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: _aiScore != null
                    ? Row(
                        children: [
                          const Text('AI Score: ', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          Text('${_aiScore!.toStringAsFixed(2)} / 10', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SGColors.pulseGold)),
                          const Spacer(),
                          const Text('Strong clarity • Good framing', style: TextStyle(fontSize: 10, color: SGColors.htmlMuted)),
                        ],
                      )
                    : const Text('Preview ready. Submit or get AI Score first.', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ),
              const SizedBox(height: 12),
            ],
            // Action buttons
            if (_isProcessing)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFFF4FD8), strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Analyzing...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
            else if (_selectedFile != null)
              Row(
                children: [
                  // Replace button
                  Expanded(
                    child: GestureDetector(
                      onTap: _replaceFile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xFFFF9F9F).withOpacity(0.65)),
                        ),
                        child: const Center(child: Text('Replace', style: TextStyle(fontSize: 12, color: Color(0xFFFF9F9F)))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // AI Score button (if not scored)
                  if (_aiScore == null) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: _getAiScore,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: const Color(0xFF060C1C).withOpacity(0.9),
                            border: Border.all(color: SGColors.pulseGold),
                          ),
                          child: const Center(child: Text('AI Score (−4)', style: TextStyle(fontSize: 12, color: SGColors.pulseGold))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Submit button
                  Expanded(
                    flex: _aiScore != null ? 2 : 1,
                    child: GestureDetector(
                      onTap: _submitEntry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF)]),
                          boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.5), blurRadius: 16)],
                        ),
                        child: Center(
                          child: Text(_aiScore != null ? 'Use & Submit' : 'Submit', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            // Step label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedFile == null
                      ? 'Step 1 of 3 • Select your file'
                      : (_aiScore == null ? 'Step 2 of 3 • Preview & AI Score' : 'Step 3 of 3 • Confirm & Submit'),
                  style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: SGColors.htmlMuted),
                ),
                const Text('AI Score uses 4 credits', style: TextStyle(fontSize: 10, color: SGColors.htmlMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
