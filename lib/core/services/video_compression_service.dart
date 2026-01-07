// lib/core/services/video_compression_service.dart
import 'dart:io';
import 'package:video_compress/video_compress.dart';

class VideoCompressionService {
  // Compress video for upload
  static Future<VideoCompressionResult> compressVideo(File videoFile) async {
    try {
      final info = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info != null && info.file != null) {
        final originalSize = await videoFile.length();
        final compressedSize = await info.file!.length();
        final savedPercent = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);

        return VideoCompressionResult(
          success: true,
          compressedFile: info.file!,
          originalSize: originalSize,
          compressedSize: compressedSize,
          savedPercent: savedPercent,
        );
      }

      return VideoCompressionResult.error('Compression failed');
    } catch (e) {
      print('Video compression error: $e');
      return VideoCompressionResult.error('Compression error: $e');
    }
  }

  // Get video thumbnail
  static Future<File?> getVideoThumbnail(String videoPath) async {
    try {
      final thumbnail = await VideoCompress.getFileThumbnail(
        videoPath,
        quality: 70,
        position: -1,
      );
      return thumbnail;
    } catch (e) {
      print('Thumbnail error: $e');
      return null;
    }
  }

  // Get video info
  static Future<MediaInfo?> getVideoInfo(String videoPath) async {
    try {
      return await VideoCompress.getMediaInfo(videoPath);
    } catch (e) {
      print('Get video info error: $e');
      return null;
    }
  }

  // Cancel compression
  static Future<void> cancelCompression() async {
    await VideoCompress.cancelCompression();
  }

  // Delete cache
  static Future<void> deleteCache() async {
    await VideoCompress.deleteAllCache();
  }
}

class VideoCompressionResult {
  final bool success;
  final File? compressedFile;
  final int? originalSize;
  final int? compressedSize;
  final String? savedPercent;
  final String? errorMessage;

  VideoCompressionResult({
    this.success = false,
    this.compressedFile,
    this.originalSize,
    this.compressedSize,
    this.savedPercent,
    this.errorMessage,
  });

  factory VideoCompressionResult.error(String msg) => VideoCompressionResult(
    success: false,
    errorMessage: msg,
  );

  String get sizeInfo {
    if (originalSize == null || compressedSize == null) return '';
    final origMB = (originalSize! / (1024 * 1024)).toStringAsFixed(1);
    final compMB = (compressedSize! / (1024 * 1024)).toStringAsFixed(1);
    return '${origMB}MB → ${compMB}MB (saved $savedPercent%)';
  }
}
