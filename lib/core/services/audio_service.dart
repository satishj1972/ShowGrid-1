// lib/core/services/audio_service.dart
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioRecorder _recorder = AudioRecorder();
  static final AudioPlayer _player = AudioPlayer();
  static String? _currentPath;

  // Check permission and start recording
  static Future<bool> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _currentPath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentPath!,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Start recording error: $e');
      return false;
    }
  }

  // Stop recording and return file path
  static Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      return path;
    } catch (e) {
      print('Stop recording error: $e');
      return null;
    }
  }

  // Cancel recording
  static Future<void> cancelRecording() async {
    try {
      await _recorder.stop();
      if (_currentPath != null) {
        final file = File(_currentPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Cancel recording error: $e');
    }
  }

  // Check if recording
  static Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  // Get amplitude for waveform visualization
  static Future<double> getAmplitude() async {
    try {
      final amp = await _recorder.getAmplitude();
      return amp.current;
    } catch (e) {
      return -160.0;
    }
  }

  // Play audio file
  static Future<void> playAudio(String path) async {
    try {
      await _player.play(DeviceFileSource(path));
    } catch (e) {
      print('Play audio error: $e');
    }
  }

  // Pause audio
  static Future<void> pauseAudio() async {
    await _player.pause();
  }

  // Stop audio
  static Future<void> stopAudio() async {
    await _player.stop();
  }

  // Get player state stream
  static Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  // Get position stream
  static Stream<Duration> get positionStream => _player.onPositionChanged;

  // Get duration stream
  static Stream<Duration> get durationStream => _player.onDurationChanged;

  // Dispose
  static Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
