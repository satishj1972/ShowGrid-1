// lib/core/services/entry_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'ai_scoring_service.dart';
import 'video_compression_service.dart';

class EntryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Submit photo entry with compression
  static Future<EntryResult> submitPhotoEntry({
    required File imageFile,
    required String challengeId,
    required String gridType,
    String? challengeDescription,
    String? category,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return EntryResult.error('Please log in');

      // Step 1: Compress image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 70,
        minWidth: 1080,
        minHeight: 1080,
      );

      if (compressedBytes == null) {
        return EntryResult.error('Failed to compress image');
      }

      // Step 2: Upload to Storage
      final fileName = 'photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.putData(compressedBytes, SettableMetadata(contentType: 'image/jpeg'));
      final mediaUrl = await ref.getDownloadURL();

      // Step 3: Get AI Score
      final aiScore = await AIScoringService.scoreImage(
        imageUrl: mediaUrl,
        challengeDescription: challengeDescription,
        category: category,
      );

      // Step 4: Create entry in Firestore
      final entryRef = await _db.collection('entries').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'GridMaster',
        'userPhoto': user.photoURL,
        'challengeId': challengeId,
        'gridType': gridType,
        'mediaType': 'photo',
        'mediaUrl': mediaUrl,
        'thumbnailUrl': mediaUrl,
        'aiScore': aiScore,
        'humanScore': 0.0,
        'finalScore': aiScore['overallScore'] ?? 0.0,
        'likes': 0,
        'status': 'scored',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Step 5: Update challenge entry count
      await _updateChallengeCount(challengeId, gridType);

      // Step 6: Update user stats
      await _updateUserStats(user.uid, aiScore['overallScore'] ?? 0.0);

      return EntryResult(
        success: true,
        entryId: entryRef.id,
        mediaUrl: mediaUrl,
        aiScore: aiScore,
      );
    } catch (e) {
      return EntryResult.error('Failed to submit: $e');
    }
  }

  // Submit video entry with compression
  static Future<EntryResult> submitVideoEntry({
    required File videoFile,
    required String challengeId,
    required String gridType,
    String? challengeDescription,
    String? category,
    File? thumbnailFile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return EntryResult.error('Please log in');

      // Step 1: Compress video
      File uploadFile = videoFile;

      final compressionResult = await VideoCompressionService.compressVideo(videoFile);
      if (compressionResult.success && compressionResult.compressedFile != null) {
        uploadFile = compressionResult.compressedFile!;
        print('Video compressed: ${compressionResult.sizeInfo}');
      }

      // Step 2: Upload video
      final videoFileName = 'videos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      final videoRef = _storage.ref().child(videoFileName);
      await videoRef.putFile(uploadFile, SettableMetadata(contentType: 'video/mp4'));
      final videoUrl = await videoRef.getDownloadURL();

      // Step 3: Upload or generate thumbnail
      String? thumbnailUrl;
      if (thumbnailFile != null) {
        final thumbFileName = 'thumbnails/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final thumbRef = _storage.ref().child(thumbFileName);
        await thumbRef.putFile(thumbnailFile, SettableMetadata(contentType: 'image/jpeg'));
        thumbnailUrl = await thumbRef.getDownloadURL();
      } else {
        // Generate thumbnail from video
        final generatedThumb = await VideoCompressionService.getVideoThumbnail(videoFile.path);
        if (generatedThumb != null) {
          final thumbFileName = 'thumbnails/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final thumbRef = _storage.ref().child(thumbFileName);
          await thumbRef.putFile(generatedThumb, SettableMetadata(contentType: 'image/jpeg'));
          thumbnailUrl = await thumbRef.getDownloadURL();
        }
      }

      // Step 4: Get AI Score using thumbnail
      Map<String, dynamic> aiScore = {'overallScore': 7.0, 'feedback': 'Video submitted successfully'};
      if (thumbnailUrl != null) {
        aiScore = await AIScoringService.scoreImage(
          imageUrl: thumbnailUrl,
          challengeDescription: challengeDescription,
          category: category,
        );
      }

      // Step 5: Create entry
      final entryRef = await _db.collection('entries').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'GridMaster',
        'userPhoto': user.photoURL,
        'challengeId': challengeId,
        'gridType': gridType,
        'mediaType': 'video',
        'mediaUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'aiScore': aiScore,
        'humanScore': 0.0,
        'finalScore': aiScore['overallScore'] ?? 0.0,
        'likes': 0,
        'status': 'scored',
        'compressionInfo': compressionResult.success ? compressionResult.sizeInfo : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _updateChallengeCount(challengeId, gridType);
      await _updateUserStats(user.uid, aiScore['overallScore'] ?? 0.0);

      // Clean up compression cache
      await VideoCompressionService.deleteCache();

      return EntryResult(
        success: true,
        entryId: entryRef.id,
        mediaUrl: videoUrl,
        aiScore: aiScore,
      );
    } catch (e) {
      return EntryResult.error('Failed to submit: $e');
    }
  }

  // Submit audio entry
  static Future<EntryResult> submitAudioEntry({
    required File audioFile,
    required String challengeId,
    required String gridType,
    String? challengeDescription,
    String? category,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return EntryResult.error('Please log in');

      // Step 1: Upload audio
      final audioFileName = 'audio/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      final audioRef = _storage.ref().child(audioFileName);
      await audioRef.putFile(audioFile, SettableMetadata(contentType: 'audio/m4a'));
      final audioUrl = await audioRef.getDownloadURL();

      // Step 2: Get AI Score
      final aiScore = await AIScoringService.scoreAudio(
        audioUrl: audioUrl,
        challengeDescription: challengeDescription,
        category: category,
      );

      // Step 3: Create entry
      final entryRef = await _db.collection('entries').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'GridMaster',
        'userPhoto': user.photoURL,
        'challengeId': challengeId,
        'gridType': gridType,
        'mediaType': 'audio',
        'mediaUrl': audioUrl,
        'aiScore': aiScore,
        'transcript': aiScore['transcript'],
        'humanScore': 0.0,
        'finalScore': aiScore['overallScore'] ?? 0.0,
        'likes': 0,
        'status': 'scored',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _updateChallengeCount(challengeId, gridType);
      await _updateUserStats(user.uid, aiScore['overallScore'] ?? 0.0);

      return EntryResult(
        success: true,
        entryId: entryRef.id,
        mediaUrl: audioUrl,
        aiScore: aiScore,
      );
    } catch (e) {
      return EntryResult.error('Failed to submit: $e');
    }
  }

  static Future<void> _updateChallengeCount(String challengeId, String gridType) async {
    String collection = 'challenges';
    if (gridType == 'fanverse') collection = 'episodes';
    if (gridType == 'gridvoice') collection = 'chapters';

    await _db.collection(collection).doc(challengeId).update({
      'entriesCount': FieldValue.increment(1),
    }).catchError((_) {});
  }

  static Future<void> _updateUserStats(String uid, double score) async {
    await _db.collection('users').doc(uid).update({
      'stats.totalEntries': FieldValue.increment(1),
      'stats.totalScore': FieldValue.increment(score),
    }).catchError((_) {});
  }

  // Query methods
  static Stream<QuerySnapshot> getEntriesForChallenge(String challengeId) {
    return _db.collection('entries')
        .where('challengeId', isEqualTo: challengeId)
        .orderBy('finalScore', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getDiscoveryFeed({String? gridType}) {
    Query query = _db.collection('entries')
        .where('status', isEqualTo: 'scored')
        .orderBy('createdAt', descending: true)
        .limit(50);

    return query.snapshots();
  }

  static Stream<QuerySnapshot> getUserEntries(String userId) {
    return _db.collection('entries')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getLeaderboard({String? challengeId, String? gridType}) {
    Query query = _db.collection('entries')
        .where('status', isEqualTo: 'scored')
        .orderBy('finalScore', descending: true)
        .limit(100);

    return query.snapshots();
  }

  static Future<void> likeEntry(String entryId) async {
    await _db.collection('entries').doc(entryId).update({
      'likes': FieldValue.increment(1),
    });
  }
}

class EntryResult {
  final bool success;
  final String? entryId;
  final String? mediaUrl;
  final Map<String, dynamic>? aiScore;
  final String? errorMessage;

  EntryResult({
    this.success = false,
    this.entryId,
    this.mediaUrl,
    this.aiScore,
    this.errorMessage,
  });

  factory EntryResult.error(String msg) => EntryResult(success: false, errorMessage: msg);
}
