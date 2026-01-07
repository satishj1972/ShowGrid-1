// lib/features/fortune/presentation/screens/submission_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/services/entry_service.dart';
import '../../../../core/widgets/ai_score_card.dart';

class SubmissionScreen extends StatefulWidget {
  final File mediaFile;
  final String mediaType;
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

class _SubmissionScreenState extends State<SubmissionScreen> {
  int _currentStep = 0;
  bool _isComplete = false;
  bool _hasError = false;
  String _errorMessage = '';
  EntryResult? _result;

  final List<String> _steps = [
    'Preparing media...',
    'Compressing...',
    'Uploading to cloud...',
    'AI is analyzing...',
    'Complete!',
  ];

  @override
  void initState() {
    super.initState();
    _submitEntry();
  }

  Future<void> _submitEntry() async {
    try {
      // Step 1: Preparing
      setState(() => _currentStep = 0);
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Compressing (for video)
      if (widget.mediaType == 'video') {
        setState(() => _currentStep = 1);
      }

      // Step 3: Uploading
      setState(() => _currentStep = 2);

      EntryResult result;

      if (widget.mediaType == 'photo') {
        result = await EntryService.submitPhotoEntry(
          imageFile: widget.mediaFile,
          challengeId: widget.challengeId,
          gridType: widget.gridType,
          challengeDescription: widget.challengeDescription,
          category: widget.challengeCategory,
        );
      } else if (widget.mediaType == 'video') {
        result = await EntryService.submitVideoEntry(
          videoFile: widget.mediaFile,
          challengeId: widget.challengeId,
          gridType: widget.gridType,
          challengeDescription: widget.challengeDescription,
          category: widget.challengeCategory,
          thumbnailFile: widget.thumbnailFile,
        );
      } else {
        // Audio
        result = await EntryService.submitAudioEntry(
          audioFile: widget.mediaFile,
          challengeId: widget.challengeId,
          gridType: widget.gridType,
          challengeDescription: widget.challengeDescription,
          category: widget.challengeCategory,
        );
      }

      // Step 4: AI Analyzing (already done in service)
      setState(() => _currentStep = 3);
      await Future.delayed(const Duration(milliseconds: 500));

      if (result.success) {
        setState(() {
          _currentStep = 4;
          _isComplete = true;
          _result = result;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = result.errorMessage ?? 'Submission failed';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: _hasError ? _buildErrorView() : (_isComplete ? _buildResultView() : _buildProgressView()),
        ),
      ),
    );
  }

  Widget _buildProgressView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SGColors.htmlViolet.withOpacity(0.2),
              ),
              child: Icon(
                _getStepIcon(_currentStep),
                size: 50,
                color: SGColors.htmlViolet,
              ),
            ),
            const SizedBox(height: 40),

            // Progress bar
            LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
              backgroundColor: SGColors.borderSubtle,
              valueColor: const AlwaysStoppedAnimation(SGColors.htmlViolet),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 16),

            // Step text
            Text(
              _steps[_currentStep],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_currentStep + 1} of ${_steps.length}',
              style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0: return Icons.tune;
      case 1: return Icons.compress;
      case 2: return Icons.cloud_upload;
      case 3: return Icons.auto_awesome;
      case 4: return Icons.check_circle;
      default: return Icons.hourglass_empty;
    }
  }

  Widget _buildResultView() {
    final score = _result?.aiScore;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SGColors.htmlGreen.withOpacity(0.2),
            ),
            child: const Icon(Icons.check_circle, size: 60, color: SGColors.htmlGreen),
          ),
          const SizedBox(height: 24),

          const Text('Submission Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Text(widget.challengeTitle, style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted)),
          const SizedBox(height: 30),

          // AI Score Card
          if (score != null) AIScoreCard(scoreData: score),
          const SizedBox(height: 30),

          // Transcript preview (for audio)
          if (widget.mediaType == 'audio' && score != null && score['transcript'] != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: SGColors.htmlGlass,
                border: Border.all(color: SGColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.subtitles, size: 18, color: SGColors.htmlCyan),
                      SizedBox(width: 8),
                      Text('Transcript', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SGColors.htmlCyan)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    score['transcript'].toString().length > 200
                        ? '${score['transcript'].toString().substring(0, 200)}...'
                        : score['transcript'].toString(),
                    style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 30),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
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
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SGColors.htmlViolet,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.2),
              ),
              child: const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            const Text('Submission Failed', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 12),
            Text(_errorMessage, style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: SGColors.borderSubtle),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _currentStep = 0;
                      });
                      _submitEntry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SGColors.htmlViolet,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Try Again'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
