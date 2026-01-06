// lib/core/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class UploadResult {
  final bool success;
  final String? downloadUrl;
  final String? thumbnailUrl;
  final String? error;
  UploadResult({required this.success, this.downloadUrl, this.thumbnailUrl, this.error});
}

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload photo
  Future<UploadResult> uploadPhoto({
    required File file,
    required String userId,
    required String contestId,
    Function(double)? onProgress,
  }) async {
    try {
      final path = 'entries/$contestId/photos/${userId}_${_uuid.v4()}.jpg';
      final ref = _storage.ref().child(path);
      
      final uploadTask = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      uploadTask.snapshotEvents.listen((event) {
        onProgress?.call(event.bytesTransferred / event.totalBytes);
      });
      
      await uploadTask;
      final url = await ref.getDownloadURL();
      return UploadResult(success: true, downloadUrl: url, thumbnailUrl: url);
    } catch (e) {
      return UploadResult(success: false, error: 'Upload failed: $e');
    }
  }

  // Upload video
  Future<UploadResult> uploadVideo({
    required File file,
    required String userId,
    required String contestId,
    Function(double)? onProgress,
  }) async {
    try {
      final path = 'entries/$contestId/videos/${userId}_${_uuid.v4()}.mp4';
      final ref = _storage.ref().child(path);
      
      final uploadTask = ref.putFile(file, SettableMetadata(contentType: 'video/mp4'));
      uploadTask.snapshotEvents.listen((event) {
        onProgress?.call(event.bytesTransferred / event.totalBytes);
      });
      
      await uploadTask;
      final url = await ref.getDownloadURL();
      return UploadResult(success: true, downloadUrl: url, thumbnailUrl: url);
    } catch (e) {
      return UploadResult(success: false, error: 'Upload failed: $e');
    }
  }

  // Upload audio
  Future<UploadResult> uploadAudio({
    required File file,
    required String userId,
    required String contestId,
    Function(double)? onProgress,
  }) async {
    try {
      final path = 'entries/$contestId/audio/${userId}_${_uuid.v4()}.m4a';
      final ref = _storage.ref().child(path);
      
      final uploadTask = ref.putFile(file, SettableMetadata(contentType: 'audio/m4a'));
      uploadTask.snapshotEvents.listen((event) {
        onProgress?.call(event.bytesTransferred / event.totalBytes);
      });
      
      await uploadTask;
      final url = await ref.getDownloadURL();
      return UploadResult(success: true, downloadUrl: url);
    } catch (e) {
      return UploadResult(success: false, error: 'Upload failed: $e');
    }
  }
}
