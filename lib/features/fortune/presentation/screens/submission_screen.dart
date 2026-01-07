// lib/features/fortune/presentation/screens/submission_screen.dart
// Handles upload progress and shows AI score

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/services/entry_service.dart';
import '../../../../core/widgets/ai_score_card.dart';

class SubmissionScreen extends StatefulWidget {
  final File mediaFile;
  final String mediaType; // 'photo' or 'video'
  final String challengeId;
  final String challengeTitle;
  final String challengeDescription;
  final String gridType;
  final String? challengeCategory;
  final File? thumbnailFile;

  const SubmissionScreen({
    super.key,
    required this.mediaFile,
    required this.mediaType,
    required this.challengeId,
    required this.challengeTitle,
    required this.challengeDescription,
    required this.gridType,
    this.challengeCategory,
    this.thumbnailFile,
  });

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  
  String _status = 'Preparing...';
  int _step = 0; // 0: prep, 1: upload, 2: scoring, 3: done
  EntryResult? _result;
  bool _isComplete = false;

  final List<String> _steps = [
    'Preparing media...',
    'Uploading to cloud...',
    'AI is analyzing...',
    'Complete!',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _startSubmission();
  }

  Future<void> _startSubmission() async {
    // Step 1: Preparing
    setState(() { _step = 0; _status = _steps[0]; });
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 2: Uploading
    setState(() { _step = 1; _status = _steps[1]; });

    // Step 3 & 4: AI Scoring (happens inside the service)
    EntryResult result;
    
    if (widget.mediaType == 'photo') {
      setState(() { _step = 2; _status = _steps[2]; });
      result = await EntryService.submitPhotoEntry(
        imageFile: widget.mediaFile,
        challengeId: widget.challengeId,
        challengeTitle: widget.challengeTitle,
        challengeDescription: widget.challengeDescription,
        gridType: widget.gridType,
        challengeCategory: widget.challengeCategory,
      );
    } else {
      setState(() { _step = 2; _status = _steps[2]; });
      result = await EntryService.submitVideoEntry(
        videoFile: widget.mediaFile,
        thumbnailFile: widget.thumbnailFile,
        challengeId: widget.challengeId,
        challengeTitle: widget.challengeTitle,
        challengeDescription: widget.challengeDescription,
        gridType: widget.gridType,
        challengeCategory: widget.challengeCategory,
      );
    }

    // Step 4: Complete
    setState(() {
      _step = 3;
      _status = _steps[3];
      _result = result;
      _isComplete = true;
    });
    
    _progressController.stop();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: _isComplete ? _buildResultView() : _buildProgressView(),
        ),
      ),
    );
  }

  Widget _buildProgressView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (_pulseController.value * 0.1),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [SGColors.htmlViolet, SGColors.htmlPink],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SGColors.htmlViolet.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _step == 0 ? Icons.tune :
                    _step == 1 ? Icons.cloud_upload :
                    _step == 2 ? Icons.auto_awesome :
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          
          // Status text
          Text(
            _status,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            widget.challengeTitle,
            style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted),
          ),
          const SizedBox(height: 40),
          
          // Progress indicator
          SizedBox(
            width: 200,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_step + 1) / 4,
                  backgroundColor: SGColors.borderSubtle,
                  valueColor: const AlwaysStoppedAnimation(SGColors.htmlViolet),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Step ${_step + 1} of 4',
                  style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepDot(0, 'Prep'),
              _buildStepLine(_step >= 1),
              _buildStepDot(1, 'Upload'),
              _buildStepLine(_step >= 2),
              _buildStepDot(2, 'AI'),
              _buildStepLine(_step >= 3),
              _buildStepDot(3, 'Done'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _step >= step;
    final isCurrent = _step == step;
    
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? SGColors.htmlViolet : SGColors.borderSubtle,
            border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: isActive && !isCurrent
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.white : SGColors.htmlMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive ? SGColors.htmlViolet : SGColors.borderSubtle,
    );
  }

  Widget _buildResultView() {
    if (_result == null || !_result!.success) {
      return _buildErrorView();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: SGColors.htmlGreen, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Submission Complete!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Media preview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(widget.mediaFile),
                fit: BoxFit.cover,
              ),
            ),
            child: widget.mediaType == 'video'
                ? const Center(
                    child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white70),
                  )
                : null,
          ),

          // AI Score Card
          if (_result!.aiScore != null && _result!.aiScore!.success)
            AIScoreCard(result: _result!.aiScore!),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('New Entry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: SGColors.borderSubtle),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SGColors.htmlViolet,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text(
              'Submission Failed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              _result?.errorMessage ?? 'Unknown error occurred',
              style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isComplete = false;
                  _step = 0;
                });
                _progressController.repeat();
                _startSubmission();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SGColors.htmlViolet,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
