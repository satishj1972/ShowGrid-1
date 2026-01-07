// lib/features/gridvoice/presentation/screens/audio_record_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../fortune/presentation/screens/submission_screen.dart';

class AudioRecordScreen extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  final String challengeDescription;
  final int maxDuration; // in seconds

  const AudioRecordScreen({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.challengeDescription,
    this.maxDuration = 180, // 3 minutes default
  });

  @override
  State<AudioRecordScreen> createState() => _AudioRecordScreenState();
}

class _AudioRecordScreenState extends State<AudioRecordScreen> {
  bool _isRecording = false;
  bool _hasRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  
  int _recordedSeconds = 0;
  Timer? _timer;
  
  List<double> _waveformData = [];
  Timer? _waveformTimer;
  
  Duration _playPosition = Duration.zero;
  Duration _playDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupPlayerListeners();
  }

  void _setupPlayerListeners() {
    AudioService.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    AudioService.positionStream.listen((pos) {
      setState(() => _playPosition = pos);
    });

    AudioService.durationStream.listen((dur) {
      setState(() => _playDuration = dur);
    });
  }

  Future<void> _startRecording() async {
    final started = await AudioService.startRecording();
    if (started) {
      setState(() {
        _isRecording = true;
        _recordedSeconds = 0;
        _waveformData = [];
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordedSeconds++);
        if (_recordedSeconds >= widget.maxDuration) {
          _stopRecording();
        }
      });

      _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        final amp = await AudioService.getAmplitude();
        setState(() {
          _waveformData.add(amp);
          if (_waveformData.length > 50) {
            _waveformData.removeAt(0);
          }
        });
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _waveformTimer?.cancel();

    final path = await AudioService.stopRecording();
    if (path != null) {
      setState(() {
        _isRecording = false;
        _hasRecording = true;
        _recordedPath = path;
      });
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    _waveformTimer?.cancel();
    await AudioService.cancelRecording();
    setState(() {
      _isRecording = false;
      _hasRecording = false;
      _recordedPath = null;
      _recordedSeconds = 0;
      _waveformData = [];
    });
  }

  void _playPause() async {
    if (_recordedPath == null) return;

    if (_isPlaying) {
      await AudioService.pauseAudio();
    } else {
      await AudioService.playAudio(_recordedPath!);
    }
  }

  void _retake() async {
    await AudioService.stopAudio();
    setState(() {
      _hasRecording = false;
      _recordedPath = null;
      _recordedSeconds = 0;
      _waveformData = [];
    });
  }

  void _submit() {
    if (_recordedPath == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubmissionScreen(
          mediaFile: File(_recordedPath!),
          mediaType: 'audio',
          challengeId: widget.challengeId,
          challengeTitle: widget.challengeTitle,
          challengeDescription: widget.challengeDescription,
          gridType: 'gridvoice',
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveformTimer?.cancel();
    AudioService.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: _hasRecording ? _buildPreview() : _buildRecorder(),
        ),
      ),
    );
  }

  Widget _buildRecorder() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.challengeTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Waveform visualization
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _waveformData.isEmpty
                ? List.generate(30, (i) => _buildWaveBar(0))
                : _waveformData.map((amp) => _buildWaveBar(amp)).toList(),
          ),
        ),

        const SizedBox(height: 30),

        // Timer
        Text(
          _formatDuration(_recordedSeconds),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'monospace'),
        ),
        Text(
          'Max ${_formatDuration(widget.maxDuration)}',
          style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted),
        ),

        const SizedBox(height: 20),

        // Progress bar
        if (_isRecording)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: LinearProgressIndicator(
              value: _recordedSeconds / widget.maxDuration,
              backgroundColor: SGColors.borderSubtle,
              valueColor: const AlwaysStoppedAnimation(SGColors.htmlGreen),
              minHeight: 4,
            ),
          ),

        const Spacer(),

        // Record button
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _isRecording ? Colors.red : SGColors.htmlGreen, width: 4),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: _isRecording ? BorderRadius.circular(8) : null,
                color: _isRecording ? Colors.red : SGColors.htmlGreen,
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          _isRecording ? 'Tap to stop' : 'Tap to record',
          style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildWaveBar(double amplitude) {
    final normalizedAmp = ((amplitude + 160) / 160).clamp(0.1, 1.0);
    final height = 10 + (normalizedAmp * 60);

    return Container(
      width: 4,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: SGColors.htmlGreen.withOpacity(0.8),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: _retake,
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Text('Preview Recording', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),

        const Spacer(),

        // Playback visualization
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SGColors.htmlGreen.withOpacity(0.2),
            border: Border.all(color: SGColors.htmlGreen, width: 3),
          ),
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 60,
            color: SGColors.htmlGreen,
          ),
        ),

        const SizedBox(height: 30),

        // Duration info
        Text(
          'Duration: ${_formatDuration(_recordedSeconds)}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),

        const SizedBox(height: 20),

        // Play button
        GestureDetector(
          onTap: _playPause,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: SGColors.htmlGreen,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                const SizedBox(width: 8),
                Text(_isPlaying ? 'Pause' : 'Play', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Action buttons
        Padding(
          padding: const EdgeInsets.all(20),
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
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SGColors.htmlGreen,
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
