// lib/core/services/entry_service.dart
// Handles: Upload Media → AI Score → Store Entry

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'ai_scoring_service.dart';

class EntryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Submit a photo entry with AI scoring
  static Future<EntryResult> submitPhotoEntry({
    required File imageFile,
    required String challengeId,
    required String challengeTitle,
    required String challengeDescription,
    required String gridType, // 'fortune', 'fanverse', 'gridvoice'
    String? challengeCategory,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return EntryResult.error('User not logged in');
      }

      // Step 1: Compress image
      final compressedFile = await _compressImage(imageFile);
      
      // Step 2: Upload to Storage
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String storagePath = 'photos/${user.uid}/$fileName';
      
      final ref = _storage.ref().child(storagePath);
      await ref.putFile(compressedFile);
      final String mediaUrl = await ref.getDownloadURL();

      // Step 3: Get AI Score
      final aiScore = await AIScoringService.scoreImage(
        imageUrl: mediaUrl,
        challengeTitle: challengeTitle,
        challengeDescription: challengeDescription,
        challengeCategory: challengeCategory,
      );

      // Step 4: Create entry in Firestore
      final entryData = {
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userPhoto': user.photoURL,
        'challengeId': challengeId,
        'gridType': gridType,
        'mediaType': 'photo',
        'mediaUrl': mediaUrl,
        'thumbnailUrl': mediaUrl, // Same as photo for now
        'aiScore': aiScore.success ? {
          'creativity': aiScore.creativity,
          'quality': aiScore.quality,
          'relevance': aiScore.relevance,
          'impact': aiScore.impact,
          'effort': aiScore.effort,
          'overallScore': aiScore.overallScore,
          'feedback': aiScore.feedback,
          'highlights': aiScore.highlights,
          'improvements': aiScore.improvements,
          'grade': aiScore.grade,
        } : null,
        'humanScore': 0.0,
        'finalScore': aiScore.success ? aiScore.overallScore : 0.0,
        'likes': 0,
        'status': aiScore.success ? 'scored' : 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _db.collection('entries').add(entryData);

      // Step 5: Update challenge entries count
      await _db.collection(_getCollectionName(gridType)).doc(challengeId).update({
        'entriesCount': FieldValue.increment(1),
      });

      // Step 6: Update user stats
      await _updateUserStats(user.uid, aiScore.overallScore);

      return EntryResult(
        success: true,
        entryId: docRef.id,
        mediaUrl: mediaUrl,
        aiScore: aiScore,
      );

    } catch (e) {
      return EntryResult.error('Submission failed: $e');
    }
  }

  // Submit a video entry with AI scoring (uses thumbnail for scoring)
  static Future<EntryResult> submitVideoEntry({
    required File videoFile,
    File? thumbnailFile,
    required String challengeId,
    required String challengeTitle,
    required String challengeDescription,
    required String gridType,
    String? challengeCategory,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return EntryResult.error('User not logged in');
      }

      // Step 1: Upload video to Storage
      final String videoName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String videoPath = 'videos/${user.uid}/$videoName';
      
      final videoRef = _storage.ref().child(videoPath);
      await videoRef.putFile(videoFile);
      final String videoUrl = await videoRef.getDownloadURL();

      // Step 2: Upload thumbnail if provided
      String? thumbnailUrl;
      if (thumbnailFile != null) {
        final String thumbName = '${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';
        final String thumbPath = 'thumbnails/${user.uid}/$thumbName';
        final thumbRef = _storage.ref().child(thumbPath);
        await thumbRef.putFile(thumbnailFile);
        thumbnailUrl = await thumbRef.getDownloadURL();
      }

      // Step 3: Get AI Score (using thumbnail or skip if no thumbnail)
      AIScoreResult aiScore;
      if (thumbnailUrl != null) {
        aiScore = await AIScoringService.scoreImage(
          imageUrl: thumbnailUrl,
          challengeTitle: challengeTitle,
          challengeDescription: challengeDescription,
          challengeCategory: challengeCategory,
        );
      } else {
        // No thumbnail, create pending entry
        aiScore = AIScoreResult.error('Video scoring pending');
      }

      // Step 4: Create entry in Firestore
      final entryData = {
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userPhoto': user.photoURL,
        'challengeId': challengeId,
        'gridType': gridType,
        'mediaType': 'video',
        'mediaUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'aiScore': aiScore.success ? {
          'creativity': aiScore.creativity,
          'quality': aiScore.quality,
          'relevance': aiScore.relevance,
          'impact': aiScore.impact,
          'effort': aiScore.effort,
          'overallScore': aiScore.overallScore,
          'feedback': aiScore.feedback,
          'highlights': aiScore.highlights,
          'improvements': aiScore.improvements,
          'grade': aiScore.grade,
        } : null,
        'humanScore': 0.0,
        'finalScore': aiScore.success ? aiScore.overallScore : 0.0,
        'likes': 0,
        'status': aiScore.success ? 'scored' : 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _db.collection('entries').add(entryData);

      // Update counts
      await _db.collection(_getCollectionName(gridType)).doc(challengeId).update({
        'entriesCount': FieldValue.increment(1),
      });

      if (aiScore.success) {
        await _updateUserStats(user.uid, aiScore.overallScore);
      }

      return EntryResult(
        success: true,
        entryId: docRef.id,
        mediaUrl: videoUrl,
        aiScore: aiScore,
      );

    } catch (e) {
      return EntryResult.error('Submission failed: $e');
    }
  }

  // Submit audio entry for GridVoice
  static Future<EntryResult> submitAudioEntry({
    required File audioFile,
    required String transcript,
    required String chapterId,
    required String chapterTitle,
    required String chapterDescription,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return EntryResult.error('User not logged in');
      }

      // Step 1: Upload audio to Storage
      final String audioName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      final String audioPath = 'audio/${user.uid}/$audioName';
      
      final audioRef = _storage.ref().child(audioPath);
      await audioRef.putFile(audioFile);
      final String audioUrl = await audioRef.getDownloadURL();

      // Step 2: Get AI Score for audio
      final aiScore = await AIScoringService.scoreAudio(
        transcript: transcript,
        chapterTitle: chapterTitle,
        chapterDescription: chapterDescription,
      );

      // Step 3: Create entry in Firestore
      final entryData = {
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userPhoto': user.photoURL,
        'challengeId': chapterId,
        'gridType': 'gridvoice',
        'mediaType': 'audio',
        'mediaUrl': audioUrl,
        'transcript': transcript,
        'aiScore': aiScore.success ? {
          'storytelling': aiScore.creativity,
          'clarity': aiScore.quality,
          'relevance': aiScore.relevance,
          'emotionalImpact': aiScore.impact,
          'authenticity': aiScore.effort,
          'overallScore': aiScore.overallScore,
          'feedback': aiScore.feedback,
          'highlights': aiScore.highlights,
          'improvements': aiScore.improvements,
          'grade': aiScore.grade,
        } : null,
        'humanScore': 0.0,
        'finalScore': aiScore.success ? aiScore.overallScore : 0.0,
        'likes': 0,
        'status': aiScore.success ? 'scored' : 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _db.collection('entries').add(entryData);

      // Update counts
      await _db.collection('chapters').doc(chapterId).update({
        'entriesCount': FieldValue.increment(1),
      });

      if (aiScore.success) {
        await _updateUserStats(user.uid, aiScore.overallScore);
      }

      return EntryResult(
        success: true,
        entryId: docRef.id,
        mediaUrl: audioUrl,
        aiScore: aiScore,
      );

    } catch (e) {
      return EntryResult.error('Submission failed: $e');
    }
  }

  // Get entries for a challenge
  static Stream<QuerySnapshot> getEntriesForChallenge(String challengeId) {
    return _db
        .collection('entries')
        .where('challengeId', isEqualTo: challengeId)
        .orderBy('finalScore', descending: true)
        .snapshots();
  }

  // Get entries for discovery feed
  static Stream<QuerySnapshot> getDiscoveryFeed({String? gridType}) {
    Query query = _db.collection('entries')
        .where('status', isEqualTo: 'scored')
        .orderBy('createdAt', descending: true)
        .limit(50);
    
    if (gridType != null && gridType != 'all') {
      query = query.where('gridType', isEqualTo: gridType);
    }
    
    return query.snapshots();
  }

  // Get user's entries
  static Stream<QuerySnapshot> getUserEntries(String userId) {
    return _db
        .collection('entries')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get leaderboard
  static Stream<QuerySnapshot> getLeaderboard({String? challengeId, String? gridType}) {
    Query query = _db.collection('entries')
        .where('status', isEqualTo: 'scored')
        .orderBy('finalScore', descending: true)
        .limit(100);
    
    if (challengeId != null) {
      query = query.where('challengeId', isEqualTo: challengeId);
    } else if (gridType != null) {
      query = query.where('gridType', isEqualTo: gridType);
    }
    
    return query.snapshots();
  }

  // Like an entry
  static Future<void> likeEntry(String entryId) async {
    await _db.collection('entries').doc(entryId).update({
      'likes': FieldValue.increment(1),
    });
  }

  // Helper: Compress image
  static Future<File> _compressImage(File file) async {
    final dir = path.dirname(file.path);
    final targetPath = '$dir/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
    );
    
    return result != null ? File(result.path) : file;
  }

  // Helper: Get collection name
  static String _getCollectionName(String gridType) {
    switch (gridType) {
      case 'fortune': return 'challenges';
      case 'fanverse': return 'episodes';
      case 'gridvoice': return 'chapters';
      default: return 'challenges';
    }
  }

  // Helper: Update user stats
  static Future<void> _updateUserStats(String userId, double score) async {
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    
    if (userDoc.exists) {
      await userRef.update({
        'stats.totalEntries': FieldValue.increment(1),
        'stats.totalScore': FieldValue.increment(score),
      });
    } else {
      await userRef.set({
        'stats': {
          'totalEntries': 1,
          'totalScore': score,
          'rank': 0,
        }
      }, SetOptions(merge: true));
    }
  }
}

// Result class
class EntryResult {
  final bool success;
  final String? errorMessage;
  final String? entryId;
  final String? mediaUrl;
  final AIScoreResult? aiScore;

  EntryResult({
    this.success = true,
    this.errorMessage,
    this.entryId,
    this.mediaUrl,
    this.aiScore,
  });

  factory EntryResult.error(String msg) => EntryResult(success: false, errorMessage: msg);
}
